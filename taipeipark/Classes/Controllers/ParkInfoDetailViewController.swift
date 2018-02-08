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

class ParkInfoDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ParkDetailCellDelegate {
    
    //Pre-linked with IBOutlets
    @IBOutlet weak var parkImageView: UIImageView!
    @IBOutlet weak var parkTableView: UITableView!
    private var groupedParkDetailDatas:[String:[ParkDetailData]]!
    var groupedParkData:ParkData!
    var parkTitle:String?
    
    var parkName:String = ""
    var location:String = ""
    
    // MARK: lifCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDetailUI()
        updatGroupedParkDatas()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParkDetailCell", for: indexPath) as! ParkDetailCell
        var openTime = self.groupedParkData!.openTime
        if self.groupedParkData!.openTime == "" {
            openTime = "無資料"
        }
        
        cell.parkNameLabel.text = parkName
        cell.locationLabel.text = location
        cell.introLabel.text = self.groupedParkData!.introduction
        cell.openTimeLabel.text = "開放時間：\(openTime)"
        cell.relatedCollectionView.isHidden = true
        cell.relatedTitleLabel.isHidden = true
        if self.groupedParkDetailDatas != nil {
            cell.relatedCollectionView.isHidden = false
            cell.relatedTitleLabel.isHidden = false
            cell.relatedDatas = self.groupedParkDetailDatas[self.parkTitle!]
            cell.delegate = self
            cell.relatedCollectionView.reloadData()
        }
        return cell
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
                    self?.groupedParkDetailDatas = nil
                }
                self?.parkTableView.reloadData()
            })
        }
    }
    
    func updateDetailUI() {
        
        parkTableView.register(UINib(nibName: "ParkDetailCell", bundle: nil), forCellReuseIdentifier: "ParkDetailCell")
        parkTableView.separatorStyle = .none
        parkTableView.delegate = self
        parkTableView.dataSource = self
        
        self.title = groupedParkData?.parkName
        
        parkName = self.groupedParkData!.parkName
        if self.groupedParkData!.parkType != nil {
            parkName = parkName + "(\(self.groupedParkData!.parkType))"
        }
        
        location = self.groupedParkData!.administrativeArea
        if self.groupedParkData!.location != nil {
            location = location + " \(self.groupedParkData!.location!)"
        }
        
        if let image = groupedParkData!.image, let imageUrl = URL(string: image) {
            parkImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: .highPriority, completed: nil)
        }
        self.parkTableView.reloadData()
    }
    
    // MARK: - ParkDetailCellDelegate
    
    func onTouchUpInside(name:String) {
        
        for data in self.groupedParkDetailDatas[self.parkTitle!]! {
            if data.name == name {
                goToRelatedParkView(title: name, data: data)
            }
        }
    }
    
    // MARK: Action
    
    func goToRelatedParkView(title:String, data:ParkDetailData) {
        // Go to RelatedParkViewController.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController = (storyboard.instantiateViewController(withIdentifier: "RelatedParkViewControllerCV") as? RelatedParkViewController)!
        detailViewController.parkTitle = title
        detailViewController.groupedParkData = data
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

