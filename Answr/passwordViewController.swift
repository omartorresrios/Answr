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
            button.backgroundColor = UIColor(colorLiteralRed: 21/255.0, green: 216/255.0, blue: 161/255.0, alpha: 1)
        } else {
            button.isUserInteractionEnabled = false
            button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        }
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(gesture:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
        
        button.setBackgroundImage(self.image(color: UIColor(colorLiteralRed: 21/255.0, green: 190/255.0, blue: 161/255.0, alpha: 1)), for: .highlighted)
        button.clipsToBounds = true
        
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
    
    @IBAction func handleButton(_ sender: AnyObject) {
        if (sender as! UITextField).text!.characters.count < 8 {
            button.isUserInteractionEnabled = false
            button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        } else {
            button.isUserInteractionEnabled = true
            button.backgroundColor = UIColor(colorLiteralRed: 21/255.0, green: 216/255.0, blue: 161/255.0, alpha: 1)
        }
        if (sender as! UITextField).text!.characters.count > 0 {
            self.showHideButton.alpha = 1
            self.showHideButton.setTitle("Mostrar", for: (.normal))
        } else {
            self.showHideButton.alpha = 0
        }
    }
    
    @IBAction func goToEmailView(_ sender: AnyObject) {
            
        if passwordV3.text!.characters.count > 8 { // Valid email
            
            // Passing data to the next view (emailVC)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let emailViewcontroller = storyboard.instantiateViewController(withIdentifier: "EmailVC") as! emailViewController
            emailViewcontroller.firstNameV4 = self.firstNameV3
            emailViewcontroller.usernameV4 = self.usernameV3
            emailViewcontroller.passwordV4 = self.passwordV3
            self.navigationController!.pushViewController(emailViewcontroller, animated: true)
                
        } else { // Invalid email
                
            self.messageLabel.text = "Muy simple. Mínimo 8 caracteres!"
            self.messageLabel.textColor = UIColor.red
            button.isUserInteractionEnabled = false
            button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
                
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
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        passwordV3.resignFirstResponder()
        return true
    }
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
