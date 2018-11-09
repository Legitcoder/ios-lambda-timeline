//
//  Post+Mapping.swift
//  LambdaTimeline
//
//  Created by Moin Uddin on 11/8/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import MapKit

extension Post: MKAnnotation {
    
    
    var coordinate: CLLocationCoordinate2D {
        guard let geotag = geotag else { return kCLLocationCoordinate2DInvalid }
        return geotag
    }
    
    var subtitle: String? {
        return author.displayName
    }
    
}
