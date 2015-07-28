//
//  GoogleDataProvider.swift
//  Places Near Me
//
//  Created by Kyle Dinh on 7/1/15.
//  Copyright (c) 2015 Kyle Dinh. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class GoogleDataProvider {
    
    let apiKey = "AIzaSyATQToLhRWQ1t8xjDmLTafjbTzd30w1kAs"
    var photoCache = [String:UIImage]()
    var placesTask = NSURLSessionDataTask()
    var session: NSURLSession {
        return NSURLSession.sharedSession()
    }
    
    func fetchPlacesNearCoordinate(coordinate: CLLocationCoordinate2D, type:String, completion: (([GooglePlace], String?) -> Void)) -> ()
    {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiKey)&location=\(coordinate.latitude),\(coordinate.longitude)&rankby=distance&sensor=true"
        urlString += "&types=\(type)"
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
            placesTask.cancel()
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var placesArray = [GooglePlace]()
            var nextPageToken : String?
            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary {
                println(json)
                nextPageToken = json["next_page_token"] as? String
                if let results = json["results"] as? NSArray {
                    for rawPlace:AnyObject in results {
                        let place = GooglePlace(dictionary: rawPlace as! NSDictionary, acceptedType: type)
                        placesArray.append(place)
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(placesArray, nextPageToken)
            }
        }
        placesTask.resume()
    }
    
    func fetchNextPage(token: String, type:String, completion: (([GooglePlace] , String!) -> Void)) -> ()
    {
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(apiKey)&pagetoken=\(token)"
        urlString = urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        if placesTask.taskIdentifier > 0 && placesTask.state == .Running {
            placesTask.cancel()
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        placesTask = session.dataTaskWithURL(NSURL(string: urlString)!) {data, response, error in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            var placesArray = [GooglePlace]()
            var nextPageToken : String!
            if let json = NSJSONSerialization.JSONObjectWithData(data, options:nil, error:nil) as? NSDictionary {
                println(json)
                if json["next_page_token"] != nil {
                    nextPageToken = json["next_page_token"] as! String
                }
                if let results = json["results"] as? NSArray {
                    for rawPlace:AnyObject in results {
                        let place = GooglePlace(dictionary: rawPlace as! NSDictionary, acceptedType: type)
                        placesArray.append(place)
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue()) {
                completion(placesArray, nextPageToken)
            }
        }
        placesTask.resume()
    }
    
}