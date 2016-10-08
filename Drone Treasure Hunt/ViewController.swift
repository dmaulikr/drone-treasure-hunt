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
    let operationQueue = OperationQueue()
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.operationQueue.maxConcurrentOperationCount = 1
        self.operationQueue.qualityOfService = .userInteractive
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
    var winHasOccured = false
    var droneA: Drone?
    var droneB: Drone?
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
        droneA?.put(in: view(at: droneAPosition))
        droneB = Drone(with: UIImage(named: "droneB")!, position: droneBPosition, color: UIColor.blue)
        droneB?.put(in: view(at: droneBPosition))
        treasure = Treasure(with: UIImage(named: "treasure")!, position: goldPosition)
        treasure.put(in: view(at: goldPosition))
        print(goldPosition)
    }

    func view(at indexPath: IndexPath) -> UIView {
        return tileCollectionViewCell(at: indexPath).tilePaintView
    }
    
    func move(drone: Drone) {
        let forbiddenPath = drone === self.droneA! ? self.droneB!.path : self.droneA!.path
        let currentPosition = drone.position
        let nextPosition = self.getNextPosition(for: drone, withforbiddenPath: forbiddenPath)
        drone.position = nextPosition
        self.collectionView.reloadItems(at: [currentPosition!])
        drone.move(to: self.view(at: nextPosition))
        print(drone.path)
    }

    func getNextPosition(for drone: Drone, withforbiddenPath path: Path) -> IndexPath {
        var possibleMoves = [IndexPath]()
        let currentRow = drone.position.row
        if currentRow + rowsNumber < (rowsNumber * colsNumber) - 1 {
            //down indexpath
            let indexpath = indexPath(with: currentRow + rowsNumber)
                possibleMoves.append(indexpath)
        }
        if currentRow - rowsNumber > 0 {
            //up position
            let indexpath = indexPath(with: currentRow - rowsNumber)
                possibleMoves.append(indexpath)
        }
        let currentIndex = index(from: currentRow)
        let rightIndex = currentIndex + 1
        let leftIndex = currentIndex - 1

        if rightIndex < colsNumber {
            //right position
            let indexpath = indexPath(with: currentRow + 1)
            possibleMoves.append(indexpath)
        }
        if leftIndex >= 0  {
            //left position
            let indexpath = indexPath(with: currentRow - 1)
                possibleMoves.append(indexpath)
        }

        possibleMoves = possibleMoves.filter { (indexpath) -> Bool in
                return !path.contains(indexpath)
            }
        let winningMove = possibleMoves.filter { (indexpath) -> Bool in
            return indexpath == treasure.position
        }.first
        if let winningMove = winningMove {
            return winningMove
        }
        let nextIndex = Int(arc4random_uniform(UInt32(possibleMoves.count)))
        let newMove = possibleMoves[nextIndex]

        return newMove
    }

    func indexPath(with row: Int) -> IndexPath {
        assert(row >= 0)
        return IndexPath(row: row, section: 0)
    }

    func index(from row: Int) -> Int {
        return row % rowsNumber
    }

    func checkWin() {
        var message = ""
        if droneA?.position == treasure.position {
            message = "droneA won"
            winHasOccured = true
        }
        if droneB?.position == treasure.position  {
            message = "droneB won"
            winHasOccured = true
        }
        if winHasOccured {
            let alertController = UIAlertController(title: "Win!!!!", message: message, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart", style: .default, handler: { (action) in

            })
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func moveDrones() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.operationQueue.addOperation({
                if self.winHasOccured {
                    return
                }
                DispatchQueue.main.sync {
                    self.move(drone: self.droneA!)
                }
            })
            self.operationQueue.addOperation({
                if self.winHasOccured {
                    return
                }
                DispatchQueue.main.sync {
                    self.move(drone: self.droneB!)
                }
            })
            self.operationQueue.addOperation({
                self.checkWin()
                if self.winHasOccured {
                    return
                }
                self.moveDrones()
            })
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.positionDronesAndTreasureInGrid()
        let newGameAlertController = UIAlertController(title: nil, message: "Tap on the start button and the drone treasure hunt will begin", preferredStyle: .alert)

        let startAction = UIAlertAction(title: "Start", style: .default) { (action) in

            self.moveDrones()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TileCollectionViewCell.identifier, for: indexPath) as! TileCollectionViewCell
        if !cornerIndexPaths.contains(indexPath) && !nonCornerIndexpaths.contains(indexPath) {
            nonCornerIndexpaths.append(indexPath)
        }
        if (droneA?.path.contains(indexPath) == true) {
            cell.tilePaintView.backgroundColor = droneA?.color
        }
        if (droneB?.path.contains(indexPath) == true) {
            cell.tilePaintView.backgroundColor = droneB?.color
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
