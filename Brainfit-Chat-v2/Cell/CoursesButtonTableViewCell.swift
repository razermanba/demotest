//
//  CoursesButtonTableViewCell.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 9/27/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit

class CoursesButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var btnResoucres: UIButton!
    @IBOutlet weak var Descrition: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let lineViewResoucres = UIView(frame: CGRect(x: 0, y: btnResoucres.frame.size.height, width: btnResoucres.frame.size.width, height: 1.5))
        lineViewResoucres.backgroundColor = UIColor.red
        btnResoucres.tintColor = UIColor.red
        btnResoucres.addSubview(lineViewResoucres)
        
        let lineViewDescrition = UIView(frame: CGRect(x: 0, y: btnResoucres.frame.size.height, width: Descrition.frame.size.width, height: 1.5))
        lineViewDescrition.backgroundColor = UIColor.black
        Descrition.tintColor = UIColor.black
        Descrition.addSubview(lineViewDescrition)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
