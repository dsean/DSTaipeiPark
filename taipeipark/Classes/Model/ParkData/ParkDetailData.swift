//
//  ParkData.swift
//  taipeipark
//
//  Created by 楊德忻 on 2018/2/6.
//  Copyright © 2018年 sean. All rights reserved.
//

/* result:
 key
 {
    id
    parkName
    name
    openTime
    Introduction
    image
    YearBuilt
 }
*/

import Foundation

import ObjectMapper

class ParkDetailData:Mappable, Equatable {
    static func ==(lhs: ParkDetailData, rhs: ParkDetailData) -> Bool {
        return lhs.id == rhs.id
    }
    
    private(set) var parkName:String!
    private(set) var name:String!
    private(set) var openTime:String = "no Data"
    private(set) var image:String?
    private(set) var introduction:String!
    private(set) var id:String!
    private(set) var yearBuilt:String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["_id"]
        parkName <- map["ParkName"]
        name <- map["Name"]
        openTime <- map["OpenTime"]
        image <- map["Image"]
        introduction <- map["Introduction"]
        yearBuilt <- map["YearBuilt"]
    }
}
