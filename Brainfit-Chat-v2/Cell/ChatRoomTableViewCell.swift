//
//  ChatRoomTableViewCell.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/18/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit

class ChatRoomTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var imageRoom: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageRoom.layer.cornerRadius = imageRoom.frame.width / 2
        imageRoom.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
