//
//  StandardScoreTableViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 5/20/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import Charts

class StandardScoreTableViewController: UITableViewController,ChartViewDelegate {
    
    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet weak var lblInforUse: UILabel!
    
    var standardScore = Mapper<StandardScore>().map(JSONObject: ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup(pieChartView: chartView)
        chartView.delegate = self
        loadStandardScore()
    }
    
    
}

extension StandardScoreTableViewController{
    
    func setup(pieChartView chartView: PieChartView) {
        chartView.usePercentValuesEnabled = false
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.holeRadiusPercent = 0
        chartView.transparentCircleRadiusPercent = 0
        chartView.chartDescription?.enabled = false
        chartView.setExtraOffsets(left: 5, top: 0, right: 5, bottom: 5)
        
        chartView.drawCenterTextEnabled = false
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .natural
        
        
        
        chartView.drawHoleEnabled = true
        chartView.rotationAngle = 0
        chartView.rotationEnabled = true
        chartView.highlightPerTapEnabled = true
        chartView.drawEntryLabelsEnabled = false
        
        let l = chartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = true
        l.xEntrySpace = 15
        l.yEntrySpace = 0
        l.yOffset = 0
        
        
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let entries = (0..<count).map { (i) -> PieChartDataEntry in
            // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
            
            let score = self.standardScore!.points![i].score!
            
            return PieChartDataEntry(value: Double(score), label: self.standardScore!.points![i].title , data:  nil)
        }
        
        
        let set = PieChartDataSet(values: entries, label: "")
        set.drawIconsEnabled = false
        set.sliceSpace = 5
        
        for point in self.standardScore!.points! {
            set.colors.append(hexStringToUIColor(hex: point.color!))
        }
        
        let data = PieChartData(dataSet: set)
        
        
        data.setValueFont(.systemFont(ofSize: 12, weight: .light))
        data.setValueTextColor(.black)
        
        
        chartView.data = data
        chartView.highlightValues(nil)
    }
    
    
    func loadStandardScore(){
        APIService.sharedInstance.getStandardScore([:], user_id: String(format: "%@", UserDefaults.standard.value(forKey: "id")  as! CVarArg), completionHandle: {(result, error) in
            if error == nil {
                self.standardScore = Mapper<StandardScore>().map(JSONObject: result)
                self.lblInforUse.text = String(format: "Name : %@ \nDate of Birth : %@ \nDate of Assessment : %@ \nAge at Assessment : %@", UserDefaults.standard.value(forKey: "name")  as! String,self.standardScore!.dob!, self.standardScore!.date_of_assessment!,String(self.standardScore!.age_at_assessment!))
                
                self.chartView.animate(xAxisDuration: 0.8, easingOption: .easeOutBack)
                self.setDataCount((self.standardScore?.points!.count)!, range: UInt32(100))
            }else {
                let alert = UIAlertController(title: "Error", message: "No data ", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

