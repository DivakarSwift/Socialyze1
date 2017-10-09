//
//  LocationManager.swift
//  veda
//
//  Created by bibek on 1/21/17.
//  Copyright © 2017 Salem Khan. All rights reserved.
//

import CoreLocation
import UIKit

protocol SlydeLocationManagerDelegate: class {
    func locationPermissionChanged()
    func locationObtained()
    func locationObtainError()
}

class SlydeLocationManager: NSObject {
    static let shared: SlydeLocationManager = SlydeLocationManager()
    
    let manager = CLLocationManager()
    weak var delegate: SlydeLocationManagerDelegate?
    
    fileprivate var location: CLLocation? = CLLocation(latitude: 39.992359, longitude: -83.006797)
    fileprivate var shouldGetLocationContiniously = false
    
    private override init() {
        super.init()
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.delegate = self
        self.manager.requestWhenInUseAuthorization()
    }
    
    func getLocation() ->  CLLocation? {
        return self.location
    }
    
    func distanceFromUser(lat: Double, long: Double) -> Double? {
        let location = CLLocation(latitude: lat, longitude: long)
        //        self.location = CLLocation(latitude: 39.956332, longitude: -83.004056)
        if let userLocation = self.location {
            return location.distance(from: userLocation)
        }else {
            return nil
        }
    }
    
    func requestLocation() {
        if isDenied {
            GlobalConstants.Notification.locationAuthorizationStatusChanged.fire()
            return
        }
        if #available(iOS 9.0, *) {
            manager.requestLocation()
        } else {
            manager.startUpdatingLocation()
        }
    }
    
    func startUpdatingLocation() {
        if isDenied {
            GlobalConstants.Notification.locationAuthorizationStatusChanged.fire()
            return
        }
        print("manager started")
        self.shouldGetLocationContiniously = true
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        self.shouldGetLocationContiniously = false
        manager.stopUpdatingLocation()
    }
    
    var isAuthorized: Bool {
        return [.authorizedWhenInUse, .authorizedAlways].contains(CLLocationManager.authorizationStatus())
    }
    
    var isNotDetermined: Bool {
        return CLLocationManager.authorizationStatus() == .notDetermined
    }
    
    var isDenied: Bool {
        return [.denied, .restricted].contains(CLLocationManager.authorizationStatus())
    }
}

extension SlydeLocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updated location is: \(String(describing: location))")
        if !self.shouldGetLocationContiniously {
            self.stopUpdatingLocation()
        }
         self.location = locations.last
        
        if let _ = self.location?.coordinate {
            GlobalConstants.Notification.newLocationObtained.fire()
            self.delegate?.locationObtained()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error updating location: \(error.localizedDescription)")
        if isNotDetermined || isDenied {
            return
        }
        GlobalConstants.Notification.locationUpdateError.fire()
        self.delegate?.locationObtainError()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if isNotDetermined {
            return
        }
        GlobalConstants.Notification.locationAuthorizationStatusChanged.fire()
        self.delegate?.locationPermissionChanged()
    }
}
