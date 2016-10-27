//
//  StartViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 9/21/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 255/255.0, green: 219/255.0, blue: 81/255.0, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
