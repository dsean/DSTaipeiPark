//
//  MapInfoWindow.swift
//
//  Created by 楊德忻 on 2018/2/6.
//  Copyright © 2018年 sean. All rights reserved.
//

import UIKit

protocol MapInfoWindowDelegate {
    func onTouchFButton(name:String)
    func onTouchPathButton()
    func onTouchGoogleButton()
}

class MapInfoWindow: UIView {

    var delegate:MapInfoWindowDelegate?
    
    @IBOutlet weak var titleInfo: UILabel!

    @IBOutlet weak var openLabel: UILabel!
    @IBOutlet weak var closeLabel: UILabel!
    @IBOutlet weak var administrativeAreaLabel: UILabel!
    @IBAction func onTouchFButton(_ sender: Any) {
        
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
}
