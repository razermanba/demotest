//
//  ProgressScoreTableViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 5/21/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import Charts


class ProgressScoreTableViewController: UITableViewController,ChartViewDelegate {
    
    var progressScore = Mapper<ProgressScore>().map(JSONObject: ())
    
    @IBOutlet weak var chartView: LineChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getProgressSore()
         chartView.delegate = self
        
    }
    
    
}

extension ProgressScoreTableViewController {
    func getProgressSore() {
        APIService.sharedInstance.getProgressScore([:] , user_id: String(format: "%@", UserDefaults.standard.value(forKey: "id")  as! CVarArg), completionHandle: {(result, error) in
            if error == nil {
                self.progressScore = Mapper<ProgressScore>().map(JSONObject: result)
                self.setupChartLine ()
                self.setDataCount(0, range: 100)
            }else {
                let alert = UIAlertController(title: "Error", message: "No data ", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func setupChartLine(){
        chartView.delegate = self
        
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = true
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.xAxis.labelPosition = .bottom
        chartView.scaleYEnabled = false
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:(self.progressScore?.labels!)!)
        chartView.xAxis.granularity = 1
        
        chartView.leftAxis.labelCount = 4
        chartView.notifyDataSetChanged()
        
        let leftAxis = chartView.leftAxis
        leftAxis.removeAllLimitLines()
        leftAxis.axisMaximum = 100
        leftAxis.axisMinimum = 0
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        chartView.rightAxis.enabled = false
        
        chartView.legend.form = .line
        chartView.legend.orientation = .horizontal
        chartView.legend.horizontalAlignment = .left
        chartView.legend.yOffset = 0
        chartView.legend.xEntrySpace = 50
        
        chartView.animate(xAxisDuration: 1)
    }
    
    func setDataCount(_ count: Int, range: UInt32) {
        let ChartData = LineChartData()
    
        for datasets in self.progressScore!.datasets!{
            
            let values = (0..<datasets.data!.count).map { (i) -> ChartDataEntry in
                
                return ChartDataEntry(x: Double(i), y: Double(datasets.data![i]), icon: nil)
            }
            
            let set1 = LineChartDataSet(values: values, label: datasets.label)
            set1.drawIconsEnabled = false
            
            set1.axisDependency = .left
            set1.setColor(hexStringToUIColor(hex: datasets.backgroundColor!))
            set1.setCircleColor(hexStringToUIColor(hex: datasets.backgroundColor!))
            set1.lineWidth = 1
            set1.circleRadius = 5
            
            set1.fillAlpha = 225/255
            set1.drawCircleHoleEnabled = false
            set1.drawFilledEnabled = true

            
            ChartData.addDataSet(set1)
            chartView.data = ChartData
        }
        
        
        for set in chartView.data!.dataSets as! [LineChartDataSet] {
            print(set.drawFilledEnabled)
            set.drawFilledEnabled = !set.drawFilledEnabled
        }
        
        for set in chartView.data!.dataSets {
            set.drawValuesEnabled = !set.drawValuesEnabled
        }
//        chartView.fitScreen()
        chartView.setScaleMinima(10, scaleY: 0)
//        chartView.setNeedsDisplay()
        
        let barLineChart = chartView as BarLineChartViewBase
        barLineChart.autoScaleMinMaxEnabled = !barLineChart.isAutoScaleMinMaxEnabled
        chartView.notifyDataSetChanged()

        
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
