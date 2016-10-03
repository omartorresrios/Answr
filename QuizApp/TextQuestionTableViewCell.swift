//
//  TextQuestionTableViewCell.swift
//  QuizApp
//
//  Created by Omar Torres on 9/17/16.
//  Copyright © 2016 OmarTorres. All rights reserved.
//

import UIKit

class TextQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.layer.cornerRadius = 6
    }
}
