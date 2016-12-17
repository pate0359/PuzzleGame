//
//  ViewController.swift
//  PuzzleGame
//
//  Created by Nignesh on 2016-12-15.
//  Copyright © 2016 patel.nignesh2108@gmail.com. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet var viewBoard: UIView!
    
    private var tileWidth : CGFloat!
    private var blankTileInitialCenter : CGPoint!
    private var blankTileCenter : CGPoint!
    
    
    private var arrayTileImages : NSArray!
    private var arrayTiles = NSMutableArray()
    private var arrayTileCenters = NSMutableArray()
    
    //For saving initial tile centers
    private var dictCentersForTile = [Int : AnyObject]()
    
    // Neighbour tiles of empty tile
    private var leftTiles = NSMutableArray(capacity: 3)
    private var rightTiles = NSMutableArray(capacity: 3)
    private var topTiles = NSMutableArray(capacity: 3)
    private var bottomTiles = NSMutableArray(capacity: 3)
    
    private var touchbeginPoint : CGPoint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        arrayTileImages = splitPuzzleImage();
        if arrayTileImages == nil || arrayTileImages?.count == 0 { return }
        
        createUI(tileArray: arrayTileImages!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- Private Methods
    
    // Split puzzle image in 16 pieces
    private func splitPuzzleImage() -> NSMutableArray? {
        
        let puzzleImage = UIImage(named: "puzzle_image");
        if (puzzleImage == nil) { return nil}
        //puzzleImage = imageWithImage(image: puzzleImage!)
        
        let arraCroppedImages : NSMutableArray = NSMutableArray()
        tileWidth = puzzleImage!.size.width as CGFloat / 2
        
        for i in 0...3{
            for j in 0...3{
                
                let imageRef = puzzleImage!.cgImage!.cropping(to: CGRect(origin: CGPoint(x: CGFloat(j) * tileWidth, y: tileWidth * CGFloat(i)), size: CGSize(width: tileWidth, height: tileWidth)))
                
                let image = UIImage(cgImage: imageRef!, scale: puzzleImage!.scale, orientation: puzzleImage!.imageOrientation)
                arraCroppedImages.add(image)
            }
        }
        return arraCroppedImages
    }
    
    //MARK:- UI Methods
    // Create a board with the 15 tiles and shuffle them
    private func createUI(tileArray:NSArray) {
        
        //Reset board
        resetBoard()
        
        //Add time to viewboard
        var x : CGFloat = 0; var y : CGFloat = 0
        
        for i in 0...(tileArray.count)-1 {
            
            if i%4 == 0 && i != 0 {
                x = 0; y = y + tileWidth
            }
            
            let tileImage = tileArray[i] as! UIImage
            let tile : UIImageView = UIImageView(frame: CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: tileWidth, height: tileWidth)))
            tile.image = tileImage
            tile.isUserInteractionEnabled = true
            tile.layer.borderWidth = 0.25
            tile.layer.borderColor = UIColor.white.cgColor
            tile.tag = i + 1
            
            //Add tap gesture
            let tap = UITapGestureRecognizer(target: self, action:#selector(self.handleTap(recognizer:)))
            tap.delegate = self
            tile.addGestureRecognizer(tap)
            viewBoard.addSubview(tile)
            
            arrayTiles.add(tile)
            arrayTileCenters.add(tile.center)
            
            dictCentersForTile[i+1] = tile.center as AnyObject?
            
            x = x + tileWidth
        }
        
        //remove random tile
        let random : Int = Int(arc4random_uniform(16))
        
        (arrayTiles[random] as! UIImageView).removeFromSuperview()
        arrayTiles.removeObject(at: random)
        
        blankTileCenter = arrayTileCenters[random] as! CGPoint
        blankTileInitialCenter = arrayTileCenters[random] as! CGPoint
        
        arrayTileCenters.removeObject(at: random)
        
        //Randomize tiles
        randomizeTiles();
    }
    
    func randomizeTiles() {
        
        let centersCopy : NSMutableArray = arrayTileCenters.mutableCopy() as! NSMutableArray
        
        for item in arrayTiles {
            
            let item = item as! UIImageView
            let random : Int = Int(arc4random_uniform(UInt32(centersCopy.count)))
            
            let randCenter : CGPoint = centersCopy[random] as! CGPoint
            item.center = randCenter
            
            centersCopy.removeObject(at: random)
        }
        
        //Calculate neighbour
        calculateNeighbours()
    }
    
    //MARK:- Reset board
    private func resetBoard() {
        
        //Remove previous tiles
        for item in viewBoard.subviews {
            item.removeFromSuperview()
        }
        
        arrayTiles.removeAllObjects()
        arrayTileCenters.removeAllObjects()
    }
    
    //MARK:- UIGestureRecognizerDelegate method
    func handleTap(recognizer: UITapGestureRecognizer) {
        
        let view = recognizer.view
        if(view == nil) { return }
        
        //move tile
        move(view: view!, tapped: true)
    }
    
    //MARK:- Move and Win Logic
    
    // Move tile
    func move(view : UIView, tapped:Bool) {
        
        let tapTileCenter = view.center
        
        if leftTiles.containsView(tile: view){
            
            for item in leftTiles {
                
                let item = item as! UIImageView
                
                var center = item.center
                center.x += tileWidth
                
                UIView.animate(withDuration: 0.15, animations:{
                    item.center = center
                })
                
                if (item.center == view.center){
                    
                    if (tapped){ blankTileCenter = tapTileCenter }
                    break
                }
            }
        }
        
        if rightTiles.containsView(tile: view){
            
            for item in rightTiles {
                
                let item = item as! UIImageView
                
                var center = item.center
                center.x -= tileWidth
                UIView.animate(withDuration: 0.15, animations:{
                    item.center = center
                })
                
                if (item.center == view.center){
                    
                    if (tapped){ blankTileCenter = tapTileCenter }
                    break
                }
            }
        }
        
        if topTiles.containsView(tile: view){
            
            for item in topTiles {
                
                let item = item as! UIImageView
                
                var center = item.center
                center.y += tileWidth
                UIView.animate(withDuration: 0.15, animations:{
                    item.center = center
                })
                
                if (item.center == view.center){
                    
                    if (tapped){ blankTileCenter = tapTileCenter }
                    break
                }
            }
        }
        
        if bottomTiles.containsView(tile: view){
            
            for item in bottomTiles {
                
                let item = item as! UIImageView
                
                var center = item.center
                center.y -= tileWidth
                UIView.animate(withDuration: 0.15, animations:{
                    item.center = center
                })
                
                if (item.center == view.center){
                    
                    if (tapped){ blankTileCenter = tapTileCenter }
                    break
                }
            }
        }
        
        self.perform(#selector(self.checkForWin), with: nil, afterDelay: 0.5)
        
        // Recalculate emty tile's neighbours
        if (tapped){  calculateNeighbours() }
    }
    
    func checkForWin() {
        
        //Check for win
        if isWon(){
            
            let alertController = UIAlertController(title:"YOU WIN!!", message:"", preferredStyle: .alert)
            let replay = UIAlertAction(title: "Play Again", style: .default) { (action) in
                
                self.createUI(tileArray: self.arrayTileImages!)
            }
            alertController.addAction(replay)
            self.present(alertController, animated: true) {}
            
            return
        }
    }
    
    //Returns true if game is won else false
    func isWon() -> Bool {
        
        var isWon = true

        for item in viewBoard.subviews {
            
            let item = item as? UIImageView
            //Compare with initial center position
            let position = dictCentersForTile[(item?.tag)!] as! CGPoint
            if position != item?.center{
                
                isWon = false
                break
            }
        }

        //Check if blank tile position is same as initial position
        if blankTileInitialCenter != blankTileCenter{
            isWon = false
        }
        return isWon
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        if let touch = touches.first{
//            
//            print("\(touch.location(in: viewBoard))")
//            
//            touchbeginPoint = touch.location(in: viewBoard)
//            
//            //touch?.view
//        }
//        super.touchesBegan(touches, with: event)
//    }
//    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        if let touch = touches.first{
//            print("\(touch.location(in: viewBoard))")
//            
////            move(view: touch.view!, tapped: true)
//        }
//        super.touchesEnded(touches, with: event)
//    }
//    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        
//        if let touch = touches.first{
//            
//            //print("\(touch)")
//            
//            let location = touch.location(in: viewBoard)
//            let view = touch.view
//            
//            
////            view?.center = location
//            
//            
//            var center = location
//            center.x = location.x
//
//            view?.center = CGPoint(x: location.x, y: (view?.center.y)!)
//
//            if leftTiles.containsView(tile: view!){
//                
//                for item in leftTiles {
//                    
//                    let item = item as! UIImageView
//
//                    var center = item.center
//                    center.x += location.x - touchbeginPoint.x
//                    item.center = center
//                    
//                    if (item.center == view?.center){
//                        
//                        //if (tapped){ blankTileCenter = tapTileCenter }
//                        break
//                    }
//                }
//            }
//        }
//        super.touchesMoved(touches, with: event)
//    }
    
    //MARK:- Calculation
    //Calculate neighbour tiles around empty tile
    func calculateNeighbours()  {
        
        leftTiles.removeAllObjects()
        rightTiles.removeAllObjects()
        topTiles.removeAllObjects()
        bottomTiles.removeAllObjects()
        
        // Left tiles
        var leftCenter : CGPoint = blankTileCenter
        while leftCenter.x - tileWidth > 0 {
            
            let left = CGPoint(x: leftCenter.x - tileWidth, y: (leftCenter.y))
            leftCenter = left
            
            let tile = getTileWithCenter(center: left)
            if(tile != nil){
                leftTiles.add(tile)
            }
        }
        
        // Right tiles
        var rightCenter : CGPoint = blankTileCenter
        while rightCenter.x + tileWidth < 4 * tileWidth {
            
            let right = CGPoint(x: rightCenter.x + tileWidth, y: (rightCenter.y))
            rightCenter = right
            
            let tile = getTileWithCenter(center: right)
            if(tile != nil){
                rightTiles.add(tile)
            }
        }
        
        // Top tiles
        var topCenter : CGPoint = blankTileCenter
        while topCenter.y - tileWidth > 0 {
            
            let top = CGPoint(x: topCenter.x, y: topCenter.y - tileWidth)
            topCenter = top
            
            let tile = getTileWithCenter(center: top)
            if(tile != nil){
                topTiles.add(tile)
            }
        }
        
        // Bottom tiles
        var bottomCenter : CGPoint = blankTileCenter
        while bottomCenter.y + tileWidth < 4 * tileWidth {
            
            let bottom = CGPoint(x: bottomCenter.x, y: bottomCenter.y + tileWidth)
            bottomCenter = bottom
            
            let tile = getTileWithCenter(center: bottom)
            if(tile != nil){
                bottomTiles.add(tile)
            }
        }
    }
    
    func getTileWithCenter(center : CGPoint) -> UIImageView? {
        
        for item in viewBoard.subviews {
            if item is UIImageView {
                
                if (item.center == center){
                    return item as? UIImageView
                }
            }
        }
        return nil
    }
}
