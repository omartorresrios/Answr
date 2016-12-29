//
//  usernameViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 25/12/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class usernameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameV2: UITextField!
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
    var firstNameV2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loader.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
        
        navigationController?.isNavigationBarHidden = false
        
        usernameV2.becomeFirstResponder()
        
        navigationController?.navigationBar.topItem?.title = ""
        
        if usernameV2.text!.characters.count > 0 {
            button.isUserInteractionEnabled = true
            button.backgroundColor = UIColor(colorLiteralRed: 12/255.0, green: 206/255.0, blue: 107/255.0, alpha: 1)
        } else {
            button.isUserInteractionEnabled = false
            button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
        }
    }
    
    @IBAction func handleButton(_ sender: AnyObject) {
        
        let senderTxt = (sender as! UITextField).text!
        if senderTxt.characters.count < 3 {
            button.isUserInteractionEnabled = false
            button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
            self.messageLabel.text = "Oops! debe tener por lo menos 3 caracteres"
            self.messageLabel.textColor = UIColor.red
        } else {
            if senderTxt.characters.count > 15 {
                self.loader.stopAnimating()
                button.isUserInteractionEnabled = false
                button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
                self.messageLabel.text = "Oops! no puede tener más de 15 caracteres"
                self.messageLabel.textColor = UIColor.red
            } else {
                self.loader.startAnimating()
                self.databaseRef.child("Users").queryOrdered(byChild: "username").queryEqual(toValue: senderTxt)
                    .observe(.value, with: { snapshot in
                        
                        if snapshot.exists() {
                            self.button.isUserInteractionEnabled = false
                            self.button.backgroundColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1)
                            self.messageLabel.text = "¡\(senderTxt) ya está elegido!"
                            self.messageLabel.textColor = UIColor.red
                            self.loader.stopAnimating()
                        } else {
                            self.button.isUserInteractionEnabled = true
                            self.button.backgroundColor = UIColor(colorLiteralRed: 12/255.0, green: 206/255.0, blue: 107/255.0, alpha: 1)
                            self.messageLabel.text = "Nombre de usuario disponible 😋"
                            self.messageLabel.textColor = UIColor.lightGray
                            self.loader.stopAnimating()
                        }
                    }) { (error) in
                        print(error.localizedDescription)
                }
            }
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        // Bottom line to usernameTextField
        let borderBottomName = CALayer()
        let borderWidthName = CGFloat(2.0)
        borderBottomName.borderColor = UIColor(colorLiteralRed: 160/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1).cgColor
        borderBottomName.frame = CGRect(x: 0, y: usernameV2.frame.height - 1.0, width: usernameV2.frame.width , height: usernameV2.frame.height - 1.0)
        borderBottomName.borderWidth = borderWidthName
        usernameV2.layer.addSublayer(borderBottomName)
        usernameV2.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goPasswordView" {
            let showPasswordView = segue.destination as! passwordViewController
            showPasswordView.firstNameV3 = self.firstNameV2
            showPasswordView.usernameV3 = self.usernameV2
            
        }
    }
    @IBAction func comeBack(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}
