//
//  MapViewController.swift
//  Places Near Me
//
//  Created by Kyle Dinh on 6/24/15.
//  Copyright (c) 2015 Kyle Dinh. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var mapView: GMSMapView!
    var searchType: String!
    var storePopupVC : StorePopupViewController!
    
    let locationManager = CLLocationManager()
    let dataProvider = GoogleDataProvider()
    
    var totalBound : GMSCoordinateBounds!
    
    var startAppAd: STAStartAppAd?
    var startAppBanner: STABannerView?
    let adsRemoved = NSUserDefaults.standardUserDefaults().boolForKey("adsRemoved")
    var token : String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.myLocationEnabled = true
        if let location : CLLocation = locationManager.location {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            self.fetchNearbyPlaces(location.coordinate)
        }
        
        startAppAd = STAStartAppAd()
        
//        if (!adsRemoved) {
            if startAppBanner == nil {
                startAppBanner = STABannerView(size: STA_AutoAdSize, autoOrigin: STAAdOrigin_Bottom, withView: self.view, withDelegate: nil);
                self.view.addSubview(startAppBanner!)
            }
//        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        startAppAd!.loadAd()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
        let placeMarker = marker as! PlaceMarker
        
        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
            infoView.nameLabel.text = placeMarker.place.name
            infoView.placeAddress.text = placeMarker.place.address
            
            if placeMarker.place.isNearest {
                infoView.nearestSign.hidden = false
            }
            
            return infoView
        } else {
            return nil
        }
    }
    
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        dataProvider.fetchPlacesNearCoordinate(coordinate, type: searchType) { places, nextPageToken in
            for (index, place: GooglePlace) in enumerate(places) {
                if (index == 0) {
                    self.totalBound = GMSCoordinateBounds(region: self.mapView.projection.visibleRegion())
                    self.totalBound.includingCoordinate(coordinate)
                    if (!self.mapView.projection.containsCoordinate(place.coordinate)) {
                        let coordicateBound = GMSCoordinateBounds(region: self.mapView.projection.visibleRegion())
                        coordicateBound.includingCoordinate(place.coordinate)
                        self.mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(coordicateBound, withPadding: 130))
                    }
                    place.isNearest = true
                }
                self.totalBound.includingCoordinate(place.coordinate)
                let marker = PlaceMarker(place: place)
                marker.map = self.mapView
                if index == 0 {
                    self.mapView.selectedMarker = marker
                }
            }
            if nextPageToken != nil {
                self.token = nextPageToken
            }
            else {
                self.token = nil
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            
            if let location : CLLocation = locationManager.location {
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                self.fetchNearbyPlaces(location.coordinate)
            }
        }
    }
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            self.fetchNearbyPlaces(location.coordinate)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        if self.totalBound == nil || self.token == nil {
            return
        }
        let northWest = CLLocationCoordinate2DMake(self.totalBound.northEast.latitude, self.totalBound.southWest.longitude)
        let southEast = CLLocationCoordinate2DMake(self.totalBound.southWest.latitude, self.totalBound.northEast.longitude)
        let checkNorthWest = mapView.projection.containsCoordinate(northWest)
        let checkSouthEast = mapView.projection.containsCoordinate(southEast)
        let checkSouthWest = mapView.projection.containsCoordinate(self.totalBound.southWest)
        let checkNorthEast = mapView.projection.containsCoordinate(self.totalBound.northEast)
        
        if checkNorthWest || checkSouthEast || checkSouthWest || checkNorthEast {
            println("fetch next page")
            dataProvider.fetchNextPage(self.token, type: searchType) { places, nextPageToken in
                for (index, place: GooglePlace) in enumerate(places) {
                    self.totalBound.includingCoordinate(place.coordinate)
                    let marker = PlaceMarker(place: place)
                    marker.map = self.mapView
                }
                if nextPageToken != nil {
                    self.token = nextPageToken
                }
                else {
                    self.token = nil
                }
            }
        }
    }

    @IBAction func homeButtonPressed(sender: UIButton) {
        startAppAd!.showAd()
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func showStorePopup(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        storePopupVC = storyboard.instantiateViewControllerWithIdentifier("storePopupViewController") as! StorePopupViewController
        storePopupVC.showInView(self.view, animated: false)
    }
}
