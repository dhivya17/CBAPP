//
//  BikeView.swift
//  CityBikesApp
//
//  Created by venkatesh on 11/12/17.
//  Copyright © 2017 venkatesh. All rights reserved.
//

import UIKit
import MapKit

class BikeView: MKMarkerAnnotationView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override var annotation: MKAnnotation? {
        willSet {
            if (newValue as? Bike) != nil {
                clusteringIdentifier = "bike"
                glyphImage = UIImage(named: "bike")
                displayPriority = .defaultLow
            }
        }
    }

}
