//
//  CourseTableViewCell.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 9/27/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit

class CourseTableViewCell: UITableViewCell {

    @IBOutlet weak var imgCourses: UIImageView!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtContent: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
