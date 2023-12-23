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

public protocol NetworkServiceInterface {
    func load(_ request: Request) -> AnyPublisher<Data, NetworkError>
}

public struct NetworkService: NetworkServiceInterface {
    var session: URLSession

    public init(session: URLSession) {
        self.session = session
    }
    
    public func load(_ request: Request) -> AnyPublisher<Data, NetworkError> {
        do {
            let request = try request.build()
            return session
                .dataTaskPublisher(for: request )
                .tryMap({ result in
                    try handleResponse(data: result.data, response: result.response)
                })
                .mapError { resolve(error: $0) }
                .eraseToAnyPublisher()
        } catch  {
            return Fail.init(error: NetworkError.Unknown).eraseToAnyPublisher()
        }
    }
    
    private func handleResponse(data: Data, response: URLResponse) throws -> Data {
        if let response = response as? HTTPURLResponse {
            if (200...299).contains(response.statusCode) {
                return data
            } else if response.statusCode == 400 {
                throw NetworkError.BadRequest(response.url?.absoluteString ?? "")
            } else if response.statusCode == 500 {
                throw NetworkError.ServerError
            } else {
                throw NetworkError.Custom(message: "error", code: response.statusCode)
            }
        } else {
            throw NetworkError.Unknown
        }
    }
    
    private func resolve(error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        } else {
            let code = URLError.Code(rawValue: (error as NSError).code)
            switch code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .Offline
            case .badServerResponse:
                return .BadRequest(error.localizedDescription)
            default:
                return .Custom(message: error.localizedDescription, code: code.rawValue)
            }
        }
    }
}
