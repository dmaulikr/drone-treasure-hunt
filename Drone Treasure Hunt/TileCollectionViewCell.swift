//
//  TileCollectionViewCell.swift
//  Drone Treasure Hunt
//
//  Created by Massimo Donati on 10/6/16.
//  Copyright © 2016 Massimo Donati. All rights reserved.
//

import UIKit

class TileCollectionViewCell: UICollectionViewCell {

    static let identifier = "tileCell"

    @IBOutlet weak var tilePaintView: UIView!

    override func layoutSubviews() {
        super.layoutSubviews()
        tilePaintView.layer.cornerRadius = self.frame.width / 2
        tilePaintView.clipsToBounds = false
    }
}
