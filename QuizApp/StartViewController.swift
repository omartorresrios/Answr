//
//  StartViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 9/21/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jeremyGif = UIImage.gifImageWithName(name: "chicken")
        imageView = UIImageView(image: jeremyGif)
        imageView.frame = CGRect(x: (view.frame.size.width / 2) - 50, y: (view.frame.size.height / 2) - 50, width: 100.0, height: 100.0)
        view.addSubview(imageView)

        navigationController?.navigationBar.isTranslucent = true
        
        loginButton.setBackgroundImage(self.image(color: UIColor(colorLiteralRed: 150/255.0, green: 69/255.0, blue: 200/255.0, alpha: 1)), for: .highlighted)
        loginButton.clipsToBounds = true
        
        signupButton.setBackgroundImage(self.image(color: UIColor(colorLiteralRed: 84/255.0, green: 116/255.0, blue: 202/255.0, alpha: 1)), for: .highlighted)
        signupButton.clipsToBounds = true

    }
    
    func image(color: UIColor) -> UIImage {
        let rect = CGRect(x: CGFloat(0.0), y: CGFloat(0.0), width: CGFloat(1.0), height: CGFloat(1.0))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 255/255.0, green: 219/255.0, blue: 81/255.0, alpha: 1.0)
        
        loginButton.backgroundColor = UIColor(colorLiteralRed: 150/255.0, green: 69/255.0, blue: 249/255.0, alpha: 1)
        loginButton.layer.cornerRadius = 30
        signupButton.backgroundColor = UIColor(colorLiteralRed: 84/255.0, green: 116/255.0, blue: 251/255.0, alpha: 1)
        signupButton.layer.cornerRadius = 30
        
        // Hide the top toolbar
        navigationController?.isNavigationBarHidden = true
        
//        //list of Images in array
//        let image : NSArray = [ UIImage(named: "14")!,
//                                UIImage(named: "15")!,
//                                UIImage(named: "16")!,
//                                UIImage(named: "17")!,
//                                UIImage(named: "29")!,
//                                UIImage(named: "19")!,
//                                UIImage(named: "24")!]
//
//        //random image generating method
//        let imagerange: UInt32 = UInt32(image.count)
//        let randomimage = Int(arc4random_uniform(imagerange))
//        let generatedimage: AnyObject = image.object(at: randomimage) as AnyObject
//        self.backgroundImage.image = generatedimage as? UIImage

        self.backgroundImage.backgroundColor = UIColor(colorLiteralRed: 21/255, green: 216/255, blue: 161/255, alpha: 1)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
