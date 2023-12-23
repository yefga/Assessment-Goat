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

import Foundation

// MARK: - OpenWeatherAPI Model
struct OpenWeatherModel: Codable, Equatable {
    let message: String?
    let coord: CoordModel?
    let weather: [WeatherModel]?
    let sys: SysModel?
    let name: String?
    
    var location: String {
        let city = name ?? ""
        let country = self.sys?.country ?? ""
        let location = "\(city.capitalized), \(country.uppercased())"
        return location
    }
    
    func iconURL(_ name: String) -> String {
        return "https://openweathermap.org/img/wn/\(name)@2x.png"
    }

}

// MARK: - CoordModel
struct CoordModel: Codable, Equatable {
    let lon, lat: Double?
}

// MARK: - Weather
struct WeatherModel: Codable, Equatable {
    let id: Int?
    let main, icon: String?
}

struct SysModel: Codable, Equatable {
    let country: String?
}

enum WidgetSize: CGFloat {
    case iPhoneSmall = 24.0
    case iPhoneMedium = 26.0
    case iPhoneLarge = 32.0
}

struct WidgetModel: Equatable {
    var size: WidgetSize
    var weatherIcon: String?
    var location: String?
    
    
    static var mock: [Self] {
        [
            .init(size: .iPhoneSmall),
            .init(size: .iPhoneMedium),
            .init(size: .iPhoneLarge)
        ]
    }
}
