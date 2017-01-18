//
//  FollowUsersTableViewCell.swift
//  QuizApp
//
//  Created by Omar Torres on 10/16/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit
import FirebaseStorage

class FollowUsersTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var tapAction: ((UITableViewCell) -> Void)?
    
    var storageRef: FIRStorage {
        return FIRStorage.storage()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        followButton.addTarget(self, action: #selector(FollowUsersTableViewCell.buttonPress(_:)), for: .touchDown)
        followButton.addTarget(self, action: #selector(FollowUsersTableViewCell.buttonRelease(_:)), for: .touchUpInside)
        followButton.addTarget(self, action: #selector(FollowUsersTableViewCell.buttonRelease(_:)), for: .touchUpOutside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        userImage.layer.cornerRadius = userImage.frame.size.height / 2
        userImage.clipsToBounds = true
        
        // UI for the followButton
        followButton.backgroundColor = UIColor(colorLiteralRed: 21/255.0, green: 216/255.0, blue: 161/255.0, alpha: 1)
        followButton.layer.cornerRadius = followButton.frame.size.height / 2
    }
    
    func configureCell(_ user: User) {
        
        if let userImgURL = user.photoURL {
            self.userImage.loadImageUsingCacheWithUrlString(urlString: userImgURL)
        }
        
        self.firstName.text = user.firstName!
        self.username.text = user.username!
        self.points.text = "\(user.points!)"
    }
    
    // Allow follow users from FollowUsersTableViewController with its followButton
    @IBAction func didTapFollow(_ sender: AnyObject) {
        tapAction?(self)
    }
    
    // Scale up on sendButton press
    func buttonPress(_ button: UIButton) {
        followButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 4.0,
                       options: .allowUserInteraction, animations: { [weak self] in
                        self?.followButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: nil)
    }
    
    // Scale down sendbutton release
    func buttonRelease(_ button: UIButton) {
        followButton.transform = .identity
    }
}
