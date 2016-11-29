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
    var questionSections: UISegmentedControl!
    
    // Create message view and label programmatically
    let messageView = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
    let messageLabel = UILabel(frame: CGRect(x: 8, y: 101, width: 359, height: 21))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentUser = FIRAuth.auth()?.currentUser
        
        self.tableView.backgroundColor = UIColor.white
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 213
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        // Configure UISegmentedControl
        questionSections = UISegmentedControl(items: ["Club", "World"])
        questionSections.sizeToFit()
        questionSections.tintColor = UIColor(red:0.99, green:0.00, blue:0.25, alpha:1.00)
        questionSections.selectedSegmentIndex = 0
        questionSections.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 15)!], for: UIControlState.normal)
        questionSections.addTarget(self, action: #selector(QuestionsTableViewController.fetchQuestions), for: .valueChanged)
        self.navigationItem.titleView = questionSections
        
        // Movements for UIToolbar transparency
        let bgImageColor = UIColor.white.withAlphaComponent(0.7)
        navigationController?.toolbar.setBackgroundImage(onePixelImageWithColor(color: bgImageColor), forToolbarPosition: UIBarPosition.bottom, barMetrics: UIBarMetrics.default)
        
        // DGElasticPullToRefresh
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            // Add logic here
            // Do not forget to call dg_stopLoading() at the end
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        messageStatus()
        fetchQuestions(_sender: questionSections)
        
        self.loader.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.loader.center = self.view.center
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        
        // Show the bottom toolbar
        navigationController?.isToolbarHidden = false
    }
    
    func messageStatus() {
        self.currentUser = FIRAuth.auth()?.currentUser
        self.databaseRef.child("Users").child(self.currentUser!.uid).child("Feed").observe(.value, with: { (snapshot) in
            
            if snapshot.exists() {
                self.loader.startAnimating()
                // Remove message from view
                self.messageView.removeFromSuperview()
                self.messageLabel.removeFromSuperview()
            } else {
                self.loader.stopAnimating()
                // Show message in view
                self.messageLabel.textAlignment = .center
                self.messageLabel.text = "No tienes preguntas! 😟"
                self.messageLabel.font = UIFont(name: "Helvetica Neue", size: 14.0)
                
                self.view.addSubview(self.messageView)
                self.view.addSubview(self.messageLabel)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @objc fileprivate func fetchQuestions(_sender: UISegmentedControl){
        
        if _sender.selectedSegmentIndex == 0 {
            // Questions of the people I follow
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
        } else {
            // Questions from all over the world
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
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let question = questionsArray[(indexPath as NSIndexPath).row]
        
        if questionsArray[(indexPath as NSIndexPath).row].questionImageURL.isEmpty {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionWithText", for: indexPath) as! TextQuestionTableViewCell
            
            cell.configureQuestion(question: question)
            
            return cell
        
        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionWithImage", for: indexPath) as! ImageQuestionTableViewCell
            
            cell.configureQuestion(question: question)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Function for delete question
    func deleteBu(_ NSIndexPathData: NSIndexPath) {
        
        // delete item at indexPath
        let question = self.questionsArray[NSIndexPathData.row]
        
        if let questionKey = question.questionId {
            self.databaseRef.child("Users").child(self.currentUser!.uid).child("Feed").child(questionKey).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                self.questionsArray.remove(at: NSIndexPathData.row)
                self.tableView.deleteRows(at: [NSIndexPathData as IndexPath], with: .automatic)
                self.loader.isHidden = true
                self.showMessage("Pregunta eliminada!", type: .success, options: [
                    .animation(.slide),
                    .animationDuration(0.3),
                    .autoHide(true),
                    .autoHideDelay(3.0),
                    .height(20.0),
                    .hideOnTap(true),
                    .position(.top),
                    .textAlignment(.center),
                    .textColor(UIColor.white),
                    .textNumberOfLines(1),
                    .textPadding(30.0)
                    ])
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteBtn = UITableViewRowAction(style: .destructive, title: "Eliminar") { (action, indexPath) in
//            let alertView = SCLAlertView()
//            
//            alertView.addButton("Eliminar", target:self, selector: #selector(QuestionsTableViewController.deleteBu(_:)))
//            alertView.showSuccess("Estás seguro?", subTitle: "No verás más esta pregunta!")
            
            self.deleteBu(indexPath as NSIndexPath)
        }
        
        UIButton.appearance().setTitleColor(UIColor.red, for: UIControlState.normal)
        deleteBtn.backgroundColor = UIColor.white
        
        return [deleteBtn]
        
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
