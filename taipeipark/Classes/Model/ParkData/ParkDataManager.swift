//
//  ParkDataManager.swift
//  taipeipark
//
//  Created by 楊德忻 on 2018/2/6.
//  Copyright © 2018年 sean. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

let KEY:String = "PARK_DATA"
let FAVORITE_KEY:String = "FAVORITE_KEY"
let DETAIL_KEY:String = "PARK_DETAIL_DATA"

class ParkDataManager {
    
    private static var instance:ParkDataManager!
    
    static var sharedManager:ParkDataManager {
        get{
            if instance == nil {
                instance = ParkDataManager()
            }
            return instance
        }
    }
    
    private init(){}
    
    private var groupedParkDatas:[String:[ParkData]]?
    
    func getDefultParkData() -> [String:[ParkData]]! {
        self.parseResults(rawString: UserDefaults.standard.string(forKey: KEY))
        return self.groupedParkDatas
    }
    
    // Request Taipei park data.
    
    func requestParkInfo(completion:@escaping ((_ groupedParkDatas:[String:[ParkData]]?, _ success:Bool)->Void)){
        
        let parkInfoUrl = "https://beta.data.taipei/api/getDatasetInfo/downloadResource"
        let para=["id": "a132516d-d2f3-4e23-866e-27e616b3855a","rid": "8f6fcb24-290b-461d-9d34-72ed1b3f51f0"];
        self.groupedParkDatas = nil
        Alamofire.request(parkInfoUrl ,parameters: para).validate().responseJSON { response in
            var success = false
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let strResults = json.rawString()
                success = self.parseResults(rawString: strResults)
                if success {
                    UserDefaults.standard.set(strResults, forKey: KEY)
                    UserDefaults.standard.synchronize()
                }
            case .failure( _): break
            }
            if !success {
                self.parseResults(rawString: UserDefaults.standard.string(forKey: KEY))
            }
            completion(self.groupedParkDatas, success)
        }
        
    }
    
    // Parse Taipei park data.
    
    @discardableResult func parseResults(rawString:String?) -> Bool {
        if let strResults = rawString,
            let parkDatas = [ParkData](JSONString: strResults), parkDatas.count > 0 {
            self.groupedParkDatas = [String:[ParkData]]()
            for data in parkDatas {
                if var savedDatas = self.groupedParkDatas?[data.parkName] {
                    savedDatas.append(data)
                    self.groupedParkDatas?.updateValue(savedDatas, forKey: data.parkName)
                }
                else {
                    self.groupedParkDatas?.updateValue([data], forKey: data.parkName)
                }
            }
            return true
        }
        return false
    }
    
    private var groupedParkDetailDatas:[String:[ParkDetailData]]?
    
    // Request Taipei park detail data.
    
    func requestParkDetailInfo(parkName:String, completion:@escaping ((_ groupedParkDetailDatas:[String:[ParkDetailData]]?, _ success:Bool)->Void)){
        
        let parkInfoUrl = "http://data.taipei/opendata/datalist/apiAccess"
        self.groupedParkDetailDatas = nil
        let para=["q": parkName,"rid": "bf073841-c734-49bf-a97f-3757a6013812", "scope": "resourceAquire"];
        Alamofire.request(parkInfoUrl ,parameters: para).validate().responseJSON { response in
            var success = false
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let strResults = json["result"]["results"].rawString()
                success = self.parseDetailResults(rawString: strResults)
                if success {
                    UserDefaults.standard.set(strResults, forKey: DETAIL_KEY)
                    UserDefaults.standard.synchronize()
                }
            case .failure( _): break
            }
            if !success {
                self.parseDetailResults(rawString: UserDefaults.standard.string(forKey: DETAIL_KEY))
            }
            completion(self.groupedParkDetailDatas, success)
        }
    }
    
    // Parse Taipei park detail data.
    
    @discardableResult func parseDetailResults(rawString:String?) -> Bool {
        if let strResults = rawString,
            let parkDatas = [ParkDetailData](JSONString: strResults), parkDatas.count > 0 {
            self.groupedParkDetailDatas = [String:[ParkDetailData]]()
            for data in parkDatas {
                if var savedDatas = self.groupedParkDetailDatas?[data.parkName] {
                    savedDatas.append(data)
                    self.groupedParkDetailDatas?.updateValue(savedDatas, forKey: data.parkName)
                }
                else {
                    self.groupedParkDetailDatas?.updateValue([data], forKey: data.parkName)
                }
            }
            return true
        }
        return false
    }
    
    // Favorite
    func getFavoriteDatas() -> [String:[ParkData]]! {
        var newData:[String:[ParkData]]! = [:]
        let data = UserDefaults.standard.dictionary(forKey: FAVORITE_KEY)
        if data != nil {
            for key in (data?.keys)! {
                let isFavorite = isMyFavorite(name: key)
                if isFavorite {
                    newData[key] = self.groupedParkDatas![key]
                }
            }
            return newData
        }
        return nil
    }
    
    func saveIsFavorite(name: String, isFavorite: Bool) {
        var data = UserDefaults.standard.dictionary(forKey: FAVORITE_KEY)
        
        if data == nil {
            data = Dictionary()
        }
        data![name] = isFavorite
        
        UserDefaults.standard.set(data, forKey: FAVORITE_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func isMyFavorite(name: String) -> Bool {
        var data = UserDefaults.standard.dictionary(forKey: FAVORITE_KEY)
        if data != nil {
            if let isMyFavorite = data?[name] {
                return isMyFavorite as! Bool
            }
            return false
        }
        return false
    }
    
    func getNearbyPark(lat: Double, long: Double) -> String {
        var parkName: String?
        var distance: String! = nil
        if self.groupedParkDatas == nil {
            return ""
        }
        for key in self.groupedParkDatas!.keys {
            if let data = self.groupedParkDatas?[key]![0] {
                
                if distance == nil {
                    parkName = data.parkName
                    distance = Utilities.getDistance(lat1: lat, long1: long, lat2: Double(data.latitude)!, long2: Double(data.longitude)!)
                }
                else {
                    let newDistance = Utilities.getDistance(lat1: lat, long1: long, lat2: Double(data.latitude)!, long2: Double(data.longitude)!)
                    if Double(newDistance)! < Double(distance)! {
                        parkName = data.parkName
                        distance = newDistance
                    }
                }
            }
            else {
              return ""
            }
        }
        return parkName!
    }
}
