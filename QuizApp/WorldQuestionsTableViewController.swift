//
//  WorldQuestionsTableViewController.swift
//  QuizApp
//
//  Created by Omar Torres on 18/12/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import JDStatusBarNotification

class WorldQuestionsTableViewController: UITableViewController {

    var databaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage!{
        return FIRStorage.storage()
    }
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    var questionsWorldArray = [Question]()
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
        
        self.navigationController!.navigationBar.setBottomBorderColorWorld(color: UIColor(colorLiteralRed: 225.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1), height: 1)
        
        self.currentUser = FIRAuth.auth()?.currentUser
        
        // Create message view and label programmatically
        messageView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 667))
        messageLabel = UILabel(frame: CGRect(x: 8, y: view.frame.height / 8, width: view.frame.width, height: 21))
        
        self.tableView.backgroundColor = UIColor.white
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 213
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        
        fetchQuestions()
        
        //        // Movements for UIToolbar transparency
        //        let bgImageColor = UIColor.white.withAlphaComponent(0.7)
        //        navigationController?.toolbar.setBackgroundImage(onePixelImageWithColor(bgImageColor), forToolbarPosition: UIBarPosition.bottom, barMetrics: UIBarMetrics.default)
        
        // DGElasticPullToRefresh
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self?.tableView.reloadData()
            // Do not forget to call dg_stopLoading() at the end
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        
        // Referencing to currentUser
        let userRef = databaseRef.child("Users").queryOrdered(byChild: "uid").queryEqual(toValue: FIRAuth.auth()!.currentUser!.uid)
        userRef.observe(.value, with: { (snapshot) in
            for userInfo in snapshot.children {
                self.navBarUser = User(snapshot: userInfo as! FIRDataSnapshot)
            }
            self.setupNavBarWithUser(user: self.navBarUser)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        
        //self.loader.frame = CGRect(x: 0, y: 20, width: 0.5, height: 0.5)
        
        
        //self.loader.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
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
        
        self.loader.startAnimating()
        // Remove message from view
        self.messageView.removeFromSuperview()
        self.messageLabel.removeFromSuperview()
            
        // Retrieve data
        let questionNodeRef = self.databaseRef.child("Questions")
        questionNodeRef.observe(.value, with: { (questionsSnap) in
            var newQuestionsWorldArray = [Question]()
                
            for question in questionsSnap.children {
                let newQuestion = Question(snapshot: question as! FIRDataSnapshot)
                    
                let followingRef = self.databaseRef.child("following").child(self.currentUser!.uid)
                followingRef.observe(.value, with: { (followingSnapRef) in
                        
                    if followingSnapRef.exists() { // The user follows other people
                        followingRef.queryOrdered(byChild: "firstName").observe(.childAdded, with: { (followingSnap) in
                            let snapshotData = followingSnap.value as! NSDictionary
                                
                            if newQuestion.userUid != snapshotData["uid"] as! String && newQuestion.userUid != self.currentUser!.uid {
                                newQuestionsWorldArray.insert(newQuestion, at: 0)
                            }
                            self.questionsWorldArray = newQuestionsWorldArray
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            self.loader.stopAnimating()
                        })
                            
                    } else { // User does not follow anyone
                        questionNodeRef.observe(.value, with: { (questionsSnap) in
                            var newQuestionsWorldArray = [Question]()
                            
                            for question in questionsSnap.children {
                                let newQuestion = Question(snapshot: question as! FIRDataSnapshot)
                                    
                                if newQuestion.userUid != self.currentUser!.uid {
                                    newQuestionsWorldArray.insert(newQuestion, at: 0)
                                }
                                self.questionsWorldArray = newQuestionsWorldArray
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                }
                                self.loader.stopAnimating()
                            }
                        })
                    }
                })
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        //UIApplication.shared.statusBarView?.backgroundColor = UIColor(colorLiteralRed: 210/255, green: 54/255, blue: 92/255, alpha: 1)
        //navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 210/255, green: 54/255, blue: 92/255, alpha: 1)
            
    }
        
    //        (sender.subviews[0] as UIView).tintColor = UIColor.blue
    //        (sender.subviews[1] as UIView).tintColor = UIColor.red

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
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(WorldQuestionsTableViewController.imageTapped(_:)))
        titleView.isUserInteractionEnabled = true
        titleView.addGestureRecognizer(tapGestureRecognizer)
        
        self.navigationItem.titleView = titleView
        
    }
    
    func imageTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "goUserProfileFromWorld", sender: sender)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionsWorldArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let question = questionsWorldArray[(indexPath as NSIndexPath).row]
            
        if questionsWorldArray[(indexPath as NSIndexPath).row].questionImageURL.isEmpty {
                
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionWithText", for: indexPath) as! TextQuestionTableViewCell
            cell.configureQuestion(question)
            return cell
                
        } else {
                
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionWithImage", for: indexPath) as! ImageQuestionTableViewCell
            cell.configureQuestion(question)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "addCommentWorld", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCommentWorld" {
            
                let vc = segue.destination as! CommentWorldViewController
                let indexPath = tableView.indexPathForSelectedRow!
                vc.selectedQuestion1 = questionsWorldArray[(indexPath.row)]
            
         }
        
        if segue.identifier == "findUserSegue" {
            let showFollowUsersTVC = segue.destination as! FollowUsersTableViewController
            showFollowUsersTVC.currentUser = self.currentUser as? FIRUser
        }
    }
    
    // Make UIToolbar Transparency
    func onePixelImageWithColor(_ color : UIColor) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context!.setFillColor(color.cgColor)
        context!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIImage(cgImage: context!.makeImage()!)
        return image
    }
}

extension UINavigationBar {
    
    func setBottomBorderColorWorld(color: UIColor, height: CGFloat) {
        let bottomBorderRect = CGRect(x: 0, y: frame.height, width: frame.width, height: height)
        let bottomBorderView = UIView(frame: bottomBorderRect)
        bottomBorderView.backgroundColor = color
        addSubview(bottomBorderView)
    }
}

//extension UIApplication {
//    var statusBarView: UIView? {
//        return value(forKey: "statusBar") as? UIView
//    }
//}
