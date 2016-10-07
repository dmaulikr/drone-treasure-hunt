//
//  ViewController.swift
//  Drone Treasure Hunt
//
//  Created by Massimo Donati on 10/6/16.
//  Copyright © 2016 Massimo Donati. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let colsNumber = 5
    let rowsNumber = 5
    var defaultGap: CGFloat = 0.0

    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch self.traitCollection.userInterfaceIdiom {
        case .phone:
            defaultGap = 10
            self.collectionView.collectionViewLayout.invalidateLayout()
            return
        case .pad:
            defaultGap = 40
            self.collectionView.collectionViewLayout.invalidateLayout()
            return
        default:
            defaultGap = 0.0
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colsNumber * rowsNumber
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TileCollectionViewCell.identifier, for: indexPath)
        return cell;
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: defaultGap, bottom: 0, right: defaultGap)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return defaultGap
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return defaultGap
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cvWidth = collectionView.frame.width
        // totalGap is 2 * defaultGap for the left and right insets + 4 * defaultGap for each space
        // between the items in the same line
        let totalGap = 2 * defaultGap + CGFloat(colsNumber + -1) * defaultGap
        let itemWidth = (cvWidth - totalGap) / CGFloat(colsNumber)
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
