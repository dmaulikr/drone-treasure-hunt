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
    var playGroundView: UIView!
    var position: IndexPath?
    internal var topConstraint: NSLayoutConstraint?
    internal var leftConstraint: NSLayoutConstraint?
    convenience init(with image: UIImage, position: IndexPath?, playGroundView: UIView) {
        self.init()
        self.position = position
        self.imageView = UIImageView(image: image)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.playGroundView = playGroundView
    }

    internal func animateTopLefConstraints(with y: CGFloat, x: CGFloat) {
        self.topConstraint?.constant = y
        self.leftConstraint?.constant = x
        UIView.animate(withDuration: 0.2, animations: {
            self.imageView.setNeedsLayout()
        }, completion: nil)
    }

    func put(in place: CGRect) {
        guard let _ = leftConstraint, let _ = topConstraint else {
            addConstraints(with: place)
            return
        }
        animateTopLefConstraints(with: place.origin.y, x: place.origin.x)
    }

    func addConstraints(with rect:CGRect) {
        UIView.animate(withDuration: 0, animations: {
            self.playGroundView.insertSubview(self.imageView, at: 0)
            let metrics = ["x":rect.origin.x,
                           "y":rect.origin.y,
                           "width": rect.width,
                           "height": rect.height]

            self.leftConstraint = NSLayoutConstraint(item: self.imageView,
                                                     attribute: .left,
                                                     relatedBy: .equal,
                                                     toItem: self.playGroundView,
                                                     attribute: .left,
                                                     multiplier: 1.0,
                                                     constant: metrics["x"]!);

            self.topConstraint = NSLayoutConstraint(item: self.imageView,
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: self.playGroundView,
                                                    attribute: .top,
                                                    multiplier: 1.0,
                                                    constant: metrics["y"]!);


            let width = NSLayoutConstraint(item: self.imageView,
                                           attribute: .width,
                                           relatedBy: .equal,
                                           toItem: nil,
                                           attribute: .notAnAttribute,
                                           multiplier: 1.0,
                                           constant: metrics["width"]!);

            let height = NSLayoutConstraint(item: self.imageView,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: metrics["height"]!);

            self.playGroundView.addConstraints([self.leftConstraint!, self.topConstraint!, width, height])
            }, completion:nil)
    }
}
