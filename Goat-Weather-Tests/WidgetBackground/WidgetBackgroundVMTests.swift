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

import XCTest
import Combine
@testable import Goat_Weather

class WidgetBackgroundVMTests: XCTestCase {

    var viewModel: WidgetBackgroundVMProtocol!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        viewModel = BackgroundViewModelTestable(isSuccess: true)
    }

    func testCurrentLocation() throws {
        let expectation = self.expectation(description: "Fetch Current Locartion Success")
        viewModel.requestLocationUsage()
        
        var latitude: Double?
        var longitude: Double?
       
        viewModel.currentLocation
            .sink { value in
                
                latitude = value.0
                longitude = value.1
                expectation.fulfill()

            }.store(in: &cancellables)
        
        

        waitForExpectations(timeout: 10)
        XCTAssertNotNil(latitude)
        XCTAssertNotNil(longitude)
        
    }
    
    func testCurrentSelectedBackground() throws {
        let expectation = self.expectation(description: "Fetch Selected Background Success")
        viewModel.fetchBackgroundFromLocal()
        
        var url: URL?
        
       
        viewModel.viewBackground
            .sink { value in
                
                url = value
                expectation.fulfill()

            }.store(in: &cancellables)
        
        

        waitForExpectations(timeout: 10)
        XCTAssertNotNil(url)
        
    }
    
    /// For another test ,...... ETC...
}


private class BackgroundViewModelTestable: WidgetBackgroundVMProtocol {
    
    var isSuccess: Bool = false
    
    var networkClient: NetworkClientInterface
    
    var photoPermission: PhotoLibraryPermission
    
    var locationPermission: LocationPermission
    
    var viewBackground: CurrentValueSubject<URL?, Never> = .init(nil)
    var viewWidgets: CurrentValueSubject<[WidgetSize], Never> = .init([.iPhoneSmall, .iPhoneMedium, .iPhoneLarge])
    var viewWeatherIconURL: CurrentValueSubject<String?, Never> = .init(nil)
    var viewLocation: CurrentValueSubject<String?, Never> = .init(nil)
    var currentState: CurrentValueSubject<ViewState, Never> = .init(.initial)
    var currentLocation: CurrentValueSubject<(Double, Double), Never> = .init((0,0))
    private var cancelBag = Set<AnyCancellable>()

    init(
        isSuccess: Bool,
        photoPermission: PhotoLibraryPermission = PhotoLibraryPermission(),
        locationPermission: LocationPermission = LocationPermission()
    ) {
        self.networkClient = NetworkClientTestable(isSuccess: isSuccess)
        self.photoPermission = photoPermission
        self.locationPermission = locationPermission
    }
    
    func fetchInitial() {
        requestLocationUsage()
        fetchBackgroundFromLocal()
    }
    
    func fetchWeather() {
        let latitude = currentLocation.value.0
        let longitude = currentLocation.value.1
        networkClient
            .request(OpenWeatherModel.self,
                     provider: WeatherProvider.fetchWeather(latitude: latitude,
                                                            longitude: longitude))
            .sink { [weak self] result in
                if case let .failure(errorData) = result {
                    self?.currentState.send(.error(errorData.errorDescription))
                }
            } receiveValue: { [weak self] value in
                self?.viewLocation.send(value.location)
                
                let name = value.weather?.last?.icon ?? ""
                self?.viewWeatherIconURL.send(value.iconURL(name))
            }.store(in: &cancelBag)
    }
    
    func fetchBackgroundFromLocal() {
        do {
            let imageURL = try DatabaseFileManager.readFile(name: AppConfiguration.backgroundName)
            viewBackground.send(imageURL)
        } catch {
            currentState.send(.error("NO IMAGE FILE"))
        }
    }
    
    func requestPhotoLibrary(_ statusBlock: @escaping ((Bool) -> Void)) {
        statusBlock(isSuccess)
    }
    
    func requestLocationUsage() {
        if isSuccess {
            currentLocation = .init(
                (35.6669247, 139.6420703)
            )
            fetchWeather()
        }
    }
    
    func changeBackground(_ imageData: Data) {
        
    }
}
