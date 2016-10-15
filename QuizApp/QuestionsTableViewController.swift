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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchQuestions()
    }
    
    fileprivate func fetchQuestions(){
        databaseRef.child("Questions").observe(.value, with: { (questions) in
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
            let vc = segue.destination as! CommentTableViewController
            let indexPath = tableView.indexPathForSelectedRow!
            
            vc.selectedQuestion = questionsArray[(indexPath as NSIndexPath).row]
        }
    }
}

