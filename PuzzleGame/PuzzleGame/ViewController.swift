//
//  ViewController.swift
//  PuzzleGame
//
//  Created by Nignesh on 2016-12-15.
//  Copyright © 2016 patel.nignesh2108@gmail.com. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet var viewBoard: UIView!
    var tileWidth : CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        createUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK:- split puzzle image in 16 pieces
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
    
    func createUI() {
        
        let tileArray = splitPuzzleImage();
        if tileArray == nil || tileArray?.count == 0 { return }
        
        //Add time to viewboard
        var x : CGFloat = 0; var y : CGFloat = 0
        for i in 0...(tileArray?.count)!-1 {
            
            if i%4 == 0 && i != 0 {
                x = 0; y = y + tileWidth
            }
            
            let tileImage = tileArray?[i] as! UIImage
            
            let tile : UIImageView = UIImageView(frame: CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: tileWidth, height: tileWidth)))
            tile.image = tileImage
            tile.tag = i
            tile.contentMode = .scaleAspectFit
            
            viewBoard.addSubview(tile)
            x = x + tileWidth
        }
        
        //Remove random tile
        let random = arc4random_uniform(16)
        
        let randomImage = viewBoard.viewWithTag(Int(random)) as! UIImageView
        randomImage.removeFromSuperview()
    }
    
//    func imageWithImage(image:UIImage) -> UIImage{
//        
//        let rect = AVMakeRect(aspectRatio: (image.size), insideRect: viewBoard.frame)
//        
//        let hasAlpha = false
//        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
//        
//        UIGraphicsBeginImageContextWithOptions(rect.size, !hasAlpha, scale)
//        image.draw(in: rect)
//        
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return newImage!
//    }
}


extension UIImage {
    
    
}
