//
//  MapInfoWindow.swift
//  GoogleMapsCustomInfoWindow
//
//  Created by Sofía Swidarowicz Andrade on 11/5/17.
//  Copyright © 2017 Sofía Swidarowicz Andrade. All rights reserved.
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

    @IBOutlet weak var openTimeLabel: UILabel!
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
