//
//  LoginViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 9/17/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var authService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.becomeFirstResponder()
        
        //Setting the delegates for the Textfields
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // Unwind Segue Action
    @IBAction func unwindToLogin(storyboard: UIStoryboardSegue){}
    
    /*
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }*/
    /*
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }*/
    /*
    // Moving the View down after the Keyboard appears
    func textFieldDidBeginEditing(textField: UITextField) {
        animateView(true, moveValue: 80)
    }*/
    /*
    // Moving the View down after the Keyboard disappears
    func textFieldDidEndEditing(textField: UITextField) {
        animateView(false, moveValue: 80)
    }*/
    
    
    // Move the View Up & Down when the Keyboard appears
    func animateView(up: Bool, moveValue: CGFloat){
        
        let movementDuration: NSTimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        self.view.endEditing(true)
        let email = emailTextField.text!.lowercaseString
        let finalEmail = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let password = passwordTextField.text!
        
        if finalEmail.isEmpty || password.isEmpty || finalEmail.characters.count < 8 {
            //Present an alertView to your user
            
            dispatch_async(dispatch_get_main_queue(), {
                let alertView =  SCLAlertView()
                alertView.showError("OOPS", subTitle: "Hey, it seems like you did not fill correctly the information")
            })
        }else {
            authService.signIn(finalEmail, password: password)
        }
    }
}
