//
//  TermsOfServiceViewController.swift
//  Answr
//
//  Created by Omar Torres on 1/02/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit

class TermsOfServiceViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(colorLiteralRed: 21/255.0, green: 216/255.0, blue: 161/255.0, alpha: 1), NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    @IBAction func comeBackAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

}
