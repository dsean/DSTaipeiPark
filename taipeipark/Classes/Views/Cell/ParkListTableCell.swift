//
//  ParkListTableCell.swift
//  taipeipark
//
//  Created by 楊德忻 on 2018/2/7.
//  Copyright © 2018年 sean. All rights reserved.
//

import UIKit
import SDWebImage

class ParkListTableCell: UITableViewCell {
    
    let defaultImage = UIImage(named: "park")
    var url:String?
    
    //Pre-linked with IBOutlets
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var parkNameLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var administrativeAreaLabel: UILabel!
    @IBOutlet weak var imgPark: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: Action
    
    @IBAction func onTouchFavoriteButton(_ sender: UIButton) {
    }
    
    @IBAction func onTouchMapButton(_ sender: UIButton) {
    }
    
    // MARK: function
    
    func reloadUI() {
        if imgPark != nil {
            if let image = self.url, let imageUrl = URL(string: image) {
                imgPark.sd_setImage(with: imageUrl, placeholderImage: defaultImage, options: .continueInBackground, completed: nil)
            }
            else{
                imgPark.image = defaultImage
            }
        }
    }
}
