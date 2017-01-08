//
//  emailViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 25/12/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class emailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailV4: UITextField!
    @IBOutlet weak var button: UIButton! {
        didSet {
            button.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    var firstNameV4: UITextField!
    var usernameV4: UITextField!
    var passwordV4: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loader.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        emailV4.becomeFirstResponder()
        
        navigationController?.isNavigationBarHidden = false
        
        navigationController?.navigationBar.topItem?.title = ""
        
        if emailV4.text!.characters.count > 0 {
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
        if (sender as! UITextField).text!.characters.count > 0 {
            button.isUserInteractionEnabled = true
            button.backgroundColor = UIColor(colorLiteralRed: 21/255.0, green: 216/255.0, blue: 161/255.0, alpha: 1)
            self.messageLabel.text = ""
        
        } else {
            button.isUserInteractionEnabled = false
            button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        }

    }
    
    @IBAction func goToUserImageView(_ sender: AnyObject) {
        self.loader.startAnimating()
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)

        if emailTest.evaluate(with: emailV4.text!) == true { // Valid email
            
            self.databaseRef.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: emailV4.text!)
                .observe(.value, with: { snapshot in
                    
                    if snapshot.exists() {
                        self.loader.stopAnimating()
                        
                        self.messageLabel.text = "Ese correo ya está asociado a un nombre de usuario."
                        self.messageLabel.textColor = UIColor.red
                        
                    } else {
                        self.loader.stopAnimating()
                        
                        // Passing data to the next view (userImageVC)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let emailViewcontroller = storyboard.instantiateViewController(withIdentifier: "userImageView") as! SignUpViewController
                        emailViewcontroller.firstNameV5 = self.firstNameV4
                        emailViewcontroller.usernameV5 = self.usernameV4
                        emailViewcontroller.passwordV5 = self.passwordV4
                        emailViewcontroller.emailV5 = self.emailV4
                        self.navigationController!.pushViewController(emailViewcontroller, animated: true)
                        
                    }
                    
                }) { (error) in
                    print(error.localizedDescription)
            }
            
        } else { // Invalid email
            self.loader.stopAnimating()
            self.messageLabel.text = "Introduce un correo válido por favor."
            self.messageLabel.textColor = UIColor.red
            
        }
    }
    
    override func viewWillLayoutSubviews() {
        // Bottom line to emailTextField
        let borderBottomName = CALayer()
        let borderWidthName = CGFloat(2.0)
        borderBottomName.borderColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1).cgColor
        borderBottomName.frame = CGRect(x: 0, y: emailV4.frame.height - 1.0, width: emailV4.frame.width , height: emailV4.frame.height - 1.0)
        borderBottomName.borderWidth = borderWidthName
        emailV4.layer.addSublayer(borderBottomName)
        emailV4.layer.masksToBounds = true
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
        emailV4.resignFirstResponder()
        return true
    }
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
