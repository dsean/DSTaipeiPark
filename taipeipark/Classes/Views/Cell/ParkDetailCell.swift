//
//  ParkDetailCell.swift
//  taipeipark
//
//  Created by 楊德忻 on 2018/2/6.
//  Copyright © 2018年 sean. All rights reserved.
//

import UIKit

protocol ParkDetailCellDelegate {
    func onTouchUpInside(name:String)
}

class ParkDetailCell:UITableViewCell {
    var url:String?
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var relatedCollectionView: UICollectionView!
    
    var delegate:ParkDetailCellDelegate?
    var relatedDatas:[ParkData]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func onTouchUpInside(name:String) {
        self.delegate?.onTouchUpInside(name: name)
    }
}
