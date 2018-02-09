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
    var locationPosition: CLLocationCoordinate2D?
    
    var nowLat = CLLocationDegrees()
    var nowLong = CLLocationDegrees()
    
    var currentLat = CLLocationDegrees()
    var currentLong = CLLocationDegrees()
    
    private var mapView: GMSMapView!
    var clusterManager: GMUClusterManager!
    private var infoWindow = MapInfoWindow()
    
    fileprivate var locationMarker : GMSMarker? = GMSMarker()
    
    // GoogleMap
    let googleMapMaker :GoogleMapMaker? = GoogleMapMaker.init()
    
    // MARK: lifCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "台北公園地圖"
        self.groupedParkDatas = ParkDataManager.sharedManager.getDefultParkData()
    }
    
    override func loadView() {
        mapView = googleMapMaker?.loadView()
        self.view = mapView
        infoWindow = loadNiB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showFirstView = true
        getCurrentLocation()
        initCluster()
        upLoadView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isFromPark = false
        showFirstView = false
        infoWindow.removeFromSuperview()
        mapView.clear()
    }
    
    // MARK: Action
    func onTouchPathButton() {
        polyline?.map = nil
        drawPath(lat: currentLat, long: currentLong)
    }
    
    func onTouchGoogleButton() {
        openGoogleApp()
    }
    
    //  MARK: Google map.
    
    // Did tap marker.
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
    
    // DidChange position
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if (locationMarker != nil){
            guard let location = locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            if showFirstView {
                showFirstView = false
                if currentData != nil {
                    addInfoView()
                }
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        }
    }
    
    // Did tap map
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    // MARK: function
    
    func initInfoViewItem(marker: GMSMarker,poiItem: POIItem) -> Bool {
        let data = self.groupedParkDatas[poiItem.name!]?[0]
        currentData = data
        locationMarker = marker
        
        guard let location = locationMarker?.position else {
            print("locationMarker is nil")
            return false
        }
        locationPosition = location
        currentLat = locationMarker?.position.latitude as! CLLocationDegrees
        currentLong = locationMarker?.position.longitude as! CLLocationDegrees
        infoWindow.removeFromSuperview()
        addInfoView()
        return true
    }
    
    func addInfoView()  {
        infoWindow = loadNiB()
        infoWindow.titleInfo.text = currentData?.parkName
        infoWindow.administrativeAreaLabel.text = currentData?.administrativeArea!
        infoWindow.updateUI()
        if Utilities.checkIsOpenTime(openTime: (currentData?.openTime)!) {
            infoWindow.openLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            infoWindow.closeLabel.textColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
        }
        else {
            infoWindow.openLabel.textColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
            infoWindow.closeLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        }
        if locationPosition != nil {
            infoWindow.center = mapView.projection.point(for: locationPosition!)
        }
        infoWindow.center = mapView.projection.point(for: CLLocationCoordinate2DMake(currentLat, currentLong))
        infoWindow.center.y = infoWindow.center.y - sizeForOffset(view: infoWindow)
        infoWindow.delegate = self
        self.view.addSubview(infoWindow)
    }
    
    func sizeForOffset(view: UIView) -> CGFloat {
        return  135.0
    }
    
    // Load mapInfo View with xib (this is optional)
    func loadNiB() -> MapInfoWindow {
        let infoWindow = MapInfoWindow.instanceFromNib() as! MapInfoWindow
        return infoWindow
    }
    
    // Cluster init
    func initCluster() {
        clusterManager = googleMapMaker?.initCluster()
        if clusterManager != nil && (googleMapMaker?.generateClusterItems(datas: self.groupedParkDatas))!  {
            // Call cluster() after items have been added to perform the clustering and rendering on map.
            clusterManager.cluster()
        }
        else {
            let noDataAlert = UIAlertController(title: "Has no Data Yet.", message:"", preferredStyle: .alert)
            noDataAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(noDataAlert, animated: true, completion: nil)
        }
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    func upLoadView() {
        var newCamera:GMSCameraPosition = GMSCameraPosition.camera(withLatitude: defaultCameraLatitude,                                                                  longitude: defaultCameraLongitude, zoom: 16)
        if isFromPark {
            showFirstView = true
            newCamera = GMSCameraPosition.camera(withLatitude: currentLat,
                                              longitude: currentLong, zoom: 16)
        }
        else {
            if nowLong != 0 && nowLat != 0 {
                groupedParkDatas = ParkDataManager.sharedManager.getDefultParkData()
                let name = ParkDataManager.sharedManager.getNearbyPark(lat: nowLat, long: nowLong)
                if groupedParkDatas != nil {
                    currentData = groupedParkDatas[name]?[0]
                    currentLat = Double(currentData!.latitude!)!
                    currentLong = Double(currentData!.longitude!)!
                    newCamera = GMSCameraPosition.camera(withLatitude:Double(currentData!.latitude!)!,
                                                         longitude: Double(currentData!.longitude!)!, zoom: 16)
                }
            }
            else {
                showFirstView = false
            }
        }
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
    }
    
    func getCurrentLocation() {
        let location = googleMapMaker?.getCurrentLocation()
        if location != nil {
            nowLat = location!["lat"]!
            nowLong = location!["long"]!
        }
        else {
            let noDataAlert = UIAlertController(title: "Please allow GPS.", message:"", preferredStyle: .alert)
            noDataAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(noDataAlert, animated: true, completion: nil)
        }
    }
    
    func drawPath(lat: CLLocationDegrees , long: CLLocationDegrees) {
        var origin = String()
        var destination = String()
        
        origin = "\(lat),\(long)"
        destination = "\(nowLat),\(nowLong)"
        googleMapMaker?.drawPath(origin: origin, destination: destination, callback: { (routes) in
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
        })
        
    }
    
    func openGoogleApp() {
        var origin = String()
        var destination = String()
        origin = "\(currentLat),\(currentLong)"
        destination = "\(nowLat),\(nowLong)"
        googleMapMaker?.openGoogleApp(origin: origin, destination: destination)
    }
}
