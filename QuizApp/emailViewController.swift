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

        self.loader.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        
        emailV4.becomeFirstResponder()
        
        navigationController?.isNavigationBarHidden = false
        
        navigationController?.navigationBar.topItem?.title = ""
        
        if emailV4.text!.characters.count > 0 {
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
    
    @IBAction func comeBackAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
