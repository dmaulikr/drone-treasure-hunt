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
    @IBOutlet weak var droneAScoreLabel: UILabel!
    @IBOutlet weak var droneBScoreLabel: UILabel!

    var droneAWinsCount = 0 {
        willSet(new) {
            DispatchQueue.main.async {
                self.droneAScoreLabel.text = " \(new)"
            }
        }
    }
    var droneBWinsCount = 0 {
        willSet(new) {
            DispatchQueue.main.async {
                self.droneBScoreLabel.text = " \(new)"
            }
        }
    }

    var cornerIndexPaths = [IndexPath]()

    var nonCornerIndexpaths = [IndexPath]()

    var winHasOccured: Bool = false {
        willSet(win) {
            if win {
                self.timer?.invalidate()
            }
        }
    }

    var droneA: Drone?
    var droneB: Drone?
    var treasure: Treasure?
    var timer: Timer?
    var needsReset = false

    //MARK: - viewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.operationQueue.maxConcurrentOperationCount = 1
        self.operationQueue.qualityOfService = .userInteractive
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        populateIndexPathsArray()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createGameComponents()
        prepareNewGame()
    }

    let moveTimeInterval = 0.5
    func startMatch() {
        if self.needsReset {
            prepareNewGame()
        }
        self.timer = Timer(timeInterval: moveTimeInterval, repeats: true, block: { (timer) in
            self.moveDrones()
        })
        self.timer?.fire()
    }

    func prepareNewGame() {

        let continueBlock = {
            self.winHasOccured = false
            self.positionDronesAndTreasureInGrid()
            self.showNewGameAlert()
        }

        guard winHasOccured == true else {
            continueBlock()
            return
        }
        var paths = Set<IndexPath>((droneA?.path)!)
        paths = paths.union((droneB?.path)!)
        droneA?.path = Path()
        droneB?.path = Path()
        self.collectionView.performBatchUpdates({ 
            self.collectionView?.reloadItems(at: Array(paths))
            }) { (finished) in
                continueBlock()
        }

    }

    func showNewGameAlert() {
        self.operationQueue.addOperation {
            DispatchQueue.main.async {
                let newGameAlertController = UIAlertController(title: nil, message: "Tap on the start button and the drone treasure hunt will begin", preferredStyle: .alert)

                let startAction = UIAlertAction(title: "Start", style: .default) { (action) in
                    self.startMatch()
                }
                newGameAlertController.addAction(startAction)

                self.present(newGameAlertController, animated: true, completion: nil)
            }
        }
    }

    //MARK: preparation to the game
    func populateIndexPathsArray() {
        populateCornerIndexPaths()
        populateNonCornerIndexPath()
    }

    func populateCornerIndexPaths() {
        // the assumption here is that we are dealing with an equal number of
        // rows and columns
        let topLeft = IndexPath(row: 0, section: 0)
        let topRight = IndexPath(row: rowsNumber - 1, section: 0)
        let bottomLeft = IndexPath(row: (rowsNumber-1)*rowsNumber, section: 0)
        let bottomRight = IndexPath(row: (rowsNumber + 1)*(rowsNumber - 1), section: 0)
        cornerIndexPaths = [topLeft, topRight, bottomLeft, bottomRight]
    }

    func populateNonCornerIndexPath() {
        (1..<colsNumber*rowsNumber).forEach { (idx) in
            let indexPath = self.indexPath(with: idx)
            if !cornerIndexPaths.contains(indexPath) {
                nonCornerIndexpaths.append(indexPath)
            }
        }
    }

    func createGameComponents() {
        droneA = Drone(with: UIImage(named: "droneA")!, position: nil, color: UIColor.orange)
        droneB = Drone(with: UIImage(named: "droneB")!, position: nil, color: UIColor.blue)
        treasure = Treasure(with: UIImage(named: "treasure")!, position: nil)
        droneAWinsCount = 0
        droneBWinsCount = 0
    }

    func computeAndAssignComponentsPosition() {
        treasure?.position = computeTreasurePosition()
        droneA?.position = computeDronePosition(with: nil)
        droneB?.position = computeDronePosition(with: droneA?.position)
    }

    func positionDronesAndTreasureInGrid() {
        guard let droneA = droneA,
                let droneB = droneB,
                let treasure = treasure else {
                    assert(false)
            return
        }
        computeAndAssignComponentsPosition()
        self.operationQueue.addOperation {
            DispatchQueue.main.async {
                droneA.put(in: self.view(at: droneA.position!))
            }
        }
        self.operationQueue.addOperation {
            DispatchQueue.main.async {
                droneB.put(in: self.view(at: droneB.position!))
            }
        }
        self.operationQueue.addOperation {
            DispatchQueue.main.async {
                treasure.put(in: self.view(at: treasure.position!))
            }
        }
        self.operationQueue.addOperation {
            DispatchQueue.main.async {
                self.view.layoutIfNeeded()
            }
        }
    }

    func computeTreasurePosition() -> IndexPath {
        let index = Int(arc4random_uniform(UInt32(nonCornerIndexpaths.count)))
        return nonCornerIndexpaths[index]
    }

    func computeDronePosition(with opponentPosition: IndexPath?) -> IndexPath {
        var availableCornerIndexPaths = cornerIndexPaths
        if let opponentPosition = opponentPosition {
            availableCornerIndexPaths = cornerIndexPaths.filter { (indexPath) -> Bool in
                return !(indexPath == opponentPosition)
            }
        }
        let index = Int(arc4random_uniform(UInt32(availableCornerIndexPaths.count)))
        let droneAIndexPath = availableCornerIndexPaths[index]
        return droneAIndexPath
    }

    func opponent(of drone:Drone) -> Drone {
        if drone === droneA {
            return droneB!
        }
        return droneA!
    }

    func view(at indexPath: IndexPath) -> UIView {
        return tileCollectionViewCell(at: indexPath).tilePaintView
    }

    func move(drone: Drone) {
        let opponentDrone = opponent(of: drone)
        let currentPosition = drone.position
        let nextPosition = self.getNextPosition(for: drone, withforbiddenPath: opponentDrone.path)
        drone.position = nextPosition
        self.collectionView.reloadItems(at: [currentPosition!])
        drone.move(to: self.view(at: nextPosition))
    }

    //MARK: drone movement logic
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
            return indexpath == treasure!.position
        }.first
        if let winningMove = winningMove {
            return winningMove
        }
        let nextIndex = Int(arc4random_uniform(UInt32(possibleMoves.count)))
        let newMove = possibleMoves[nextIndex]

        return newMove
    }

    func checkWin() {
        var message = ""
        if droneA?.position == treasure!.position {
            message = "droneA won"
            droneAWinsCount += 1
            winHasOccured = true
        }
        if droneB?.position == treasure!.position  {
            message = "droneB won"
            droneBWinsCount += 1
            winHasOccured = true
        }
        if winHasOccured {
            let alertController = UIAlertController(title: "Win!!!!", message: message, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "New hunt", style: .default, handler: { (action) in
                self.prepareNewGame()
            })
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func moveDrones() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            let checkWinClosure = {
                if self.winHasOccured {
                    return
                }
            }
            self.operationQueue.addOperation({
                checkWinClosure()
                DispatchQueue.main.sync {
                    self.move(drone: self.droneA!)
                }
            })
            self.operationQueue.addOperation({
                checkWinClosure()
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

    //MARK: Utility methods
    func indexPath(with row: Int) -> IndexPath {
        assert(row >= 0)
        return IndexPath(row: row, section: 0)
    }

    func index(from row: Int) -> Int {
        return row % rowsNumber
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout -
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
        cell.tilePaintView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
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
