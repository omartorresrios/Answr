//
//  LoginViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 9/17/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton! {
        didSet {
            loginButton.layer.cornerRadius = 15
        }
    }
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    
    var authService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loader.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor.white
        
        emailTextField.becomeFirstResponder()
                
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(LoginViewController.textFieldDidChange(_:)), for: .editingChanged)
        
        if emailTextField.text!.characters.count > 0 && passwordTextField.text!.characters.count > 0 {
            loginButton.isUserInteractionEnabled = true
            loginButton.backgroundColor = UIColor(colorLiteralRed: 21/255.0, green: 216/255.0, blue: 161/255.0, alpha: 1)
        }
        else {
            loginButton.isUserInteractionEnabled = false
            loginButton.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.makeTheChange), name: NSNotification.Name(rawValue: "theChange"), object: nil)
        
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(gesture:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
        
        loginButton.setBackgroundImage(self.image(color: UIColor(colorLiteralRed: 21/255.0, green: 190/255.0, blue: 161/255.0, alpha: 1)), for: .highlighted)
        loginButton.clipsToBounds = true
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
    
    func makeTheChange() {
        self.loader.stopAnimating()
        self.messageLabel.text = "No es la contraseña correcta. ¡Lo sentimos!"
        self.messageLabel.textColor = UIColor.red
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "theChange"), object: nil)
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespaces)
        let password = passwordTextField.text!
        
        if finalEmail.characters.count > 0 && password.characters.count > 0 {
            loginButton.isUserInteractionEnabled = true
            loginButton.backgroundColor = UIColor(colorLiteralRed: 21/255.0, green: 216/255.0, blue: 161/255.0, alpha: 1)
            self.messageLabel.text = ""
        }
        else {
            loginButton.isUserInteractionEnabled = false
            loginButton.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        }
    }
    
    override func viewDidLayoutSubviews() {
        // Bottom line to emailTextField
        let borderBottomEmail = CALayer()
        let borderWidthEmail = CGFloat(2.0)
        borderBottomEmail.borderColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1).cgColor
        borderBottomEmail.frame = CGRect(x: 0, y: emailTextField.frame.height - 1.0, width: emailTextField.frame.width , height: emailTextField.frame.height - 1.0)
        borderBottomEmail.borderWidth = borderWidthEmail
        emailTextField.layer.addSublayer(borderBottomEmail)
        emailTextField.layer.masksToBounds = true
        
        // Bottom line to passwordTextField
        let borderBottomPass = CALayer()
        let borderWidthPass = CGFloat(2.0)
        borderBottomPass.borderColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1).cgColor
        borderBottomPass.frame = CGRect(x: 0, y: passwordTextField.frame.height - 1.0, width: passwordTextField.frame.width , height: passwordTextField.frame.height - 1.0)
        borderBottomPass.borderWidth = borderWidthPass
        passwordTextField.layer.addSublayer(borderBottomPass)
        passwordTextField.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        navigationController?.isNavigationBarHidden = false
        
    }

    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func loginAction(_ sender: AnyObject) {
        self.loader.startAnimating()
        let email = emailTextField.text!.lowercased()
        let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespaces)
        let password = passwordTextField.text!
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        if emailTest.evaluate(with: emailTextField.text!) == true { // Valid email
        
            self.databaseRef.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: emailTextField.text!)
                .observe(.value, with: { snapshot in
                    
                    if snapshot.exists() {
                        
                        self.authService.signIn(finalEmail, password: password)
                        
                    } else {
                        self.loader.stopAnimating()
                        self.messageLabel.text = "No podemos encontrar una cuenta con ese correo."
                        self.messageLabel.textColor = UIColor.red
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
            }
            
        } else { // Invalid email
            self.loader.stopAnimating()
            self.messageLabel.text = "Introduce un correo válido por favor."
            self.messageLabel.textColor = UIColor.red
            
        }
        
        // Hide keyboard
        dismissKeyboard()
    }
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
