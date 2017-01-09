//
//  UpdatePasswordViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 7/01/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UpdatePasswordViewController: UIViewController {

    @IBOutlet weak var userEmail: UITextField! {
        didSet {
            userEmail.layer.borderWidth = 1
            userEmail.layer.borderColor = UIColor(colorLiteralRed: 18/255.0, green: 165/255.0, blue: 244/255.0, alpha: 1).cgColor
            userEmail.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    @IBOutlet weak var message: UILabel!
    var user: User!
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var authenticationService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loader.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        saveButton.isUserInteractionEnabled = false
        saveButton.backgroundColor = UIColor.lightGray
        
        userEmail.becomeFirstResponder()
        
        // Reachability for checking internet connection
        NotificationCenter.default.addObserver(self, selector: #selector(AddQuestionViewController.reachabilityStatusChanged), name: NSNotification.Name(rawValue: "ReachStatusChanged"), object: nil)
        
    }
    
    func reachabilityStatusChanged() {
        if reachability?.isReachable == false {
            saveButton.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func userEmailEditingChanged(_ sender: AnyObject) {
        if userEmail.text!.characters.count > 0 {
            self.message.text = ""
            
            saveButton.isUserInteractionEnabled = true
            saveButton.backgroundColor = UIColor(colorLiteralRed: 18/255.0, green: 165/255.0, blue: 244/255.0, alpha: 1)
        
        } else {
            saveButton.isUserInteractionEnabled = false
            saveButton.backgroundColor = UIColor.lightGray
        }
            
    }
    
    @IBAction func saveChanges(_ sender: AnyObject) {
        
        self.loader.startAnimating()
        
        // Check for internet connection
        if (reachability?.isReachable)! {
            
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            
            if emailTest.evaluate(with: userEmail.text!) == true { // Valid email
                
                if userEmail.text! == user.email {
                    self.loader.stopAnimating()
                    
                    let email = self.userEmail.text!
                    
                    self.authenticationService.resetPassword(email)
                    
                } else {
                    self.loader.stopAnimating()
                    
                    self.message.text = "Ese no es tu correo."
                    self.message.textColor = UIColor.red
                }
                
            } else { // Invalid email
                self.loader.stopAnimating()
                self.message.text = "Introduce un correo válido por favor."
                self.message.textColor = UIColor.red
                
            }
        }
    }
    
    @IBAction func comeBack(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}
