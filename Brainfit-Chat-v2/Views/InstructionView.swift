//
//  InstructionView.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 11/20/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit

class InstructionView: UIView {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblInstruction: UITextView!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var viewBG: UIView!
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    override func layoutSubviews() {
        viewBG.layer.cornerRadius = 15

        viewBG.layer.shadowColor = UIColor.darkGray.cgColor
        viewBG.layer.shadowOffset = CGSize.zero
        viewBG.layer.shadowOpacity = 1.0
        viewBG.layer.shadowRadius = 7.0
        viewBG.layer.masksToBounds =  false
        
    }
}
