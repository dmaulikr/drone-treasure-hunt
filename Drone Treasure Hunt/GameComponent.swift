//
//  GameComponent.swift
//  Drone Treasure Hunt
//
//  Created by Massimo Donati on 10/7/16.
//  Copyright © 2016 Massimo Donati. All rights reserved.
//

import Foundation
import UIKit

class GameComponent: Placeable {
    internal var imageView: UIImageView!
    var position: IndexPath!

    convenience init(with image: UIImage, position: IndexPath) {
        self.init()
        self.position = position
        self.imageView = UIImageView(image: image)
    }

    internal func put(in place: UIView!) {
        UIView.animate(withDuration: 0.3, animations: {
            place.addSubview(self.imageView)
            let views = ["view": self.imageView!]
            self.imageView.frame = CGRect(x: 0, y: 0, width: place.frame.width, height: place.frame.height)
            place.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [.alignAllCenterX], metrics: nil, views: views))
            place.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [.alignAllCenterY], metrics: nil, views: views))
            }, completion: nil)
    }
}
