//
//  firstNameViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 26/12/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit

class firstNameViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameV1: UITextField!
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.layer.cornerRadius = 15
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameV1.becomeFirstResponder()
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.topItem?.title = ""
        
        if firstNameV1.text!.characters.count > 0 {
            button.isUserInteractionEnabled = true
            button.backgroundColor = UIColor(colorLiteralRed: 12/255.0, green: 206/255.0, blue: 107/255.0, alpha: 1)
        } else {
            button.isUserInteractionEnabled = false
            button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        }
        
    }
    
    @IBAction func handleButton(_ sender: AnyObject) {
        if (sender as! UITextField).text!.characters.count > 0 {
            button.isUserInteractionEnabled = true
            button.backgroundColor = UIColor(colorLiteralRed: 12/255.0, green: 206/255.0, blue: 107/255.0, alpha: 1)
        } else {
            button.isUserInteractionEnabled = false
            button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        // Bottom line to firstNameTextField
        let borderBottomName = CALayer()
        let borderWidthName = CGFloat(2.0)
        borderBottomName.borderColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1).cgColor
        borderBottomName.frame = CGRect(x: 0, y: firstNameV1.frame.height - 1.0, width: firstNameV1.frame.width , height: firstNameV1.frame.height - 1.0)
        borderBottomName.borderWidth = borderWidthName
        firstNameV1.layer.addSublayer(borderBottomName)
        firstNameV1.layer.masksToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goUsernameView" {
            let showUsernameView = segue.destination as! usernameViewController
            showUsernameView.firstNameV2 = self.firstNameV1
        }
    }
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}
