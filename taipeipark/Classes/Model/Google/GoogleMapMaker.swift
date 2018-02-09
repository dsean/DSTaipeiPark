//
//  GoogleMap.swift
//  taipeipark
//
//  Created by 楊德忻 on 2018/2/9.
//  Copyright © 2018年 sean. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON
import GoogleMaps
import GooglePlaces

class GoogleMapMaker: NSObject {
    
    let locationManager = CLLocationManager()
    var locationMarker : GMSMarker? = GMSMarker()
    var mapView: GMSMapView!
    var clusterManager: GMUClusterManager!
    
    func loadView() -> GMSMapView {
        var camera:GMSCameraPosition
        camera = GMSCameraPosition.camera(withLatitude: 0,
                                          longitude: 0, zoom: 16)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        return mapView
    }
    
    func getCurrentLocation() -> [String: Double]? {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // Call the authorizationStatus() class
        locationManager.requestWhenInUseAuthorization()
        // get my current locations lat, lng
        if CLLocationManager.locationServicesEnabled() {
            let lat = locationManager.location?.coordinate.latitude
            let long = locationManager.location?.coordinate.longitude
            if let lattitude = lat  {
                if let longitude = long {
                    return ["lat":lattitude, "long":longitude]
                }
            }
            else {
                return nil
            }
        }
        else {
            print("Location Service not Enabled. Plz enable u'r location services")
            return nil
        }
        return nil
    }
    
    // Cluster init
    func initCluster() -> GMUClusterManager? {
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        if mapView == nil {
            return nil
        }
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        return clusterManager
    }
    
    func generateClusterItems(datas: [String:[ParkData]]!) -> Bool {
        if datas != nil {
            for key in datas.keys {
                let data = datas[key]?[0]
                let lat = Double(data!.latitude!)!
                let lng = Double(data!.longitude)!
                let name = key
                
                let item = POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name, isOpen: Utilities.checkIsOpenTime(openTime: (data?.openTime)!))
                clusterManager.add(item)
            }
        }
        else {
            return false
        }
        return true
    }
    
    func openGoogleApp(origin: String,destination: String) {
        let url = "comgooglemaps://?saddr=\(origin)&daddr=\(destination)&directionsmode=driving"
        if (UIApplication.shared.canOpenURL(URL(string:url)!)) {
            // Open Google map.
            UIApplication.shared.openURL(URL(string:url)!)
        }
        else {
            // Go to itunes.
            UIApplication.shared.openURL((URL(string:
                "itms-apps://itunes.apple.com/tw/app/google-maps/id585027354?l=zh&mt=8")!))
        }
    }
    
    func drawPath(origin: String, destination: String, callback: @escaping (_ routes: [JSON]) -> Void) {
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        Alamofire.request(url).responseJSON { response in
            
            let json = JSON(response.data!)
            let routes = json["routes"].arrayValue
            callback (routes)
        }
    }
}
