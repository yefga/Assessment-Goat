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


let mock: String = """
{
    "coord": {
        "lon": 139.6421,
        "lat": 35.6669
    },
    "weather": [
        {
            "id": 801,
            "main": "Clouds",
            "description": "few clouds",
            "icon": "02n"
        }
    ],
    "base": "stations",
    "main": {
        "temp": 280.74,
        "feels_like": 280,
        "temp_min": 278.99,
        "temp_max": 281.88,
        "pressure": 1027,
        "humidity": 42
    },
    "visibility": 10000,
    "wind": {
        "speed": 1.54,
        "deg": 0
    },
    "clouds": {
        "all": 20
    },
    "dt": 1703321730,
    "sys": {
        "type": 2,
        "id": 2033467,
        "country": "JP",
        "sunrise": 1703281675,
        "sunset": 1703316734
    },
    "timezone": 32400,
    "id": 1862143,
    "name": "Horinouchi",
    "cod": 200
}
"""

let data = mock.data(using: .utf8)

class NetworkServiceTestable: NetworkServiceInterface {
    var isSuccess: Bool = false
    
    init(isSuccess: Bool) {
        self.isSuccess = isSuccess
    }

    func load(_ request: Goat_Weather.Request) -> AnyPublisher<Data, Goat_Weather.NetworkError> {
        if isSuccess {
            Result.Publisher(
                mock.data(using: .utf8) ?? Data()
            ).eraseToAnyPublisher()
        } else {
            Result.Publisher(
                NetworkError.Custom(message: "FAILURE", code: 0)
            ).eraseToAnyPublisher()
        }
        
    }
}
