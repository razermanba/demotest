//
//  CoursesDetailViewController.swift
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
import AVKit


class CoursesDetailViewController: UIViewController {
    var courseID : Int = 0
    let appdelgate = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet weak var tableView: UITableView!
    var indexRowSelect : Int?
    var indexSectionSelect : Int?
    var playerLayer: AVPlayerLayer?
    var player : AVPlayer?
    @IBOutlet weak var viewPlayer: UIView!
    var cellButton : CoursesButtonTableViewCell! = nil
    
    var contentText : String = ""
    
    
    var courses = Mapper<CoursesDetail>().map(JSONObject: ())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image : UIImage = UIImage(named: "logo_groupchat.png")!
        let imageView = UIImageView()
        imageView.frame.size.width = 40
        imageView.frame.size.height = 40
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        navigationItem.titleView = imageView

        getCourses(courseID: String(courseID))
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @objc func actionResoucres(){
        
        contentText = "resoucres"
        
        tableView.reloadData()
        
        let lineViewResoucres = UIView(frame: CGRect(x: 0, y: cellButton.btnResoucres.frame.size.height, width: cellButton.btnResoucres.frame.size.width, height: 1.5))
        lineViewResoucres.backgroundColor = UIColor.red
        cellButton.btnResoucres.tintColor = UIColor.red
        cellButton.btnResoucres.addSubview(lineViewResoucres)
        
        let lineViewDescrition = UIView(frame: CGRect(x: 0, y: cellButton.btnResoucres.frame.size.height, width: cellButton.Descrition.frame.size.width, height: 1.5))
        lineViewDescrition.backgroundColor = UIColor.black
        cellButton.Descrition.tintColor = UIColor.black
        cellButton.Descrition.addSubview(lineViewDescrition)
        
        
    }
    
    @objc func actionDescrition(){
        
        contentText = "descrition"
        
        tableView.reloadData()
        
        let lineViewResoucres = UIView(frame: CGRect(x: 0, y: cellButton.btnResoucres.frame.size.height, width: cellButton.btnResoucres.frame.size.width, height: 1.5))
        lineViewResoucres.backgroundColor = UIColor.black
        cellButton.btnResoucres.tintColor = UIColor.black
        cellButton.btnResoucres.addSubview(lineViewResoucres)
        
        let lineViewDescrition = UIView(frame: CGRect(x: 0, y: cellButton.btnResoucres.frame.size.height, width: cellButton.Descrition.frame.size.width, height: 1.5))
        lineViewDescrition.backgroundColor = UIColor.red
        cellButton.Descrition.tintColor = UIColor.red
        cellButton.Descrition.addSubview(lineViewDescrition)
        
    }
}

// MARK: - Table view data source
extension CoursesDetailViewController : UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.courses?.topics?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return self.courses?.topics?[section - 1].media?.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellTitle", for: indexPath) as! CoursesTitleTableViewCell
                cell.txtTitle.text = self.courses?.title
                cell.txtResoucre.text = String(format: "%d resoucre", self.courses?.topics?.count ?? 0)
                return cell
            default:
                cellButton = tableView.dequeueReusableCell(withIdentifier: "cellButton", for: indexPath) as? CoursesButtonTableViewCell
                cellButton.btnResoucres.addTarget(self, action: #selector(actionResoucres), for: .touchUpInside)
                cellButton.Descrition.addTarget(self, action: #selector(actionDescrition), for: .touchUpInside)
                
                
                return cellButton
            }
        }else {
            //
            switch contentText {
            case "descrition":
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellDescription", for: indexPath) as! CoursesDescriptionTableViewCell
                cell.txtDesciption.text = self.courses?.description?.htmlToString

                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellTopic", for: indexPath) as! CoursesTopicTableViewCell
                let course = self.courses?.topics![indexPath.section - 1].media
                let media = course![indexPath.row]
                cell.txtTitle.text = media.title
                cell.txtIndex.text = String(indexPath.row + 1)
                if media.context == "document" {
                    cell.imgType.image = #imageLiteral(resourceName: "border_ticked_signin")
                    //                    UIImage.init(named: "doc")
                }else {
                    cell.imgType.image = #imageLiteral(resourceName: "icons8-Edit-48")
                }
                
                if indexRowSelect == indexPath.row && indexSectionSelect == indexPath.section {
                    cell.txtIndex.textColor = UIColor.red
                    cell.txtTitle.textColor = UIColor.red
                }else {
                    cell.txtIndex.textColor = UIColor.black
                    cell.txtTitle.textColor = UIColor.black
                }
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 0{
            indexRowSelect = indexPath.row
            indexSectionSelect = indexPath.section
            
            let course = self.courses?.topics![indexSectionSelect! - 1].media
            let media = course![indexRowSelect!]
            
            if media.context == "video" {
                player?.pause()
                player = nil
                
                player = AVPlayer(url: URL(string:media.file ?? "")!)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                playerViewController.view.frame = viewPlayer.bounds
                self.addChild(playerViewController)
                viewPlayer.addSubview(playerViewController.view)
                playerViewController.player!.play()
                playerViewController.didMove(toParent: self)
            }
            
            tableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        if  section >= 1{
            let coures = self.courses?.topics?[section - 1]
            let sectionLabel = UILabel(frame: CGRect(x: 16 , y: 0 , width:tableView.bounds.size.width, height: 10))
            sectionLabel.font = UIFont(name: "Helvetica", size: 12)
            sectionLabel.textColor = UIColor.darkGray
            sectionLabel.text = coures?.title
            sectionLabel.sizeToFit()
            headerView.addSubview(sectionLabel)
        }
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section >= 1{
            return 10
        }else {
            return 0
        }
    }
    
}

extension CoursesDetailViewController{
    func getCourses(courseID : String){
        self.appdelgate?.showLoading()
        APIService.sharedInstance.coursesDetail([:], courses_id: courseID, completionHandle:{(result, error) in
            if error == nil {
                self.courses = Mapper<CoursesDetail>().map(JSONObject: result)
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

