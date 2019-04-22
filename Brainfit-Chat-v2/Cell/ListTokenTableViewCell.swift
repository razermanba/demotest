//
//  ListTokenTableViewCell.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/22/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit

class ListTokenTableViewCell: UITableViewCell {

    @IBOutlet weak var imageToken: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
