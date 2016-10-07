//
//  Drone.swift
//  Drone Treasure Hunt
//
//  Created by Massimo Donati on 10/6/16.
//  Copyright © 2016 Massimo Donati. All rights reserved.
//

import Foundation
import UIKit

class Drone: GameComponent, Movable {
    var color: UIColor!
    var path: [IndexPath]?

    convenience init(with image: UIImage, position: IndexPath, color: UIColor) {
        self.init(with: image, position: position)
        self.color = color
    }

    func move(to view: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            view.addSubview(self.imageView)
            let views = ["view": self.imageView!]
            self.imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [.alignAllCenterX], metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [.alignAllCenterY], metrics: nil, views: views))
            }, completion: nil)
    }
}
