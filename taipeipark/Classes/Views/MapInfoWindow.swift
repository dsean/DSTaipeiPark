//
//  MapInfoWindow.swift
//
//  Created by 楊德忻 on 2018/2/6.
//  Copyright © 2018年 sean. All rights reserved.
//

import UIKit

protocol MapInfoWindowDelegate {
    func onTouchPathButton()
    func onTouchGoogleButton()
}

class MapInfoWindow: UIView {

    var delegate:MapInfoWindowDelegate?
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var titleInfo: UILabel!

    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var administrativeAreaLabel: UILabel!
    
    @IBAction func onTouchFavoriteButton(_ sender: UIButton) {
        let isMyFavorite = ParkDataManager.sharedManager.isMyFavorite(name: self.titleInfo.text!)
        ParkDataManager.sharedManager.saveIsFavorite(name: self.titleInfo.text!, isFavorite: !isMyFavorite)
        if !isMyFavorite {
            self.favoriteButton.setImage(UIImage(named: "ic_myfavorite"), for: .normal)
        }
        else {
            self.favoriteButton.setImage(UIImage(named: "ic_myfavorite_disable"), for: .normal)
        }
    }
    
    @IBAction func onTouchPathButton(_ sender: UIButton) {
        self.delegate?.onTouchPathButton()
    }
    
    @IBAction func onTouchGoogleButton(_ sender: UIButton) {
        self.delegate?.onTouchGoogleButton()
    }
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapInfoWindowView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func updateUI() {
        if self.titleInfo.text != nil {
            let isMyFavorite = ParkDataManager.sharedManager.isMyFavorite(name: self.titleInfo.text!)
            if isMyFavorite {
                self.favoriteButton.setImage(UIImage(named: "ic_myfavorite"), for: .normal)
            }
            else {
                self.favoriteButton.setImage(UIImage(named: "ic_myfavorite_disable"), for: .normal)
            }
        }
    }
}
