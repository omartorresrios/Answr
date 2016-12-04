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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        userImage.layer.cornerRadius = userImage.frame.size.height / 2
        userImage.clipsToBounds = true
    }
    
    func configureCell(_ user: User) {
        
        let imageURL = user.photoURL!
        
        self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024) { (imgData, error) in
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        self.userImage.image = UIImage(data: data)
                    }
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        self.firstName.text = user.firstName!
        self.username.text = user.username!
        self.points.text = "\(user.points!)"
    }
    
    @IBAction func didTapFollow(_ sender: AnyObject) {
        tapAction?(self)
    }
    
    
}
