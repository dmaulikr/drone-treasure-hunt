//
//  Movable.swift
//  Drone Treasure Hunt
//
//  Created by Massimo Donati on 10/7/16.
//  Copyright © 2016 Massimo Donati. All rights reserved.
//

import Foundation
import UIKit

enum moves {
    case up, down, left, right
}

protocol Movable {
    var path: [IndexPath]? { get }

    func move(to view:UIView)
}
