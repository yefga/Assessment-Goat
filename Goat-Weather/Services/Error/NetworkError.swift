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

public extension Error {
    var asErrorNetworkService: NetworkError {
        self as? NetworkError ?? .Unknown
    }
    
    var asErrorFileManager: DatabaseFileManagerError {
        self as? DatabaseFileManagerError ?? .unknown
    }
}

public enum NetworkError: Error {
    case ServerError
    case BadRequest(String)
    case URLFailure
    case Decoding(Error)
    case Offline
    case Custom(message: String, code: Int)
    case Unknown
    
}

extension NetworkError: LocalizedError {
    /**
         Returns a localized description of the error, depending on the case.
         */
    public var errorDescription: String? {
        switch self {
        case .Unknown:
            return "An unknown error occurred."
        case let .Custom(message, status):
            return "\(status), \(message)"
        case .BadRequest(let parameters): // 400
            return "Request is invalid. \(parameters)"
        case .ServerError: // 500
            return "Server encountered a problem.\nPlease try again in a moment!"
        case .Offline: // 1009
            return "Your Internet connection is offline.\nPlease check your network status."
        case .URLFailure:
            return "URL not valid"
        case .Decoding(let error):
            return "Failed to Decoding \(error)"
        }
    }
}
