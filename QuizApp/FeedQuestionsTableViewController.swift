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
import JDStatusBarNotification

class FeedQuestionsTableViewController: UITableViewController {
    
    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var questionsFeedArray = [Question]()
    var currentUser: AnyObject?
    var user: FIRUser?
    var navBarUser: User!
    var selectedQuestion: Question!
    var otherUser: NSDictionary?
    var questionKey: String!
    var newQuestion: Question!
    var messageView: UIView!
    var messageLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isStatusBarHidden = false
        
        self.navigationController!.navigationBar.setBottomBorderColor(color: UIColor(colorLiteralRed: 225.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1), height: 1)
        
        self.tabBarController?.tabBar.isHidden = false
        
        self.currentUser = FIRAuth.auth()?.currentUser
        
        // Create message view and label programmatically
        messageView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 667))
        messageLabel = UILabel(frame: CGRect(x: 8, y: view.frame.height / 8, width: view.frame.width, height: 21))
        
        self.tableView.backgroundColor = UIColor.white
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 213
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        
        
        // DGElasticPullToRefresh
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.white
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.tableView.reloadData()
            // Do not forget to call dg_stopLoading() at the end
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(UIColor(colorLiteralRed: 218/255.0, green: 218/255.0, blue: 218/255.0, alpha: 1))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        
        // Referencing to currentUser
        let userRef = databaseRef.child("Users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        userRef.observe(.value, with: { (snapshot) in
            for userInfo in snapshot.children {
                self.navBarUser = User(snapshot: userInfo as! FIRDataSnapshot)
            }
            // Put user image in navigation bar
            self.setupNavBarWithUser(user: self.navBarUser)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        fetchQuestions()
        
        //
        ///self.loader.center = self.view.center
        
        // Show the bottom toolbar
        //navigationController?.isToolbarHidden = false
        
    }
    
    func messageStatus() {
        self.currentUser = FIRAuth.auth()?.currentUser
        self.loader.startAnimating()
        self.databaseRef.child("Users").child(self.currentUser!.uid).child("Feed").observe(.value, with: { (snapshot) in
                
            if snapshot.exists() {
                self.loader.stopAnimating()
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
    
    @objc fileprivate func fetchQuestions(){
        
        self.currentUser = FIRAuth.auth()?.currentUser
        
        messageStatus()
        
        // Retrieve data
        self.databaseRef.child("Questions").observe(.value, with: { (questionsSnap) in
            var newQuestionsFeedArray = [Question]()
                
            for question in questionsSnap.children {
                let newQuestion = Question(snapshot: question as! FIRDataSnapshot)
                    
                self.databaseRef.child("Users").child(self.currentUser!.uid).child("Feed").observe(.childAdded, with: { (questionsFeed) in
                    let questionKey = questionsFeed.key
                        
                    if newQuestion.questionId == questionKey {
                        newQuestionsFeedArray.insert(newQuestion, at: 0)
                    }
                    self.questionsFeedArray = newQuestionsFeedArray
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    self.loader.stopAnimating()
                        
                })
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
            
        //UIApplication.shared.statusBarView?.backgroundColor = UIColor(colorLiteralRed: 0/255, green: 63/255, blue: 96/255, alpha: 1)
        //navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 0/255, green: 63/255, blue: 96/255, alpha: 1)

//        (sender.subviews[0] as UIView).tintColor = UIColor.blue
//        (sender.subviews[1] as UIView).tintColor = UIColor.red
    }
    
    func setupNavBarWithUser(user: User) {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        titleView.layer.cornerRadius = 20
        
        let profileImageView = UIImageView()
        //profileImageView.frame = CGRect(x: titleView.frame.size.width / 2, y: 0, width: 40, height: 40)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let userImgViewURL = user.photoURL {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: userImgViewURL)
        }
        
        titleView.addSubview(profileImageView)
        
        // ios 9 constraint anchors
        // Need x,y, width, height anchors
        profileImageView.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40.0).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        
        // UITapGestureRecognizer
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(FeedQuestionsTableViewController.imageTapped(_:)))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(tapGestureRecognizer)
        
        self.navigationItem.titleView = titleView

    }
    
    func imageTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "goUserProfileFromFeed", sender: sender)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsFeedArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        messageStatus()
        let question = questionsFeedArray[indexPath.row]
            
        if question.questionImageURL.isEmpty {
                
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionWithText", for: indexPath) as! TextQuestionTableViewCell
            cell.configureQuestion(question)
            return cell
                
        } else {
                
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionWithImage", for: indexPath) as! ImageQuestionTableViewCell
            cell.configureQuestion(question)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Function for delete question
    func deleteBu(_ NSIndexPathData: IndexPath) {
        
        
        // delete item at indexPath
        let question = self.questionsFeedArray[(NSIndexPathData as NSIndexPath).row]
            
        if let questionKey = question.questionId {
            self.databaseRef.child("Users").child(self.currentUser!.uid).child("Feed").child(questionKey).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                self.questionsFeedArray.remove(at: NSIndexPathData.row)
                self.tableView.deleteRows(at: [NSIndexPathData as IndexPath], with: .automatic)
                    
                self.loader.isHidden = true
                    
                JDStatusBarNotification.show(withStatus: "Pregunta eliminada!", dismissAfter: 2.0, styleName: JDStatusBarStyleDark)
            })
        }
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteBtn = UITableViewRowAction(style: .destructive, title: "Eliminar") { (action, indexPath) in
            self.deleteBu(indexPath as IndexPath)
        }
        
        UIButton.appearance().setTitleColor(UIColor.red, for: UIControlState.normal)
        deleteBtn.backgroundColor = UIColor.white
        
        return [deleteBtn]
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "addCommentFeed", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCommentFeed" {
            let vc = segue.destination as! CommentViewController
            let indexPath = tableView.indexPathForSelectedRow!
            vc.selectedQuestion = questionsFeedArray[(indexPath.row)]
        }
        
        if segue.identifier == "findUserSegue" {
            let showFollowUsersTVC = segue.destination as! FollowUsersTableViewController
            showFollowUsersTVC.currentUser = self.currentUser as? FIRUser
        }
    }
    
}


//
//extension UIApplication {
//    var statusBarView: UIView? {
//        return value(forKey: "statusBar") as? UIView
//    }
//}
