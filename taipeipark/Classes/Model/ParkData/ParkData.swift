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
    ParkName
    AdministrativeArea
    Location
    ParkType
    Introduction
    Latitude
    Longitude
    Area
    YearBuilt
    OpenTime
    Image
    ManagementName
    ManageTelephone
 }
 see https://data.gov.tw/dataset/73867 
*/

import Foundation

import ObjectMapper

class ParkData:Mappable, Equatable {
    static func ==(lhs: ParkData, rhs: ParkData) -> Bool {
        return lhs.id == rhs.id
    }
    
    private(set) var parkName:String!
    private(set) var administrativeArea:String!
    private(set) var location:String!
    private(set) var parkType:String!
    private(set) var latitude:String!
    private(set) var longitude:String!
    private(set) var area:String!
    private(set) var managementName:String!
    private(set) var manageTelephone:String!
    private(set) var openTime:String = ""
    private(set) var image:String?
    private(set) var introduction:String!
    private(set) var id:String!
    private(set) var yearBuilt:String?
    
    required init?(map: Map) {}
    
    // Mapping park data with JSON.
    
    func mapping(map: Map) {
        parkName <- map["ParkName"]
        openTime <- map["OpenTime"]
        image <- map["Image"]
        introduction <- map["Introduction"]
        yearBuilt <- map["YearBuilt"]
        location <- map["Location"]
        parkType <- map["parkType"]
        latitude <- map["Latitude"]
        longitude <- map["Longitude"]
        area <- map["Area"]
        administrativeArea <- map["AdministrativeArea"]
        managementName <- map["ManagementName"]
        manageTelephone <- map["ManageTelephone"]
    }
}
