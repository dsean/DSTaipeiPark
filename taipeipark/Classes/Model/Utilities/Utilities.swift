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
        var open = strArr[0]+":00"
        var close = strArr[1]+":00"
        
        let nowDate = Date()
        let dformatter = DateFormatter()
        dformatter.dateFormat = "HH:mm:ss"
        let now = dformatter.string(from: nowDate)
        if close < open {
            let oldClose = close
            close = open
            open = oldClose
        }
        if (now > open) && (now < close) {
            return true
        }
        else {
            return false
        }
    }
}
