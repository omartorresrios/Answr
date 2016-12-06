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
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 255/255.0, green: 219/255.0, blue: 81/255.0, alpha: 1.0)
        
        loginButton.backgroundColor = UIColor(colorLiteralRed: 239/255.0, green: 71/255.0, blue: 86/255.0, alpha: 1)
        loginButton.layer.cornerRadius = 30
        signupButton.backgroundColor = UIColor(colorLiteralRed: 12/255.0, green: 206/255.0, blue: 107/255.0, alpha: 1)
        signupButton.layer.cornerRadius = 30
        
        // Hide the top toolbar
        navigationController?.isNavigationBarHidden = true
        
        //list of Images in array
        let image : NSArray = [ UIImage(named: "14")!,
                                UIImage(named: "15")!,
                                UIImage(named: "16")!,
                                UIImage(named: "17")!,
                                UIImage(named: "29")!,
                                UIImage(named: "19")!,
                                UIImage(named: "24")!]

        //random image generating method
        let imagerange: UInt32 = UInt32(image.count)
        let randomimage = Int(arc4random_uniform(imagerange))
        let generatedimage: AnyObject = image.object(at: randomimage) as AnyObject
        self.backgroundImage.image = generatedimage as? UIImage
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
