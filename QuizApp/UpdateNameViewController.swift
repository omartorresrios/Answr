//
//  UpdateNameViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 5/01/17.
//  Copyright © 2017 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class UpdateNameViewController: UIViewController {

    @IBOutlet weak var userName: UITextField! {
        didSet {
            userName.layer.borderWidth = 1
            userName.layer.borderColor = UIColor(colorLiteralRed: 18/255.0, green: 165/255.0, blue: 244/255.0, alpha: 1).cgColor
            userName.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.layer.cornerRadius = 15
        }
    }
    
    var oldName: String!
    var user: User!
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userName.text! = oldName
        
        saveButton.isUserInteractionEnabled = false
        saveButton.backgroundColor = UIColor.lightGray
        
        userName.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    @IBAction func userNameEditingChanged(_ sender: AnyObject) {
        if userName.text!.characters.count > 0 {
            if userName.text! == user.firstName {
                saveButton.isUserInteractionEnabled = false
                saveButton.backgroundColor = UIColor.lightGray
            } else {
                saveButton.isUserInteractionEnabled = true
                saveButton.backgroundColor = UIColor(colorLiteralRed: 18/255.0, green: 165/255.0, blue: 244/255.0, alpha: 1)
            }
        }
    }
    
    @IBAction func saveChanges(_ sender: AnyObject) {
        
        let name = userName.text!
                    
        let changeRequest = FIRAuth.auth()!.currentUser!.profileChangeRequest()
        changeRequest.displayName = name

        changeRequest.commitChanges(completion: { (error) in
            if error == nil {
                let userRef = self.databaseRef.child("Users").child(self.user.uid)
                userRef.child("firstName").setValue(name, withCompletionBlock: { (error, ref) in
                    if error == nil {
                        print("currentUser firstName updated")
//                      SVProgressHUD.showSuccess(withStatus: "Actualizado!")
                        // Once updated, return to SettingsTVC
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
    
    @IBAction func comeBack(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
