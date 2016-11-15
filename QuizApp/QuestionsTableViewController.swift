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
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
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
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        // Movements for UIToolbar transparency
        let bgImageColor = UIColor.white.withAlphaComponent(0.7)
        navigationController?.toolbar.setBackgroundImage(onePixelImageWithColor(color: bgImageColor), forToolbarPosition: UIBarPosition.bottom, barMetrics: UIBarMetrics.default)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchQuestions()
        
        self.loader.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.loader.center = self.view.center
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        
        // Show the bottom toolbar
        navigationController?.isToolbarHidden = false
    }
    
    @IBAction func deleteQuestion(_ sender: AnyObject) {
        
        let position: CGPoint = sender.convert(CGPoint.zero, to: self.view)
        let indexPath: NSIndexPath = self.tableView.indexPathForRow(at: position)! as NSIndexPath
        
        let question = self.questionsArray[indexPath.row]
        
        if let questionKey = question.questionId {
            self.databaseRef.child("Users").child(self.currentUser!.uid).child("Feed").child(questionKey).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                self.questionsArray.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath as IndexPath], with: .right)
            })
        }
    }
    
    fileprivate func fetchQuestions(){
        
        self.currentUser = FIRAuth.auth()?.currentUser
        
        self.databaseRef.child("Questions").observe(.value, with: { (questions) in
            var newQuestionsArray = [Question]()
            for question in questions.children {
                let newQuestion = Question(snapshot: question as! FIRDataSnapshot)
                
                self.databaseRef.child("Users").child(self.currentUser!.uid).child("Feed").observe(.childAdded, with: { (questionsFeed) in
                    let questionKey = questionsFeed.key
                    if newQuestion.questionId == questionKey {
                        newQuestionsArray.insert(newQuestion, at: 0)
                    }
                    self.questionsArray = newQuestionsArray
                    self.tableView.reloadData()
                    self.loader.stopAnimating()
                })
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
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
            
            cell.firstNameLabel.text = questionsArray[(indexPath as NSIndexPath).row].firstName
            cell.questionTextLabel.text = questionsArray[(indexPath as NSIndexPath).row].questionText
            if questionsArray[(indexPath as NSIndexPath).row].numberOfComments.isEmpty == false {
                cell.commentsCounter.text = "\(questionsArray[(indexPath as NSIndexPath).row].counterComments!)" + "/"
                cell.numberOfComments.text = questionsArray[(indexPath as NSIndexPath).row].numberOfComments
            }
            
            //TimeStamp
            let timeInterval  = questionsArray[(indexPath as NSIndexPath).row].timestamp
            
            //Convert to Date
            let date = NSDate(timeIntervalSince1970: timeInterval as! TimeInterval)
            
            //Date formatting
            let dateFormatter = DateFormatter()
            
            dateFormatter.timeZone = NSTimeZone.local
            
            let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
            let secondInDays: TimeInterval = 60 * 60 * 24
            
            if elapsedTimeInSeconds > 7 * secondInDays {
                dateFormatter.dateFormat = "dd/MM/yy"
            } else if elapsedTimeInSeconds > secondInDays {
                dateFormatter.dateFormat = "EEE"
            } else {
                dateFormatter.dateFormat = "HH:mm:a"
            }
            
            let dateString = dateFormatter.string(from: date as Date)
            
            cell.timestamp.text = dateString
            
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
            if questionsArray[(indexPath as NSIndexPath).row].numberOfComments.isEmpty == false {
                cell.commentsCounter.text = "\(questionsArray[(indexPath as NSIndexPath).row].counterComments!)" + "/"
                cell.numberOfComments.text = questionsArray[(indexPath as NSIndexPath).row].numberOfComments
            }
            
            //TimeStamp
            let timeInterval  = questionsArray[(indexPath as NSIndexPath).row].timestamp
            
            //Convert to Date
            let date = NSDate(timeIntervalSince1970: timeInterval as! TimeInterval)
            
            //Date formatting
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm:a"
            dateFormatter.timeZone = NSTimeZone.local
            
            let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
            let secondInDays: TimeInterval = 60 * 60 * 24
            
            if elapsedTimeInSeconds > 7 * secondInDays {
                dateFormatter.dateFormat = "dd/MM/yy"
            } else if elapsedTimeInSeconds > secondInDays {
                dateFormatter.dateFormat = "EEE"
            } else {
                dateFormatter.dateFormat = "HH:mm:a"
            }
            
            let dateString = dateFormatter.string(from: date as Date)
            
            cell.timestamp.text = dateString
            
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
    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        
//        let question = self.questionsArray[indexPath.row]
//        
//        if let questionKey = question.questionId {
//            self.databaseRef.child("Users").child(self.currentUser!.uid).child("Feed").child(questionKey).removeValue(completionBlock: { (error, ref) in
//                if error != nil {
//                    print(error!.localizedDescription)
//                    return
//                }
//                self.questionsArray.remove(at: indexPath.row)
//                self.tableView.deleteRows(at: [indexPath], with: .automatic)
//            })
//        }
//    }
    
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

