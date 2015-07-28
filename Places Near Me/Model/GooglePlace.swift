//
//  GooglePlace.swift
//  Places Near Me
//
//  Created by Kyle Dinh on 7/1/15.
//  Copyright (c) 2015 Kyle Dinh. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class GooglePlace {
    
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let placeType: String
    var isNearest: Bool
    
    init(dictionary:NSDictionary, acceptedType: String)
    {
        name = dictionary["name"] as! String
        address = dictionary["vicinity"] as! String
        
        let location = dictionary["geometry"]?["location"] as! NSDictionary
        let lat = location["lat"] as! CLLocationDegrees
        let lng = location["lng"] as! CLLocationDegrees
        coordinate = CLLocationCoordinate2DMake(lat, lng)
        
        var foundType = "atm"
        for type in dictionary["types"] as! [String] {
            if type == acceptedType {
                foundType = type
                break
            }
        }
        placeType = foundType
        isNearest = false
    }
}
