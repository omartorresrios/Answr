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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        commenterImageView.layer.cornerRadius = commenterImageView.layer.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
