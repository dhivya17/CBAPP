//
//  Bike.swift
//  CityBikesApp
//
//  Created by venkatesh on 11/12/17.
//  Copyright © 2017 venkatesh. All rights reserved.
//

import UIKit
import MapKit

class Bike: MKPointAnnotation {
    
    class func bikes(fromDictionaries dictionaries: [[String: AnyObject]]) -> [Bike] {
        let bikes = dictionaries.map { item -> Bike in
            let bike = Bike()
            let latitude = item["latitude"] as! NSNumber
            let longitude = item["longitude"] as! NSNumber
            bike.coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue)
            bike.title = NSString(format:"%@",item["name"] as! String) as String
            // bike.title = String(describing: item["name"] as? String)
            // bike.subtitle = "Empty slots:\( item["empty_slots"] as! NSNumber)"
            return bike
        }
       return bikes
    }
}
