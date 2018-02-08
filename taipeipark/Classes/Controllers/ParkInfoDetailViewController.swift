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
    
    var myFavoriteButton:UIBarButtonItem?
    
    // MARK: lifCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let mapButton = UIBarButtonItem(title: "map", style: .done, target: self, action: #selector(onTouchMapButton))
        var favoriteImage: UIImage?
        let isMyFavorite = ParkDataManager.sharedManager.isMyFavorite(name: (groupedParkData?.parkName)!)
        if isMyFavorite {
            favoriteImage = UIImage(named: "ic_myfavorite")
        }
        else {
            favoriteImage = UIImage(named: "ic_myfavorite_disable")
        }
        
        myFavoriteButton = UIBarButtonItem.init(image: UIImage(named: "ic_myfavorite_disable"), style: .plain, target: self, action: #selector(onTouchMyFavoriteButton))
        myFavoriteButton?.setBackgroundImage(favoriteImage, for: .normal, barMetrics: UIBarMetrics.default)
        
        navigationItem.rightBarButtonItems = [myFavoriteButton!, mapButton]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDetailUI()
        updatGroupedParkDatas()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
                self.parkTableView.setContentOffset(CGPoint.zero, animated:false)
                goToRelatedParkView(title: name, data: data)
            }
        }
    }
    
    // MARK: Action
    
    @objc func onTouchMyFavoriteButton(sender: AnyObject) {
        let isMyFavorite = ParkDataManager.sharedManager.isMyFavorite(name: parkName)
        ParkDataManager.sharedManager.saveIsFavorite(name: parkName, isFavorite: !isMyFavorite)
        var favoriteImage :UIImage?
        if !isMyFavorite {
            favoriteImage = UIImage(named: "ic_myfavorite")
        }
        else {
            favoriteImage = UIImage(named: "ic_myfavorite_disable")
        }
        myFavoriteButton?.setBackgroundImage(favoriteImage, for: .normal, barMetrics: UIBarMetrics.default)
    }
    
    @objc func onTouchMapButton(sender: AnyObject) {
        let data = self.groupedParkData
        if let mpaViewController = (self.tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers.first as? ParkMapViewController {
            mpaViewController.currentLat = Double((data?.latitude as! NSString).doubleValue)
            mpaViewController.currentLong = Double((data?.longitude as! NSString).doubleValue)
            mpaViewController.currentData = data
            mpaViewController.isFromPark = true
            self.tabBarController?.selectedIndex = 1
        }
    }

    func goToRelatedParkView(title:String, data:ParkDetailData) {
        // Go to RelatedParkViewController.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController = (storyboard.instantiateViewController(withIdentifier: "RelatedParkViewControllerCV") as? RelatedParkViewController)!
        detailViewController.parkTitle = title
        detailViewController.groupedParkData = data
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}

