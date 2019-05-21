//
//  RoomChatTableViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/18/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import AlamofireImage


class RoomChatTableViewController: UITableViewController {
    
    var arrayRoom = Mapper<RoomChat>().mapArray(JSONArray: [])
    var roomID : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let image : UIImage = UIImage(named: "logo_groupchat.png")!
        let imageView = UIImageView()
        imageView.frame.size.width = 40
        imageView.frame.size.height = 40
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        navigationItem.titleView = imageView
        
        
        self.tableView.estimatedRowHeight = 83
        self.tableView.rowHeight = UITableView.automaticDimension
        
        getListRoom(pageNumber: 0)
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return arrayRoom.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "RoomChatCell", for: indexPath) as! ChatRoomTableViewCell
        
        cell.lblTitle.text = arrayRoom[indexPath.row].name
        let url = URL(string: arrayRoom[indexPath.row].avatar!)!
        let placeholderImage = UIImage(named: "avatar_student (1)")!
        DispatchQueue.main.async {
            cell.imageRoom.af_setImage( withURL: url,placeholderImage: placeholderImage)
        }
        cell.lblContent.text = arrayRoom[indexPath.row].message?.content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        UserDefaults.standard.set(arrayRoom[indexPath.row].room_id!, forKey: "room")
        
        SocketIOManager.sharedInstance.socketConnect()
        
        self.performSegue(withIdentifier: "Chat", sender: self)
        
    }
    
  
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Chat" {
            
//            let navVC = segue.destination as! UINavigationController
//            let chatView = navVC.viewControllers.first as! ChatViewController
            
        }
    }
}

extension RoomChatTableViewController{
    func getListRoom(pageNumber : Int){
        APIService.sharedInstance.getListRoom([:], pagenumber: String(pageNumber) , completionHandle: {(result, error) in
            self.arrayRoom = Mapper<RoomChat>().mapArray(JSONArray: result as! [[String : Any]])
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
            }            
        })
    }
}
