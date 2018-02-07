//
//  RelatedParkSpotCollectionViewCell.swift
//  Taipei_Park
//
//  Created by Puyan Lin on 2018/1/25.
//  Copyright © 2018年 Puyan. All rights reserved.
//

import UIKit

protocol RelatedParkCollectionViewCellDelegate {
    func onTouchUpInside(name:String)
}

class RelatedParkCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    let defaultImage = UIImage(named: "park")
    var url:String?
    var delegate:RelatedParkCollectionViewCellDelegate?
    
    @IBAction func onTouchRelatedCell(_ sender: UIButton) {
        self.delegate?.onTouchUpInside(name: nameLabel.text!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func reloadUI() {
        if imgView != nil {
            if let image = self.url, let imageUrl = URL(string: image) {
                imgView.sd_setImage(with: imageUrl, placeholderImage: defaultImage, options: .continueInBackground, completed: nil)
            }
            else{
                imgView.image = defaultImage
            }
        }
    }
}
