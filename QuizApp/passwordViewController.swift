//
//  passwordViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 25/12/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit

class passwordViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var passwordV3: UITextField!
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var showHideButton: UIButton!
    
    var firstNameV3: UITextField!
    var usernameV3: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passwordV3.becomeFirstResponder()
        
        navigationController?.isNavigationBarHidden = false
        
        navigationController?.navigationBar.topItem?.title = ""
        
        if passwordV3.text!.characters.count > 0 {
            button.isUserInteractionEnabled = true
            button.backgroundColor = UIColor(colorLiteralRed: 12/255.0, green: 206/255.0, blue: 107/255.0, alpha: 1)
        } else {
            button.isUserInteractionEnabled = false
            button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        }
        
    }
    
    @IBAction func handleButton(_ sender: AnyObject) {
        if (sender as! UITextField).text!.characters.count < 8 {
            button.isUserInteractionEnabled = false
            button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        } else {
            button.isUserInteractionEnabled = true
            button.backgroundColor = UIColor(colorLiteralRed: 12/255.0, green: 206/255.0, blue: 107/255.0, alpha: 1)
        }
        if (sender as! UITextField).text!.characters.count > 0 {
            self.showHideButton.alpha = 1
            self.showHideButton.setTitle("Mostrar", for: (.normal))
        } else {
            self.showHideButton.alpha = 0
        }
    }
    
    @IBAction func goToEmailView(_ sender: AnyObject) {
            
        if passwordV3.text!.characters.count > 8 {
            let stricterFilterString = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}"
            let passwordTest = NSPredicate(format: "SELF MATCHES %@", stricterFilterString)
            
            if passwordTest.evaluate(with: passwordV3.text!) == true { // Valid email
                // Passing data to the next view (emailVC)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let emailViewcontroller = storyboard.instantiateViewController(withIdentifier: "EmailVC") as! emailViewController
                emailViewcontroller.firstNameV4 = self.firstNameV3
                emailViewcontroller.usernameV4 = self.usernameV3
                emailViewcontroller.passwordV4 = self.passwordV3
                self.navigationController!.pushViewController(emailViewcontroller, animated: true)
                
            } else { // Invalid email
                
                self.messageLabel.text = "Muy simple. Debe tener por lo menos 1 mayúscula y 1 número."
                self.messageLabel.textColor = UIColor.red
                button.isUserInteractionEnabled = false
                button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
                
            }
        }
    }
    
    @IBAction func showHidePassword(_ sender: AnyObject) {
        if self.passwordV3!.isSecureTextEntry == true {
            self.showHideButton.setTitle("Ocultar", for: (.normal))
            self.passwordV3!.isSecureTextEntry = false
        }
        else {
            self.showHideButton.setTitle("Mostrar", for: (.normal))
            self.passwordV3!.isSecureTextEntry = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        // Bottom line to passwordTextField
        let borderBottomName = CALayer()
        let borderWidthName = CGFloat(2.0)
        borderBottomName.borderColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1).cgColor
        borderBottomName.frame = CGRect(x: 0, y: passwordV3.frame.height - 1.0, width: passwordV3.frame.width , height: passwordV3.frame.height - 1.0)
        borderBottomName.borderWidth = borderWidthName
        passwordV3.layer.addSublayer(borderBottomName)
        passwordV3.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
