//
//  FillinBlankTableViewCell.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 11/30/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit

class FillinBlankTableViewCell: UITableViewCell {

    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var txtInputText: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
