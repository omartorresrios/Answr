//
//  MainTabBarViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 22/12/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    
    
    @IBOutlet var tabB: UITabBar!
    
    override func viewWillLayoutSubviews() {
        // TabBar height
        var tabFrame = self.tabB.frame
        tabFrame.size.height = 40
        tabFrame.origin.y = self.view.frame.size.height - 40
        self.tabBar.frame = tabFrame
        
        // TabBar transparency
        tabB.backgroundImage = onePixelImageWithColor(UIColor.white)
        tabB.shadowImage = UIImage()
        
        //navigationController?.tabBarController?.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // Make UIToolbar Transparency
    func onePixelImageWithColor(_ color : UIColor) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context!.setFillColor(color.cgColor)
        context!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIImage(cgImage: context!.makeImage()!)
        return image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

