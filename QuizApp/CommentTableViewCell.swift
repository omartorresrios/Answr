//
//  CommentTableViewCell.swift
//  QuizApp
//
//  Created by Omar Torres on 9/23/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commenterImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var commentContent: UILabel!
    
    var answer: NSDictionary?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        commenterImageView.layer.cornerRadius = commenterImageView.frame.size.height / 2
        commenterImageView.clipsToBounds = true
    }
    
    func configureCell(_ answer: NSDictionary) {
        
         self.answer = answer
        
        if let commenterImgURL = answer["commenterImageURL"] as? String {
            self.commenterImageView.loadImageUsingCacheWithUrlString(urlString: commenterImgURL)
        }
        
        self.firstNameLabel.text = answer["firstName"] as? String
        self.commentContent.text = answer["commentText"] as? String

    }

}
