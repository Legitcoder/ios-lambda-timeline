//
//  LocationManagerHelper.swift
//  LambdaTimeline
//
//  Created by Moin Uddin on 11/8/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManagerHelper: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() -> CLLocation? {
        return locationManager.location
    }
    
}
