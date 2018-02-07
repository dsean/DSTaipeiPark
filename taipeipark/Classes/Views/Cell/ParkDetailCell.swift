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

class ParkDetailCell:UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, RelatedParkCollectionViewCellDelegate  {
    var url:String?
    
    //Pre-linked with IBOutlets
    @IBOutlet weak var relatedTitleLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var relatedCollectionView: UICollectionView!
    
    var delegate:ParkDetailCellDelegate?
    var relatedDatas:[ParkDetailData]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.relatedCollectionView.register(UINib(nibName: "RelatedParkCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RelatedParkCollectionViewCell")
    }
    
    // MARK: - Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let relatedDatas = self.relatedDatas else {
            // loading
            return 0
        }
        return relatedDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RelatedParkCollectionViewCell", for: indexPath) as! RelatedParkCollectionViewCell
        let data = self.relatedDatas![indexPath.item]
        cell.url = data.image
        cell.nameLabel.text = data.name
        cell.delegate = self
        cell.reloadUI()
        
        return cell
    }
    
    func onTouchUpInside(name:String) {
        self.delegate?.onTouchUpInside(name: name)
    }
}
