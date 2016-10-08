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
    var path = Path()
    override var position: IndexPath! {
        willSet(newPosition) {
            path.append(newPosition)
        }

    }

    convenience init(with image: UIImage, position: IndexPath, color: UIColor) {
        self.init(with: image, position: position)
        path.append(position)
        self.color = color
    }

    func move(to place: UIView) {
        clearImageViewConstraints()
        UIView.animate(withDuration: 1, animations: {
            place.addSubview(self.imageView)
            let views = ["view": self.imageView!]
            self.imageView.frame = CGRect(x: 0, y: 0, width: place.frame.width, height: place.frame.height)
            place.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [.alignAllCenterX], metrics: nil, views: views))
            place.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [.alignAllCenterY], metrics: nil, views: views))
            }, completion: nil)
    }
    
    func clearImageViewConstraints() {
        self.imageView.superview?.removeConstraints(self.imageView.constraints)
    }
}
