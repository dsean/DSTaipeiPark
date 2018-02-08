//
//  Utilities.swift
//  Created by 楊德忻 on 2018/2/6.
//  Copyright © 2018年 sean. All rights reserved.
//

import Foundation
import UIKit

class Utilities: NSObject {

    class func checkIsOpenTime(openTime:String) -> Bool {
        if openTime == "" {
            return false
        }
        var strArr = openTime.components(separatedBy: "~")
        var open = strArr[0].replacingOccurrences(of: ":", with: "")+"00"
        var close = strArr[1].replacingOccurrences(of: ":", with: "")+"00"
        
        let nowDate = Date()
        let dformatter = DateFormatter()
        dformatter.dateFormat = "HHmmss"
        let now = dformatter.string(from: nowDate)
        if Double(close)! < Double(open)! {
            let oldClose = close
            close = open
            open = oldClose
        }
        if (Double(now)! > Double(open)!) && (Double(now)! < Double(close)!) {
            return true
        }
        else {
            return false
        }
    }
    
    class func getDistance(lat1: Double,long1: Double,lat2: Double,long2: Double) -> String {
        let currentLocation = CLLocation(latitude: lat1, longitude: long1)
        let targetLocation = CLLocation(latitude: lat2, longitude: long2)
        let distance:CLLocationDistance = currentLocation.distance(from: targetLocation)
        return "\(distance)"
    }
}
