//
//  Movable.swift
//  Drone Treasure Hunt
//
//  Created by Massimo Donati on 10/7/16.
//  Copyright © 2016 Massimo Donati. All rights reserved.
//

import Foundation
import UIKit

enum Moves {
    case up, down, left, right
}
typealias Path = [IndexPath]
protocol Movable {
    var path: Path { get }
    func move(to place: CGRect)
}
