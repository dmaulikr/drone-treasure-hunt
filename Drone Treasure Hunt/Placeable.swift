//
//  Positionable.swift
//  Drone Treasure Hunt
//
//  Created by Massimo Donati on 10/7/16.
//  Copyright © 2016 Massimo Donati. All rights reserved.
//

import Foundation
import UIKit

protocol Placeable {
    var position: IndexPath? {get set}
    var playGroundView: UIView! { get set }
    func put(in place: CGRect)
}
