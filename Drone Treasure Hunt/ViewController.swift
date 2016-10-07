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

        // the assumption here is that we are dealing with an equal number of
        // rows and columns
        let topLeft = IndexPath(row: 0, section: 0)
        let topRight = IndexPath(row: rowsNumber - 1, section: 0)
        let bottomLeft = IndexPath(row: (rowsNumber-1)*rowsNumber, section: 0)
        let bottomRight = IndexPath(row: (rowsNumber + 1)*(rowsNumber - 1), section: 0)
        cornerIndexPaths = [topLeft, topRight, bottomLeft, bottomRight]
    }

    var cornerIndexPaths = [IndexPath]()

    var nonCornerIndexpaths = [IndexPath]()

    var positionDroneA: IndexPath?
    var positionDroneB: IndexPath?

    var droneA: Drone!
    var droneB: Drone!
    var treasure: Treasure!

    func computeTreasurePosition() -> IndexPath {
        let index = Int(arc4random_uniform(UInt32(nonCornerIndexpaths.count)))
        return nonCornerIndexpaths[index]
    }

    func computeDronePosition() -> IndexPath {
        let index = Int(arc4random_uniform(UInt32(cornerIndexPaths.count)))
        let droneAIndexPath = cornerIndexPaths[index]
        cornerIndexPaths.remove(at: index)
        return droneAIndexPath
    }

    func positionDronesAndTreasureInGrid() {
        let goldPosition = computeTreasurePosition()
        let droneAPosition = computeDronePosition()
        let droneBPosition = computeDronePosition()
        droneA = Drone(with: UIImage(named: "droneA")!, position: droneAPosition, color: UIColor.orange)
        droneA.put(in: view(at: droneAPosition))
        droneB = Drone(with: UIImage(named: "droneB")!, position: droneBPosition, color: UIColor.blue)
        droneB.put(in: view(at: droneBPosition))
        treasure = Treasure(with: UIImage(named: "treasure")!, position: goldPosition)
        treasure.put(in: view(at: goldPosition))
        print(goldPosition)
    }

    func view(at indexPath: IndexPath) -> UIView {
        return tileCollectionViewCell(at: indexPath).tilePaintView
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.positionDronesAndTreasureInGrid()
        let newGameAlertController = UIAlertController(title: nil, message: "Tap on the start button and the drone treasure hunt will begin", preferredStyle: .alert)

        let startAction = UIAlertAction(title: "Start", style: .default) { (action) in

        }

        newGameAlertController.addAction(startAction)

        present(newGameAlertController, animated: true, completion: nil)

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

    func tileCollectionViewCell(at indexPath: IndexPath) -> TileCollectionViewCell {
        return self.collectionView.cellForItem(at: indexPath) as! TileCollectionViewCell
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TileCollectionViewCell.identifier, for: indexPath)
        if !cornerIndexPaths.contains(indexPath) && !nonCornerIndexpaths.contains(indexPath) {
            nonCornerIndexpaths.append(indexPath)
        }
        return cell;
    }

    //MARK: UICollectionViewDelegateFlowLayout
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
