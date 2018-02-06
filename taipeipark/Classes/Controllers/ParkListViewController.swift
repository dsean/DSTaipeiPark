//
//  ViewController.swift
//  taipeipark
//
//  Created by 楊德忻 on 2018/2/3.
//  Copyright © 2018年 sean. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON

class ParkListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
        self.title = "台北市公園景點"
        
        updatGroupedParkDatas()
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
        
        if let park = self.parkTitles?[indexPath.row], let data = self.groupedParkDatas[park]?[0] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ParkListTableCell", for: indexPath) as! ParkListTableCell
            cell.url = data.image
            cell.parkNameLabel.text = data.parkName
            cell.administrativeAreaLabel.text = data.administrativeArea
            cell.introLabel.text = data.introduction
            cell.reloadUI()
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
}

