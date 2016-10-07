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
        self.init()
        self.position = position
        self.imageView = UIImageView(image: image)
        self.imageView.clipsToBounds = true
        self.color = color
    }

    func move(to view: UIView) {
        UIView.animate(withDuration: 0.3, animations: { 
            self.imageView.frame = view.frame
            }, completion: nil)
    }

}
