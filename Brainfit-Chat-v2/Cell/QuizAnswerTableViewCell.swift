//
//  QuizAnswerTableViewCell.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 11/3/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit

class QuizAnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var imgChooice: UIImageView!
    @IBOutlet weak var lblAnswer: UILabel!
    @IBOutlet weak var viewBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
