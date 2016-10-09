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
    override var position: IndexPath? {
        willSet(newPosition) {
            if let currentPosition = position {
                guard newPosition != path.last else {
                    path.removeLast()
                    return
                }
                path.append(currentPosition)
            }
        }
    }

    convenience init(with image: UIImage, position: IndexPath?, color: UIColor, playGroundView: UIView!) {
        self.init(with: image, position: position, playGroundView: playGroundView)
        if let position = position {
            path.append(position)
        }
        self.color = color
    }

    func move(to place: CGRect) {
        animateTopLefConstraints(with: place.origin.y, x: place.origin.x)
    }
}
