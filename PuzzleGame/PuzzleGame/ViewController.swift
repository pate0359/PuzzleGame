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
    
    var tileWidth : CGFloat!
    var blankTileCenter : CGPoint!

    private var blankTileInitialCenter : CGPoint!
    private var arrayTileImages : NSArray!
    private var arrayTiles = NSMutableArray()
    private var arrayTileCenters = NSMutableArray()
    
    //To store initial tile centers to check win
    private var dictCentersForTile = [Int : AnyObject]()
    
    // Neighbour tiles of empty tile
    var leftTiles = NSMutableArray(capacity: 3)
    var rightTiles = NSMutableArray(capacity: 3)
    var topTiles = NSMutableArray(capacity: 3)
    var bottomTiles = NSMutableArray(capacity: 3)
    
    //Touchended is not called sometimes due to tap gesture on tile. work around to saperate touches event and tap guesture event
    var isMoving : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        arrayTileImages = splitPuzzleImage();
        if arrayTileImages == nil || arrayTileImages?.count == 0 { return }
        
        //create tile board ui
        resetBoard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Action methods
    @IBAction func resetGameClicked(_ sender: AnyObject) {
        
        //reset tile board
        resetBoard()
    }

    //MARK:- Split tiles
    
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
    
    //MARK:- UI methods
    
    //Reset tile board
    private func resetBoard() {
        
        //Remove previous tiles
        for item in viewBoard.subviews {
            item.removeFromSuperview()
        }
        
        arrayTiles.removeAllObjects()
        arrayTileCenters.removeAllObjects()
        
        //create tile board ui
        self.createUI(tileArray: self.arrayTileImages!)
    }
    
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
            tap.delaysTouchesBegan = false
            tap.delaysTouchesEnded = false
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
        
        //Initialize blank tile center
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
    
    //MARK:- UIGestureRecognizerDelegate method
    func handleTap(recognizer: UITapGestureRecognizer) {

        let view = recognizer.view
        if(view == nil) { return }
        
        //move tile
        moveTile(view: view!, tapped: !isMoving)
    }
    
    //MARK:- move and win logic
    // Move tile
    func moveTile(view : UIView, tapped:Bool) {
        
        if leftTiles.containsView(tile: view){
            
            var count : Int = 0
            var cgFloatX : CGFloat = 0
            var isMoved : Bool = true

            for item in leftTiles {
                
                let item = item as! UIImageView
                var center = item.center
                
                if (!tapped){
                    if count == 0 {

                        if  blankTileCenter.x - center.x < tileWidth/2{
                            // Update new postion
                            cgFloatX =  CGFloat((Int(center.x/tileWidth) + 1)) * tileWidth - tileWidth/2
                            isMoved = true
                        }else{
                            // back to original position
                            cgFloatX = CGFloat((Int(center.x/tileWidth))) * tileWidth + tileWidth/2
                            isMoved = false
                        }
                    }else{
                        
                        cgFloatX = cgFloatX - tileWidth
                    }
                }else{
                 
                    cgFloatX = center.x + tileWidth
                }
        
                center.x = cgFloatX
                UIView.animate(withDuration: 0.15, animations:{
                    item.center = center
                })

                count += 1
                
                //Update blank tile
                if item.center == view.center{
                    
                    // Don't update blank tile center if tile is back to position
                    if isMoved {
                        var blankCenter = blankTileCenter
                        blankCenter?.x = cgFloatX - tileWidth
                        blankTileCenter = blankCenter
                    }
                    break
                }
            }
        }
        
        if rightTiles.containsView(tile: view){
            
            var count : Int = 0
            var cgFloatX : CGFloat = 0
            var isMoved : Bool = true
            
            for item in rightTiles {
                
                let item = item as! UIImageView
                var center = item.center
                
                if (!tapped){
                    if count == 0 {
                        if  center.x - blankTileCenter.x < tileWidth/2{
                            // Update new postion
                            cgFloatX =  CGFloat((Int(center.x/tileWidth) + 1)) * tileWidth - tileWidth/2
                            isMoved = true
                        }else{
                            // back to original position
                            cgFloatX = CGFloat((Int(center.x/tileWidth))) * tileWidth + tileWidth/2
                            isMoved = false
                        }
                    }else{
                        cgFloatX = cgFloatX + tileWidth
                    }
                }else{
                    cgFloatX = center.x - tileWidth
                }

                center.x = cgFloatX
                UIView.animate(withDuration: 0.15, animations:{
                    item.center = center
                })
                
                count += 1
                
                //Update blank tile
                if item.center == view.center{
                    
                    // Don't update blank tile center if tile is back to position
                    if isMoved {
                        var blankCenter = blankTileCenter
                        blankCenter?.x = cgFloatX + tileWidth
                        blankTileCenter = blankCenter
                    }
                    break
                }
            }
        }
        
        if topTiles.containsView(tile: view){
            
            var count : Int = 0
            var cgFloatY : CGFloat = 0
            var isMoved : Bool = true
            
            for item in topTiles {
                
                let item = item as! UIImageView
                var center = item.center
                
                if (!tapped){
                    if count == 0 {
                        if  blankTileCenter.y - center.y < tileWidth/2{
                            // Update new postion
                            cgFloatY =  CGFloat((Int(center.y/tileWidth) + 1)) * tileWidth - tileWidth/2
                            isMoved = true
                        }else{
                            // back to original position
                            cgFloatY = CGFloat((Int(center.y/tileWidth))) * tileWidth + tileWidth/2
                            isMoved = false
                        }
                    }else{
                        cgFloatY = cgFloatY - tileWidth
                    }
                }else{
                    cgFloatY = center.y + tileWidth
                }
                
                center.y = cgFloatY
                UIView.animate(withDuration: 0.15, animations:{
                    item.center = center
                })
                
                count += 1
                
                //Update blank tile
                if item.center == view.center{
                    
                    // Don't update blank tile center if tile is back to position
                    if isMoved {
                        var blankCenter = blankTileCenter
                        blankCenter?.y = cgFloatY - tileWidth
                        blankTileCenter = blankCenter
                    }
                    break
                }
            }
        }
        
        if bottomTiles.containsView(tile: view){
            
            var count : Int = 0
            var cgFloatY : CGFloat = 0
            var isMoved : Bool = true
            
            for item in bottomTiles {
                
                let item = item as! UIImageView
                var center = item.center
                
                if (!tapped){
                    if count == 0 {
                        if  center.y - blankTileCenter.y < tileWidth/2{
                            // Update new postion
                            cgFloatY =  CGFloat((Int(center.y/tileWidth) + 1)) * tileWidth - tileWidth/2
                            isMoved = true
                        }else{
                            // back to original position
                            cgFloatY = CGFloat((Int(center.y/tileWidth))) * tileWidth + tileWidth/2
                            isMoved = false
                        }
                    }else{
                        cgFloatY = cgFloatY + tileWidth
                    }
                }else{
                    cgFloatY = center.y - tileWidth
                }
                
                center.y = cgFloatY
                UIView.animate(withDuration: 0.15, animations:{
                    item.center = center
                })
                
                count += 1
                
                //Update blank tile
                if item.center == view.center{
                    // Don't update blank tile center if tile is back to position
                    if isMoved {
                        var blankCenter = blankTileCenter
                        blankCenter?.y = cgFloatY + tileWidth
                        blankTileCenter = blankCenter
                    }
                    break
                }
            }
        }
        
        //Check for win
        self.perform(#selector(self.checkForWin), with: nil, afterDelay: 0.5)
        
        //print("after move : \(blankTileCenter)")
        
        // Recalculate empty tile's neighbours
        calculateNeighbours()
    }
    
    func checkForWin() {
        
        //Check for win
        if isWon(){
            
            let alertController = UIAlertController(title:"YOU WIN!!", message:"", preferredStyle: .alert)
            let replay = UIAlertAction(title: "Play Again", style: .default) { (action) in
                
                self.resetBoard()
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


//MARK:- Touch events

extension ViewController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMoving = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        isMoving = true
        
        if let touch = touches.first{
            
            let location = touch.location(in: viewBoard)
            let view = touch.view
            
            let  xVal = location.x - (view?.center.x)!
            let  yVal = location.y - (view?.center.y)!
            
            if leftTiles.containsView(tile: view!){
                
                if xVal < 0 {  // left move not allowed
                    return
                }
                
                var preItemCenter : CGPoint = blankTileCenter
                
                for item in leftTiles {

                    let item = item as! UIImageView
                    
                    var center = item.center
                    center.x = (center.x + xVal >= preItemCenter.x) ? preItemCenter.x : center.x + xVal
                    item.center = center
                    
                    preItemCenter.x -= tileWidth
                    
                    if item.center == view?.center{
                        break
                    }
                }
            }
            
            if rightTiles.containsView(tile: view!){
                
                if xVal > 0 {  // right move not allowed
                    return
                }
                
                var preItemCenter : CGPoint = blankTileCenter
                for item in rightTiles {
                    
                    let item = item as! UIImageView
                    
                    var center = item.center
                    center.x = (center.x + xVal <= preItemCenter.x) ? preItemCenter.x : center.x + xVal
                    item.center = center
                    
                    preItemCenter.x += tileWidth
                    
                    if item.center == view?.center{
                        break
                    }
                }
            }
            
            if topTiles.containsView(tile: view!){
                
                if yVal < 0 {  // up move not allowed
                    return
                }
                
                var preItemCenter : CGPoint = blankTileCenter
                for item in topTiles {
                    
                    let item = item as! UIImageView
                    
                    var center = item.center
                    center.y = (center.y + yVal >= preItemCenter.y) ? preItemCenter.y : center.y + yVal
                    item.center = center
                    
                    preItemCenter.y -= tileWidth
                    
                    if item.center == view?.center{
                        break
                    }
                }
            }
            
            if bottomTiles.containsView(tile: view!){
                
                if yVal > 0 {  // down move not allowed
                    return
                }
                
                var preItemCenter : CGPoint = blankTileCenter
                for item in bottomTiles {
                    
                    let item = item as! UIImageView
                    
                    var center = item.center
                    center.y = (center.y + yVal <= preItemCenter.y) ? preItemCenter.y : center.y + yVal
                    item.center = center
                    
                    preItemCenter.y += tileWidth
                    
                    if item.center == view?.center{
                        break
                    }
                }
            }
        }
        
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        isMoving = false
        
        if let touch = touches.first{

            let view = touch.view
            //move tile
            moveTile(view: view!, tapped: isMoving)
        }
        super.touchesEnded(touches, with: event)
    }
}
