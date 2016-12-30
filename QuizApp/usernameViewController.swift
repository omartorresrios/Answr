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
                            self.button.backgroundColor = UIColor(colorLiteralRed: 21/255.0, green: 216/255.0, blue: 161/255.0, alpha: 1)
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
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        usernameV2.resignFirstResponder()
        return true
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
