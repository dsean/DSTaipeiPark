//
//  ParkListViewController.swift
//  taipeipark
//
//  Created by 楊德忻 on 2018/2/6.
//  Copyright © 2018年 sean. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON
import GoogleMaps
import GooglePlaces

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}

let kCameraLatitude = 25.0486809;
let kCameraLongitude = 121.5669247;

let locationManager = CLLocationManager()

var latValue = CLLocationDegrees()
var longValue = CLLocationDegrees()

var lat = CLLocationDegrees()
var long = CLLocationDegrees()

class ParkMapViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate, MapInfoWindowDelegate {
    
    var polyline:GMSPolyline?
    private var groupedParkDatas:[String:[ParkData]]!
    
    func onTouchFButton(name: String) {
        
    }
    
    func onTouchPathButton() {
        polyline?.map = nil
         drawPath(title: "", lat: lat, long: long)
    }
    
    func onTouchGoogleButton() {
        var origin = String()
        var destination = String()
        origin = "\(lat),\(long)"
        destination = "\(latValue),\(longValue)"
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
    
    private var mapView: GMSMapView!
    var clusterManager: GMUClusterManager!
    private var infoWindow = MapInfoWindow()
    
    // MARK: Needed to create the custom info window
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: kCameraLatitude,
                                              longitude: kCameraLongitude, zoom: 14)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        self.view = mapView
        infoWindow = loadNiB()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.groupedParkDatas = ParkDataManager.sharedManager.getDefultParkData()
        
        getCurrentLocation()
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        
        // Generate and add random items to the cluster manager.
        generateClusterItems()
        
        // Call cluster() after items have been added to perform the clustering and rendering on map.
        clusterManager.cluster()
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            NSLog("Did tap marker for cluster item \(poiItem.name)")
            // Needed to create the custom info window
            locationMarker = marker
            infoWindow.removeFromSuperview()
            infoWindow = loadNiB()
            let data = self.groupedParkDatas[poiItem.name!]?[0]
            infoWindow.titleInfo.text = poiItem.name!
            infoWindow.administrativeAreaLabel.text = data?.administrativeArea!
            infoWindow.openTimeLabel.text = data?.openTime
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return false
            }
            lat = locationMarker?.position.latitude as! CLLocationDegrees
            long = locationMarker?.position.longitude as! CLLocationDegrees
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
            infoWindow.delegate = self
            self.view.addSubview(infoWindow)
        }
        else {
            infoWindow.removeFromSuperview()
            let newCamera = GMSCameraPosition.camera(withTarget: marker.position,
                                                     zoom: mapView.camera.zoom + 1)
            let update = GMSCameraUpdate.setCamera(newCamera)
            mapView.moveCamera(update)
        }
        
        return false
    }
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        }
    }
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    
    // MARK: Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    // MARK: Needed to create the custom info window (this is optional)
    func sizeForOffset(view: UIView) -> CGFloat {
        return  135.0
    }
    
    // MARK: Needed to create the custom info window (this is optional)
    func loadNiB() -> MapInfoWindow{
        let infoWindow = MapInfoWindow.instanceFromNib() as! MapInfoWindow
        return infoWindow
    }
    
    // cluster manager.
    private func generateClusterItems() {
        for key in self.groupedParkDatas!.keys {
            let data = self.groupedParkDatas[key]?[0]
            let lat = Double((data?.latitude as! NSString).doubleValue)
            let lng = Double((data?.longitude as! NSString).doubleValue)
            let name = key
            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name)
            clusterManager.add(item)
        }
    }
    
    func drawPath(title: String, lat: CLLocationDegrees , long: CLLocationDegrees) {
        
        var origin = String()
        var destination = String()
        
        origin = "\(lat),\(long)"
        destination = "\(latValue),\(longValue)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving"
        origin = "\(lat),\(long)"
        Alamofire.request(url).responseJSON { response in
            
            let json = JSON(response.data!)
            let routes = json["routes"].arrayValue
            
            for route in routes {
                self.polyline?.map = nil
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                self.polyline = GMSPolyline.init(path: path)
                self.polyline!.strokeWidth = 4
                self.polyline!.strokeColor = UIColor.red
                self.polyline!.map = self.mapView
            }
            
        }
    }
    
    func getCurrentLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization() // Call the authorizationStatus() class
        
        if CLLocationManager.locationServicesEnabled() { // get my current locations lat, lng
            let lat = locationManager.location?.coordinate.latitude
            let long = locationManager.location?.coordinate.longitude
            if let lattitude = lat  {
                if let longitude = long {
                    latValue = lattitude
                    longValue = longitude
                }
            }
            else {
                print("problem to find lat and lng")
            }
        }
        else {
            print("Location Service not Enabled. Plz enable u'r location services")
        }
    }
}

