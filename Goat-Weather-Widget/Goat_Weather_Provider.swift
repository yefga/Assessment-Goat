/// Copyright (c) 2023 Yefga.com
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import WidgetKit
import Combine
import SwiftUI
import Kingfisher

private var cancelBag = Set<AnyCancellable>()

struct WidgetProvider: TimelineProvider {
    
    typealias Entry = WidgetEntry
    
    func placeholder(
        in context: Context
    ) -> Entry {
        let entryDate = Calendar.current.date(byAdding: .minute,
                                              value: 1,
                                              to: Date())!
        return WidgetEntry(date: entryDate,
                                data: .init(
                                    location: "Current Location",
                                    backgroundImage: .placeholder("image.example"),
                                    weatherImage: .placeholder("image.weather")
                                )
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (Entry) -> ()
    ) {
        let entryDate = Calendar.current.date(byAdding: .minute, 
                                              value: 1,
                                              to: Date())!
        let entry = WidgetEntry(date: entryDate,
                                data: .init(
                                    location: "Location",
                                    backgroundImage: .placeholder("image.example"),
                                    weatherImage: .placeholder("image.weather")
                                )
        )
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        let currentDate = Date()
        let entryDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
                
        var data: WidgetDataModel = .init(
            location: "Getting your current location",
            backgroundImage: .placeholder("image.example"),
            weatherImage: .placeholder("image.weather")
        )
        
        let latitude: Double = UserDefaults.group?.double(forKey: UserDefaults.Key.GET_LATITUDE) ?? 0
        let longitude: Double = UserDefaults.group?.double(forKey: UserDefaults.Key.GET_LONGITUDE) ?? 0
        
        let dispatchGroup = DispatchGroup()
        
        // Background Image
        do {
            if let backgroundURL = try DatabaseFileManager.readFile(
                name: AppConfiguration.backgroundName
            ) {
                let backgroundData = try Data(contentsOf: backgroundURL)
                data.backgroundImage = .uiImage(backgroundData)
            }
        } catch {
            // Handle errors...
        }
        
        // Weather Data
        let provider: Request = WeatherProvider.fetchWeather(latitude: latitude, longitude: longitude)
        dispatchGroup.enter()
        NetworkClient()
            .request(OpenWeatherModel.self, provider: provider)
            .sink(receiveCompletion: { response in
                switch response {
                case .finished:
                    break
                case .failure:
                    data.location = "Location Not Found, Please try again later"
                }
            }, receiveValue: { value in
                data.location = value.location
                let iconName = value.weather?.last?.icon ?? ""

                if let url = URL(string: value.iconURL(iconName)) {
                    KingfisherManager
                        .shared
                        .downloader
                        .downloadImage(with: url, options: []) { result in
                            if case let .success(response) = result {
                                data.weatherImage = .uiImage(response.originalData)
                                dispatchGroup.leave()
                            }
                        }
                }
    
                
            })
            .store(in: &cancelBag)
    
        // Notify when all tasks are complete
        dispatchGroup.notify(queue: .main) {
            let entry = WidgetEntry(date: entryDate, data: data)
            let timeline = Timeline(entries: [entry], policy: .after(entryDate))
            completion(timeline)
          
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

}
