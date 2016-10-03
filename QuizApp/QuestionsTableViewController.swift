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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 213
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        fetchQuestions()
    }
    
    private func fetchQuestions(){
        databaseRef.child("Questions").observeEventType(.Value, withBlock: { (questions) in
            var newQuestionsArray = [Question]()
            for question in questions.children {
                let newQuestion = Question(snapshot: question as! FIRDataSnapshot)
                newQuestionsArray.insert(newQuestion, atIndex: 0)
            }
            self.questionsArray = newQuestionsArray
            self.tableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if questionsArray[indexPath.row].questionImageURL.isEmpty {
            let cell = tableView.dequeueReusableCellWithIdentifier("questionWithText", forIndexPath: indexPath) as! TextQuestionTableViewCell
            
            cell.firstNameLabel.text = questionsArray[indexPath.row].firstName
            cell.usernameLabel.text = questionsArray[indexPath.row].username
            cell.questionTextLabel.text = questionsArray[indexPath.row].questionText
            
            storageRef.referenceForURL(questionsArray[indexPath.row].questionerImageURL).dataWithMaxSize(1 * 1024 * 1024, completion: { (data, error) in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue(), {
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
        
            let cell = tableView.dequeueReusableCellWithIdentifier("questionWithImage", forIndexPath: indexPath) as! ImageQuestionTableViewCell
            cell.firstNameLabel.text = questionsArray[indexPath.row].firstName
            cell.usernameLabel.text = questionsArray[indexPath.row].username
            cell.questionTextLabel.text = questionsArray[indexPath.row].questionText
            
            storageRef.referenceForURL(questionsArray[indexPath.row].questionerImageURL).dataWithMaxSize(1 * 1024 * 1024, completion: { (data, error) in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue(), {
                        if let data = data {
                            cell.userImageView.image = UIImage(data: data)
                        }
                    })
                }else {
                    print(error!.localizedDescription)
                }
            })
            
            storageRef.referenceForURL(questionsArray[indexPath.row].questionImageURL).dataWithMaxSize(1 * 1024 * 1024, completion: { (data, error) in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue(), {
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("addComment", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addComment" {
            let vc = segue.destinationViewController as! CommentTableViewController
            let indexPath = tableView.indexPathForSelectedRow!
            
            vc.selectedQuestion = questionsArray[indexPath.row]
        }
    }
}

