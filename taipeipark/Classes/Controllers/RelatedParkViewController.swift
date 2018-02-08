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

class RelatedParkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //Pre-linked with IBOutlets
    @IBOutlet weak var parkImageView: UIImageView!
    @IBOutlet weak var parkTableView: UITableView!

    var groupedParkData:ParkDetailData!
    var parkTitle:String?
    
    // MARK: lifCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.parkTableView.register(UINib(nibName: "ParkDetailCell", bundle: nil), forCellReuseIdentifier: "ParkDetailCell")
        parkTableView.separatorStyle = .none
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parkTableView.delegate = self
        parkTableView.dataSource = self
        updateDetailUI()
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
        
        cell.parkNameLabel.text = self.groupedParkData!.parkName
        cell.locationLabel.text = self.groupedParkData!.name
        cell.introLabel.text = self.groupedParkData!.introduction
        cell.openTimeLabel.text = "開放時間：\(self.groupedParkData!.openTime)"
        cell.relatedCollectionView.isHidden = true
        cell.relatedTitleLabel.isHidden = true
        return cell
    }
    
    // MARK: function
    
    func updateDetailUI() {
        self.title = groupedParkData?.name!
        if let image = groupedParkData?.image, let imageUrl = URL(string: image) {
            parkImageView.sd_setImage(with: imageUrl, placeholderImage: nil, options: .highPriority, completed: nil)
        }
        self.parkTableView.reloadData()
    }
}

