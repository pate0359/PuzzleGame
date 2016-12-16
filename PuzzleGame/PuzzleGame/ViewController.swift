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
    private var blankTileCenter : CGPoint!
    
    private var leftTiles = NSMutableArray(capacity: 3)
    private var rightTiles = NSMutableArray(capacity: 3)
    private var topTiles = NSMutableArray(capacity: 3)
    private var bottomTiles = NSMutableArray(capacity: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        createUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


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
    
    // Create a board with the 15 tiles and shuffle them
    private func createUI() {
        
        let tileArray = splitPuzzleImage();
        if tileArray == nil || tileArray?.count == 0 { return }
        
        //random tile to be removed and assign as black tile
        var random : Int = Int(arc4random_uniform(16))
        
        //Shuffle array
        //tileArray?.shuffle()
        
        //Add time to viewboard
        var x : CGFloat = 0; var y : CGFloat = 0
        
        for i in 0...(tileArray?.count)!-1 {
            
            if i%4 == 0 && i != 0 {
                x = 0; y = y + tileWidth
            }

            if i != random {
            
                let tileImage = tileArray?[i] as! UIImage
                let tile : UIImageView = UIImageView(frame: CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: tileWidth, height: tileWidth)))
                tile.image = tileImage
                tile.isUserInteractionEnabled = true
                tile.layer.borderWidth = 0.5
                tile.layer.borderColor = UIColor.white.cgColor
                
                //Add tap gesture
                let tap = UITapGestureRecognizer(target: self, action:#selector(self.handleTap(recognizer:)))
                tap.delegate = self
                tile.addGestureRecognizer(tap)
                viewBoard.addSubview(tile)
                
            }else{
                
                //blank tile location
                blankTileCenter = CGPoint(x: x + tileWidth/2, y: y + tileWidth/2)
            }
            
            x = x + tileWidth
        }
        
        calculateNeighbours()
    }
    
    func calculateNeighbours()  {
        
        print("blankTileCenter : ",blankTileCenter)
        
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
        
//        print("leftTiles : ",leftTiles.count)
//        print("rightTiles : ",rightTiles.count)
//        print("topTiles : ",topTiles.count)
//        print("bottomTiles : ",bottomTiles.count)
        
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
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        
        let view = recognizer.view
        if(view == nil) { return }
        
        let tapTileCenter = view?.center
        
        if leftTiles.containsView(tile: view!){
            
            for item in leftTiles {
                
                let item = item as! UIImageView
                
                var center = item.center
                center.x += tileWidth
                item.center = center
                
                if (item.center == view?.center){
                    
                    blankTileCenter = tapTileCenter
                    break
                }
            }
        }
        
        if rightTiles.containsView(tile: view!){
            
            for item in rightTiles {
                
                let item = item as! UIImageView
                
                var center = item.center
                center.x -= tileWidth
                item.center = center
                
                if (item.center == view?.center){
                    
                    blankTileCenter = tapTileCenter
                    break
                }
            }
        }
        
        if topTiles.containsView(tile: view!){
            
            for item in topTiles {
                
                let item = item as! UIImageView
                
                var center = item.center
                center.y += tileWidth
                item.center = center
                
                if (item.center == view?.center){
                    
                    blankTileCenter = tapTileCenter
                    break
                }
            }
        }
        
        if bottomTiles.containsView(tile: view!){
            
            for item in bottomTiles {
                
                let item = item as! UIImageView
                
                var center = item.center
                center.y -= tileWidth
                item.center = center
                
                if (item.center == view?.center){
                    
                    blankTileCenter = tapTileCenter
                    break
                }
            }
        }
        
        // Recalculate emty tile's neighbours
        calculateNeighbours()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
