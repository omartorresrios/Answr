//
//  UpdateEmailViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 5/01/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UpdateEmailViewController: UIViewController {

    @IBOutlet weak var userEmail: UITextField! {
        didSet {
            userEmail.layer.borderWidth = 1
            userEmail.layer.borderColor = UIColor(colorLiteralRed: 18/255.0, green: 165/255.0, blue: 244/255.0, alpha: 1).cgColor
            userEmail.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var oldEmail: String!
    var user: User!
    var name: String!
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loader.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        userEmail.text! = oldEmail
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func userEmailEditingChanged(_ sender: AnyObject) {
        if userEmail.text!.characters.count > 0 {
            self.message.text = ""
            if userEmail.text! == user.email {
                saveButton.isUserInteractionEnabled = false
                saveButton.backgroundColor = UIColor.lightGray
            } else {
                saveButton.isUserInteractionEnabled = true
                saveButton.backgroundColor = UIColor(colorLiteralRed: 18/255.0, green: 165/255.0, blue: 244/255.0, alpha: 1)
            }
        }
    }

    @IBAction func saveChanges(_ sender: AnyObject) {
        
        self.loader.startAnimating()
        
        // Check for internet connection
        if (reachability?.isReachable)! {
            
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            
            if emailTest.evaluate(with: userEmail.text!) == true { // Valid email
                
                self.databaseRef.child("Users").queryOrdered(byChild: "email").queryEqual(toValue: userEmail.text!)
                    .observe(.value, with: { snapshot in
                        
                        if snapshot.exists() {
                            self.loader.stopAnimating()
                            
                            self.message.text = "Ese correo ya está asociado a un nombre de usuario."
                            self.message.textColor = UIColor.red
                            
                        } else {
                            self.loader.stopAnimating()
                            
                            let email = self.userEmail.text!
                            
                            let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
                            changeRequest.displayName = self.name
                            
                            changeRequest.commitChanges(completion: { (error) in
                                if error == nil {
                                    let userRef = self.databaseRef.child("Users").child(self.user.uid)
                                    userRef.child("email").setValue(email, withCompletionBlock: { (error, ref) in
                                        if error == nil {
                                            print("currentUser email updated")
                                            
                                            // Once updated, return to SettingsVC
                                            for controller in self.navigationController!.viewControllers as Array {
                                                if controller is SettingsViewController {
                                                    self.navigationController!.popToViewController(controller as UIViewController, animated: true)
                                                    break
                                                }
                                            }
                                        } else {
                                            let alertView = SCLAlertView()
                                            alertView.showError("🙁", subTitle: "Hubo un problema, no se pudo actualizar. Intenta de nuevo!")
                                        }
                                    })
                                    
                                    
                                } else {
                                    print(error!.localizedDescription)
                                }
                            })
                            
                        }
                        
                    }) { (error) in
                        print(error.localizedDescription)
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
}
