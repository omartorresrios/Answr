//
//  QuestionTableViewCell.swift
//  QuizApp
//
//  Created by Omar Torres on 10/20/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet weak var questionContent: UILabel!
    
    var selectedQuestion: Question!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.clipsToBounds = true
    }

}
