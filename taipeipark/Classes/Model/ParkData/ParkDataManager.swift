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
    
    private(set) var groupedParkDatas:[String:[ParkData]]?
    
    // Request Taipei park data.
    
    func requestParkInfo(completion:@escaping ((_ groupedParkDatas:[String:[ParkData]]?, _ success:Bool)->Void)){
        
        let parkInfoUrl = "https://beta.data.taipei/api/getDatasetInfo/downloadResource?id=a132516d-d2f3-4e23-866e-27e616b3855a&rid=8f6fcb24-290b-461d-9d34-72ed1b3f51f0"
        
        self.groupedParkDatas = nil
        Alamofire.request(parkInfoUrl).validate().responseJSON { response in
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
}
