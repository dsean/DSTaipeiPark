//
//  ParkInfoDetailViewController.swift
//  taipeipark
//
//  Created by 楊德忻 on 2018/2/7.
//  Copyright © 2018年 sean. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON

class ParkInfoDetailViewController: UIViewController {
    
    private var groupedParkDetailDatas:[String:[ParkDetailData]]!
    var groupedParkData:ParkData!
    var parkTitle:String?
    
    // MARK: lifCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = parkTitle
        
        updatGroupedParkDatas()
    }
    
    // MARK: function
    
    private func updatGroupedParkDatas() {
        if self.groupedParkDetailDatas == nil {
            ParkDataManager.sharedManager.requestParkDetailInfo(parkName:self.parkTitle! ,completion: { [weak self] (groupedDatas,success) in
                
                if groupedDatas != nil && groupedDatas!.count > 0 {
                    self?.groupedParkDetailDatas = groupedDatas
                }
                
                if !success {
                    let useCache = groupedDatas != nil && groupedDatas!.count > 0
                    let noDataAlert = UIAlertController(title: "無相關景點", message: useCache ? "":"", preferredStyle: .alert)
                    noDataAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(noDataAlert, animated: true, completion: nil)
                }
            })
        }
    }
}

