//
//  QuizQuestionTableViewCell.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 11/3/20.
//  Copyright © 2020 macbook. All rights reserved.
//

import UIKit

class QuizQuestionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var QuizAnswer: UITableView!
    
    var arrAnswer = ["Answer 1","Answer 2","Answer 3","Answer 4"]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        QuizAnswer.dataSource = self
        QuizAnswer.delegate = self
        self.QuizAnswer.estimatedRowHeight = 150
        self.QuizAnswer.rowHeight = UITableView.automaticDimension
        
    }
    
    //    override func layoutSubviews() {
    //        super.layoutSubviews()
    //        //set the values for top,left,bottom,right margins
    //        let padding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    //        contentView.frame = bounds.inset(by: padding)
    //    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension QuizQuestionTableViewCell : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAnswer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cellAnswer", for: indexPath) as! QuizAnswerTableViewCell
        
        cell.lblAnswer.text = arrAnswer[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellSelected  = tableView.cellForRow(at: indexPath as IndexPath) as! QuizAnswerTableViewCell
        selectedCell(viewBg: cellSelected.viewBG, imgCheck: cellSelected.imgChooice)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cellToDeSelect = tableView.cellForRow(at: indexPath as IndexPath) as! QuizAnswerTableViewCell
        DeSelectCell(viewBg: cellToDeSelect.viewBG,imgCheck: cellToDeSelect.imgChooice)
    }
}

extension QuizQuestionTableViewCell {
    func selectedCell(viewBg : UIView, imgCheck : UIImageView)  {
        viewBg.backgroundColor = UIColor(red: 0.88, green: 0.96, blue: 1.00, alpha: 1.00)
        viewBg.layer.masksToBounds = true
        viewBg.layer.borderColor = UIColor(red: 0.28, green: 0.74, blue: 0.93, alpha: 1.00).cgColor
        viewBg.layer.borderWidth = 1.0
        imgCheck.image = UIImage.init(named: "radio-checked")
        
    }
    
    func DeSelectCell(viewBg : UIView,imgCheck : UIImageView)  {
        viewBg.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.00)
        viewBg.layer.masksToBounds = true
        viewBg.layer.borderColor = UIColor.clear.cgColor
        viewBg.layer.borderWidth = 1.0
        imgCheck.image = UIImage.init(named: "radio")
    }
}
