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
import MapKit

public final class LocationPermission: NSObject {
    
    static var shared: LocationPermission?
    
    lazy var locationManager: CLLocationManager =  {
        return CLLocationManager()
    }()
    
    var completionHandler: PermissionAuthorizationHandlerCompletionBlock?
    
    override init() {
        super.init()
    }
    
    private var whenInUseNotRealChangeStatus: Bool = false
    
    private func requestPermission(
        _ completionHandler: @escaping PermissionAuthorizationHandlerCompletionBlock
    ) {
        self.completionHandler = completionHandler
        
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            break
        case .authorizedWhenInUse:
            self.whenInUseNotRealChangeStatus = true
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        case .authorizedAlways:
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            break
        default:
            completionHandler(self.isAuthorized)
        }
    }
    
    /// GET LATITUDE, LONGITUDE in Double
    public var coordinate: (Double?, Double?) {
        let location = CLLocationManager().location
        return (location?.coordinate.latitude, location?.coordinate.longitude)
    }
    
    public var isAuthorized: Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways {
            return true
        }
        return false
    }
    
    func request(_ completion: ((Bool) -> Void)? = nil) {
        if LocationPermission.shared == nil {
            LocationPermission.shared = LocationPermission()
        }
        
        guard let shared = LocationPermission.shared else {
            return
        }
        
        shared.requestPermission { (authorized) in
            DispatchQueue.main.async {
                completion?(authorized)
                LocationPermission.shared = nil
            }
        }
    }
    
    deinit {
        locationManager.delegate = nil
    }
}

extension LocationPermission {
    typealias PermissionAuthorizationHandlerCompletionBlock = (Bool) -> Void
}

extension LocationPermission: CLLocationManagerDelegate {
    public func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        
        
    }
    
    @available(iOS 14.0, *)
    public func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        if whenInUseNotRealChangeStatus {
            if manager.authorizationStatus == .authorizedWhenInUse {
                return
            }
        }
        
        if manager.authorizationStatus == .notDetermined {
            return
        }

        if let completionHandler = completionHandler {
            completionHandler(self.isAuthorized)
        }
    }
    
}
