//
//  ListMemberChatTableViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/22/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import AlamofireImage



class ListMemberChatTableViewController: UITableViewController {
    var listMember = Mapper<listUserChat>().map(JSONObject: ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image : UIImage = UIImage(named: "logo_groupchat.png")!
        let imageView = UIImageView()
        imageView.frame.size.width = 40
        imageView.frame.size.height = 40
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        navigationItem.titleView = imageView
        
        
        self.tableView.estimatedRowHeight = 105
        self.tableView.rowHeight = UITableView.automaticDimension
        
        getListMember()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.listMember == nil {
            return 0
        }else {
            return (self.listMember?.users!.count)!
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! ListMemberTableViewCell
        let user = self.listMember?.users![indexPath.row]
        let url = URL(string: user?.avatar! ?? "")!
        let placeholderImage = UIImage(named: "avatar_student (1)")!
        DispatchQueue.main.async {
            cell.imageAvatar.af_setImage( withURL: url,placeholderImage: placeholderImage)
        }
        cell.lblName.text = self.listMember?.users![indexPath.row].name
        
        if user?.role == "student" {
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.listMember?.users![indexPath.row]
        
        if user?.role == "student" {
            self.performSegue(withIdentifier: "token", sender: self)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "token" {
            let token = segue.destination as! ListTokenViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                token.arrayToken = (self.listMember?.users![indexPath.row].tokens)!
            }
        }
    }
}

extension ListMemberChatTableViewController {
    func getListMember() {
        APIService.sharedInstance.getListMember([:], roomId:  String(format: "%@", UserDefaults.standard.value(forKey: "room")  as! CVarArg), completionHandle: {(result, error) in
            self.listMember = Mapper<listUserChat>().map(JSONObject: result as! [String:Any])
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
}
