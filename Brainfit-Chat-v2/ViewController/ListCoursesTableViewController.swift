//
//  ListCoursesTableViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 9/27/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import AlamofireImage


class ListCoursesTableViewController: UITableViewController {
    let appdelgate = UIApplication.shared.delegate as? AppDelegate
    
    var courses = Mapper<courses>().map(JSONObject: ())
    var courseId : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image : UIImage = UIImage(named: "logo_groupchat.png")!
        let imageView = UIImageView()
        imageView.frame.size.width = 40
        imageView.frame.size.height = 40
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        navigationItem.titleView = imageView
        
        
        getCourses()
        
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.courses?.dataCourses?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCourses", for: indexPath) as! CourseTableViewCell
        
        let course = self.courses?.dataCourses?[indexPath.row]
        let url = URL(string: course?.image ?? "")!
        
        cell.imgCourses.sd_setImage(with: url)
        cell.txtTitle.text = course?.title
        cell.txtContent.text = course?.content?.htmlToString
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = self.courses?.dataCourses?[indexPath.row]
        courseId = course?.id ?? 0
        self.performSegue(withIdentifier: "detailCourse", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailCourse" {
            let courseVC = segue.destination as! CoursesDetailViewController
            courseVC.courseID = courseId
            
        }
    }
    
    
}

extension ListCoursesTableViewController{
    func getCourses(){
        self.appdelgate?.showLoading()
        APIService.sharedInstance.getListCourses([:], completionHandle: {(result, error) in
            if error == nil {
                self.courses = Mapper<courses>().map(JSONObject: result)
                self.tableView.reloadData()
                self.appdelgate?.dismissLoading()
                
            }else {
                self.appdelgate?.dismissLoading()
                let alert = UIAlertController(title: "Error", message: (error as! String), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        })
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

public extension UIImage {

    func tint(with fillColor: UIColor) -> UIImage? {
        let image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        fillColor.set()
        image.draw(in: CGRect(origin: .zero, size: size))

        guard let imageColored = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        UIGraphicsEndImageContext()
        return imageColored
    }
}
