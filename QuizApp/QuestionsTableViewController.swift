//
//  ViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 9/17/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class QuestionsTableViewController: UITableViewController {
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    var questionsArray = [Question]()
    var currentUser: AnyObject?
    var user: FIRUser?
    var selectedQuestion: Question!
    var otherUser: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currentUser = FIRAuth.auth()?.currentUser
        
        self.tableView.backgroundColor = UIColor.white
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 213
        
        // Movements for UIToolbar transparency
        let bgImageColor = UIColor.white.withAlphaComponent(0.7)
        navigationController?.toolbar.setBackgroundImage(onePixelImageWithColor(color: bgImageColor), forToolbarPosition: UIBarPosition.bottom, barMetrics: UIBarMetrics.default)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchQuestions()
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        
        // Show the bottom toolbar
        navigationController?.isToolbarHidden = false

    }
    
    fileprivate func fetchQuestions(){
        
        self.currentUser = FIRAuth.auth()?.currentUser
        
        self.databaseRef.child("Users").child(self.currentUser!.uid).child("Feed").observe(.value, with: { (questions) in
            
            for question in questions.children {
                let questionSnap = Question(snapshot: question as! FIRDataSnapshot)
                
                self.databaseRef.child("Questions").queryOrdered(byChild: "questionId").queryEqual(toValue: questionSnap.questionId).observe(.childAdded, with: { (snapshot) in
                    
                    var newQuestionsArray = [Question]()
                    for question in questions.children {
                        let newQuestion = Question(snapshot: question as! FIRDataSnapshot)
                        newQuestionsArray.insert(newQuestion, at: 0)
                    }
                    self.questionsArray = newQuestionsArray
                    self.tableView.reloadData()
                    
                }) { (error) in
                    print(error.localizedDescription)
                }
            }
        })
    
        // Questions worldwide (PUEDE QUE SE IMPLEMENTE MÁS ADELANTE) P.E: 2 OPC.(PREG. DEL MUNDO y PREG. DE GENTE QUE SIGO)
        /*databaseRef.child("Questions").observe(.value, with: { (questions) in
            var newQuestionsArray = [Question]()
            for question in questions.children {
                let newQuestion = Question(snapshot: question as! FIRDataSnapshot)
                newQuestionsArray.insert(newQuestion, at: 0)
            }
            self.questionsArray = newQuestionsArray
            self.tableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }*/
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if questionsArray[(indexPath as NSIndexPath).row].questionImageURL.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionWithText", for: indexPath) as! TextQuestionTableViewCell
            
            //cell.layer.cornerRadius = 10
            
            cell.firstNameLabel.text = questionsArray[(indexPath as NSIndexPath).row].firstName
            cell.questionTextLabel.text = questionsArray[(indexPath as NSIndexPath).row].questionText
            
            storageRef.reference(forURL: questionsArray[(indexPath as NSIndexPath).row].questionerImageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if error == nil {
                    DispatchQueue.main.async(execute: {
                        if let data = data {
                            cell.userImageView.image = UIImage(data: data)
                        }
                    })
                }else {
                    print(error!.localizedDescription)
                }
            })
            return cell
            
        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionWithImage", for: indexPath) as! ImageQuestionTableViewCell
            cell.firstNameLabel.text = questionsArray[(indexPath as NSIndexPath).row].firstName
            cell.questionTextLabel.text = questionsArray[(indexPath as NSIndexPath).row].questionText
            
            storageRef.reference(forURL: questionsArray[(indexPath as NSIndexPath).row].questionerImageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if error == nil {
                    DispatchQueue.main.async(execute: {
                        if let data = data {
                            cell.userImageView.image = UIImage(data: data)
                        }
                    })
                }else {
                    print(error!.localizedDescription)
                }
            })
            
            storageRef.reference(forURL: questionsArray[(indexPath as NSIndexPath).row].questionImageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) in
                if error == nil {
                    DispatchQueue.main.async(execute: {
                        if let data = data {
                            cell.questionImageView.image = UIImage(data: data)
                        }
                    })
                } else {
                    print(error!.localizedDescription)
                }
            })
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "addComment", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addComment" {
            let vc = segue.destination as! CommentViewController
            let indexPath = tableView.indexPathForSelectedRow!
            vc.selectedQuestion = questionsArray[(indexPath.row)]
        }
        
        if segue.identifier == "findUserSegue" {
            let showFollowUsersTVC = segue.destination as! FollowUsersTableViewController
            showFollowUsersTVC.currentUser = self.currentUser as? FIRUser
        }
    }
    
    // Make UIToolbar Transparency
    func onePixelImageWithColor(color : UIColor) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context!.setFillColor(color.cgColor)
        context!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIImage(cgImage: context!.makeImage()!)
        return image
    }
}

