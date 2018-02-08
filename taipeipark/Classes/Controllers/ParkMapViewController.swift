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
    var isOpen: Bool
    var position: CLLocationCoordinate2D
    var name: String!
    
    init(position: CLLocationCoordinate2D, name: String, isOpen: Bool) {
        self.position = position
        self.name = name
        self.isOpen = isOpen
    }
}

class ParkMapViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate, MapInfoWindowDelegate {
    
    var polyline:GMSPolyline?
    private var groupedParkDatas:[String:[ParkData]]!
    var currentData: ParkData?
    
    var isFromPark: Bool = false
    var showFirstView: Bool = false
    
    var defaultCameraLatitude = 25.0486809
    var defaultCameraLongitude = 121.5669247
    
    let locationManager = CLLocationManager()
    
    var nowLat = CLLocationDegrees()
    var nowLong = CLLocationDegrees()
    
    var currentLat = CLLocationDegrees()
    var currentLong = CLLocationDegrees()
    
    private var mapView: GMSMapView!
    var clusterManager: GMUClusterManager!
    private var infoWindow = MapInfoWindow()
    
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    
    // MARK: lifCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "台北公園地圖"
        self.groupedParkDatas = ParkDataManager.sharedManager.getDefultParkData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getCurrentLocation()
        initCluster()
        upLoadView()
    }
    
    override func loadView() {
        var camera:GMSCameraPosition
        if isFromPark {
            camera = GMSCameraPosition.camera(withLatitude: currentLat,
                                              longitude: currentLong, zoom: 16)
        }
        else {
            camera = GMSCameraPosition.camera(withLatitude: defaultCameraLatitude,
                                              longitude: defaultCameraLongitude, zoom: 16)
        }
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        self.view = mapView
        infoWindow = loadNiB()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isFromPark = false
        showFirstView = false
        infoWindow.removeFromSuperview()
        mapView.clear()
    }
    
    // MARK: Action
    
    func onTouchFButton(name: String) {
        
    }
    
    func onTouchPathButton() {
        polyline?.map = nil
        drawPath(title: "", lat: currentLat, long: currentLong)
    }
    
    func onTouchGoogleButton() {
        openGoogleApp()
    }
    
    //  MARK: Google map.
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItem {
            // Needed to create the custom info window
            initInfoViewItem(marker: marker, poiItem: poiItem)
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
    
    // Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            if showFirstView {
                showFirstView = false
                addInfoView()
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        }
    }
    
    // Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    // Needed to create the custom info window
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    // MARK: function
    
    func initInfoViewItem(marker: GMSMarker,poiItem: POIItem) -> Bool {
        let data = self.groupedParkDatas[poiItem.name!]?[0]
        locationMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        
        infoWindow.titleInfo.text = poiItem.name!
        infoWindow.administrativeAreaLabel.text = data?.administrativeArea!
        
        if Utilities.checkIsOpenTime(openTime: (data?.openTime)!) {
            marker.icon = GMSMarker.markerImage(with: .red)
            infoWindow.openLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            infoWindow.closeLabel.textColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        }
        else {
            marker.icon = GMSMarker.markerImage(with: .blue)
            infoWindow.openLabel.textColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
            infoWindow.closeLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        }
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
        currentLat = locationMarker?.position.latitude as! CLLocationDegrees
        currentLong = locationMarker?.position.longitude as! CLLocationDegrees
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        infoWindow.delegate = self
        self.view.addSubview(infoWindow)
        return true
    }
    
    func sizeForOffset(view: UIView) -> CGFloat {
        return  135.0
    }
    
    // Needed to create the custom info window (this is optional)
    func loadNiB() -> MapInfoWindow{
        let infoWindow = MapInfoWindow.instanceFromNib() as! MapInfoWindow
        return infoWindow
    }
    
    // Cluster init
    func initCluster() {
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
    
    // cluster manager.
    private func generateClusterItems() {
        for key in self.groupedParkDatas!.keys {
            let data = self.groupedParkDatas[key]?[0]
            let lat = Double((data?.latitude as! NSString).doubleValue)
            let lng = Double((data?.longitude as! NSString).doubleValue)
            let name = key
            
            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name, isOpen: Utilities.checkIsOpenTime(openTime: (data?.openTime)!))
            clusterManager.add(item)
        }
    }
    
    func upLoadView() {
        var newCamera:GMSCameraPosition
        if isFromPark {
            showFirstView = true
            newCamera = GMSCameraPosition.camera(withLatitude: currentLat,
                                              longitude: currentLong, zoom: 16)
            //addInfoView()
        }
        else {
            if nowLong != 0 && nowLat != 0 {
                newCamera = GMSCameraPosition.camera(withLatitude: nowLat,
                                                  longitude: nowLong, zoom: 16)
            }
            else {
                newCamera = GMSCameraPosition.camera(withLatitude: defaultCameraLatitude,
                                                  longitude: defaultCameraLongitude, zoom: 16)
            }
        }
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
    }
    
    func addInfoView()  {
        infoWindow = loadNiB()
        infoWindow.titleInfo.text = currentData?.parkName
        infoWindow.administrativeAreaLabel.text = currentData?.administrativeArea!
        
        if Utilities.checkIsOpenTime(openTime: (currentData?.openTime)!) {
            infoWindow.openLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            infoWindow.closeLabel.textColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        }
        else {
            infoWindow.openLabel.textColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
            infoWindow.closeLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        }
        infoWindow.center = mapView.projection.point(for: CLLocationCoordinate2DMake(currentLat, currentLong))
        infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        infoWindow.delegate = self
        self.view.addSubview(infoWindow)
    }
    
    func getCurrentLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // Call the authorizationStatus() class
        locationManager.requestWhenInUseAuthorization()
        // get my current locations lat, lng
        if CLLocationManager.locationServicesEnabled() {
            let lat = locationManager.location?.coordinate.latitude
            let long = locationManager.location?.coordinate.longitude
            if let lattitude = lat  {
                if let longitude = long {
                    nowLat = lattitude
                    nowLong = longitude
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
    
    func drawPath(title: String, lat: CLLocationDegrees , long: CLLocationDegrees) {
        
        var origin = String()
        var destination = String()
        
        origin = "\(lat),\(long)"
        destination = "\(nowLat),\(nowLong)"
        
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
    
    func openGoogleApp() {
        var origin = String()
        var destination = String()
        origin = "\(currentLat),\(currentLong)"
        destination = "\(nowLat),\(nowLong)"
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
}
