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

class ParkListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ParkListTableCellDelegate {
    
    //Pre-linked with IBOutlets
    @IBOutlet weak var parkListTableView: UITableView!
    
    private var groupedParkDatas:[String:[ParkData]]!
    private var parkTitles:[String]?
    
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
        parkListTableView.delegate = self
        parkListTableView.dataSource = self
        parkListTableView.tableFooterView = UIView()
        self.title = "台北市公園列表"
        
        updatGroupedParkDatas()
        self.parkListTableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let parkTitles = self.parkTitles else {
            // loading
            return 1
        }
        return parkTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Set park data to list view
        if let park = self.parkTitles?[indexPath.row], let data = self.groupedParkDatas[park]?[0] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParkListTableCell", for: indexPath) as! ParkListTableCell
            let isMyFavorite = ParkDataManager.sharedManager.isMyFavorite(name: data.parkName)
            if isMyFavorite {
                cell.favoriteButton.setImage(UIImage(named: "ic_myfavorite"), for: .normal)
            }
            else {
                cell.favoriteButton.setImage(UIImage(named: "ic_myfavorite_disable"), for: .normal)
            }
            
            cell.url = data.image
            cell.parkNameLabel.text = data.parkName
            cell.administrativeAreaLabel.text = data.administrativeArea
            cell.introLabel.text = data.introduction
            cell.delegate = self
            cell.reloadUI()
            return cell
        }
        // Loading cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let park = self.parkTitles?[indexPath.row], let data = self.groupedParkDatas[park]?[0] {
            goToDetailParkInfoView(title: park,data: data)
        }
    }
    
    // MARK: function
    
    private func updatGroupedParkDatas() {
        if self.groupedParkDatas == nil {
            ParkDataManager.sharedManager.requestParkInfo(completion: { [weak self] (groupedDatas,success) in
                
                if groupedDatas != nil && groupedDatas!.count > 0 {
                    self?.groupedParkDatas = groupedDatas
                    self?.parkTitles = Array(groupedDatas!.keys)
                    self?.parkListTableView.reloadData()
                }
                
                if !success {
                    let useCache = groupedDatas != nil && groupedDatas!.count > 0
                    let noDataAlert = UIAlertController(title: "Get data fail", message: useCache ? "":"", preferredStyle: .alert)
                    noDataAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(noDataAlert, animated: true, completion: nil)
                }
            })
        }
    }
    
    // MARK: Action
    
    func goToDetailParkInfoView(title:String, data:ParkData) {
        // Go to DetailParkInfoViewController.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController = (storyboard.instantiateViewController(withIdentifier: "ParkInfoDetailViewControllerCV") as? ParkInfoDetailViewController)!
        detailViewController.parkTitle = title
        detailViewController.groupedParkData = data
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    // MARK: ParkListTableCellDelegate
    func onTouchFavoriteButton(name:String) {
        
    }
    
    func onTouchMapButton(name:String) {
        let data = self.groupedParkDatas[name]?[0]
        if let mpaViewController = (self.tabBarController?.viewControllers?[1] as? UINavigationController)?.viewControllers.first as? ParkMapViewController {
            mpaViewController.currentLat = Double((data?.latitude as! NSString).doubleValue)
            mpaViewController.currentLong = Double((data?.longitude as! NSString).doubleValue)
            mpaViewController.currentData = data
            mpaViewController.isFromPark = true
            self.tabBarController?.selectedIndex = 1
        }
    }
}

