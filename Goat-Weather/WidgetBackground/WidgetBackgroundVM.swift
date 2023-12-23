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
import Combine

protocol WidgetBackgroundVMProtocol {
    var networkClient: NetworkClientInterface { get }
    var photoPermission: PhotoLibraryPermission { get }
    var locationPermission: LocationPermission { get }
    
    var viewBackground: CurrentValueSubject<URL?, Never> { get }
    var viewWidgets: CurrentValueSubject<[WidgetSize], Never> { get }
    var viewWeatherIconURL: CurrentValueSubject<String?, Never> { get }
    var viewLocation: CurrentValueSubject<String?, Never> { get }
    var currentState: CurrentValueSubject<ViewState, Never> { get }
    var currentLocation: CurrentValueSubject<(Double, Double), Never> { get }
    
    func fetchInitial()
    func fetchWeather()
    func fetchBackgroundFromLocal()
    func requestPhotoLibrary(_ statusBlock: @escaping ((Bool) -> Void))
    func requestLocationUsage()
    func changeBackground(_ imageData: Data)
}

enum ViewState: Equatable {
    case loading
    case error(String?)
    case success
    case initial
}

final class WidgetBackgroundVM: WidgetBackgroundVMProtocol {
    
    
    var photoPermission: PhotoLibraryPermission
    var locationPermission: LocationPermission
    var networkClient: NetworkClientInterface
    
    init(
        photoPermission: PhotoLibraryPermission = .init(),
        locationPermission: LocationPermission = .init(),
        networkClient: NetworkClientInterface = NetworkClient()
    ) {
        self.photoPermission = photoPermission
        self.locationPermission = locationPermission
        self.networkClient = networkClient
    }
    
    var viewBackground: CurrentValueSubject<URL?, Never> = .init(nil)
    var viewWidgets: CurrentValueSubject<[WidgetSize], Never> = .init([
        .iPhoneSmall, .iPhoneMedium, .iPhoneLarge
    ])
    var viewWeatherIconURL: CurrentValueSubject<String?, Never> = .init(nil)
    var viewLocation: CurrentValueSubject<String?, Never> = .init(nil)
    var currentState: CurrentValueSubject<ViewState, Never> = .init(.initial)
    var currentLocation: CurrentValueSubject<(Double, Double), Never> = .init((0, 0))
    
    private var cancelBag = Set<AnyCancellable>()
    
    func fetchInitial() {
        requestLocationUsage()
        fetchBackgroundFromLocal()
    }
    
    func fetchWeather() {
        networkClient.request(OpenWeatherModel.self,
                              provider: WeatherProvider.fetchWeather(latitude: currentLocation.value.0,
                                                                     longitude: currentLocation.value.1))
            .sink { [weak self] error in
                switch error {
                case .failure(let error):
                    self?.currentState.send(.error(error.errorDescription))
                    
                case .finished:
                    break
                }
            } receiveValue: { [weak self] value in
                self?.viewLocation.send(value.location)
                
                let iconName = value.weather?.last?.icon ?? ""
                let iconURL = value.iconURL(iconName)
                self?.viewWeatherIconURL.send(iconURL)
            }.store(in: &cancelBag)
    }
    
    func fetchBackgroundFromLocal() {
        do {
            if let urlPath = try DatabaseFileManager.readFile(name: AppConfiguration.backgroundName) {
                viewBackground.send(urlPath)
            } else {
                currentState.send(.error(DatabaseFileManagerError.cannotFound.description))
            }
        } catch {
            currentState.send(.error(error.asErrorFileManager.description))
        }
    }
    
    func requestPhotoLibrary(_ statusBlock: @escaping ((Bool) -> Void)) {
        photoPermission.request { status in
            statusBlock(status)
        }
    }
    
    func requestLocationUsage() {
        locationPermission.request { [weak self] status in
            if status {
                let latitude = self?.locationPermission.locationManager.location?.coordinate.latitude ?? 0.0
                let longitude = self?.locationPermission.locationManager.location?.coordinate.longitude ?? 0.0

                if latitude != 0.0 {
                    UserDefaults.group?.set(latitude, forKey: UserDefaults.Key.GET_LATITUDE)
                }
                if longitude != 0.0 {
                    UserDefaults.group?.set(longitude, forKey: UserDefaults.Key.GET_LONGITUDE)
                }
                self?.currentLocation.send((latitude, longitude))

                self?.fetchWeather()
            } else {
                self?.currentState.send(.error("Your location is unauthorized, Please turn on your location access to get weather updated"))
            }
        }
    }
    
    func changeBackground(_ imageData: Data) {
        do {
            try DatabaseFileManager.writeFile(name: AppConfiguration.backgroundName, data: imageData)
        } catch {
            currentState.send(.error(error.asErrorFileManager.description))
        }
    }
}


