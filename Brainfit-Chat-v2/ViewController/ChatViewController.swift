//
//  ChatViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/18/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import AlamofireImage
import SocketIO
import YouTubePlayer
import VIMVideoPlayer
import AVKit
import AVFoundation
//import GoogleInteractiveMediaAds

class ChatViewController: MessagesViewController  {
    var arrayListChat = Mapper<listChat>().mapArray(JSONArray: [])
    var messageList: [MockMessage] = []
    var pageNumber : Int = 0
    let refreshControl = UIRefreshControl()
    let userSender = Sender(id:String(format: "%@", UserDefaults.standard.value(forKey: "id")! as! CVarArg), displayName: String(format: "%@", UserDefaults.standard.value(forKey: "name")! as! CVarArg))
    let img = UIImageView()
    var contentPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var player : AVPlayer?
    let imageToken = UIImageView()
    var clickVideo : Int = 0
    var indexold : Int = 0
    
    
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.messageList.removeAll()
        
        let image : UIImage = UIImage(named: "logo_groupchat.png")!
        let imageView = UIImageView()
        imageView.frame.size.width = 40
        imageView.frame.size.height = 40
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        navigationItem.titleView = imageView
        
        
        configureMessageCollectionView()
        
        configureMessageInputBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didGotSocketEvent), name: NSNotification.Name(rawValue: "NotificationMessage_DidGotSocketEvent"), object: nil)
        
        
        loadHistoryChat()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(true)
        player?.pause()
        player = nil
        
    }
    @IBAction func backAction(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        SocketIOManager.sharedInstance.socketDissconectRoom()
        
        performSegue(withIdentifier: "backVC", sender: nil)
        
    }
    
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = UIColor.gray
        messageInputBar.sendButton.tintColor = UIColor.gray
    }
}

extension ChatViewController {
    func loadHistoryChat(){
        APIService.sharedInstance.getHistoryChat([:], roomId: String(format: "%@", UserDefaults.standard.value(forKey: "room")  as! CVarArg) , pagenumber: String(pageNumber), completionHandle: {(result, error) in
            if  error == nil {
                //                print(result)
                self.arrayListChat = Mapper<listChat>().mapArray(JSONArray: result as! [[String : Any]])
                
                for chat in self.arrayListChat {
                    self.typeChat(type: chat.type! , content: chat.content!, user_id: String(chat.user_id), name: chat.name!, link: chat.link! , create_at: chat.created_at!)
                }
                
                self.pageNumber = self.pageNumber + 1;
                
                //                DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
                self.messagesCollectionView.scrollToBottom(animated: true)
                //                }
            }else {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.messagesCollectionView.scrollToBottom(animated: true)
                }
            }
        })
    }
    
    @objc func loadMoreMessages()  {
        APIService.sharedInstance.getHistoryChat([:], roomId: String(format: "%@", UserDefaults.standard.value(forKey: "room")  as! CVarArg) , pagenumber: String(pageNumber), completionHandle: {(result, error) in
            if error == nil {
                self.arrayListChat = Mapper<listChat>().mapArray(JSONArray: result as! [[String : Any]])
                self.pageNumber = self.pageNumber + 1;
                
                print(self.pageNumber);
                
                for chat in self.arrayListChat {
                    self.loadMoreMessagesChat(type: chat.type! , content: chat.content!, user_id: String(chat.user_id), name: chat.name!, link: chat.link! , create_at: chat.created_at!)
                    
                }
                
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                    
                    self.player?.pause()
                    
                    for subview in self.messagesCollectionView.layer.sublayers! {
                        if subview.value(forKey: "tag") as? Int == 1{
                            subview.removeFromSuperlayer()
                        }
                    }
                }
                
            }else {
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                }
            }
        })
    }
    
    
    @objc func didGotSocketEvent(_ notifObject : NSNotification) {
        let event : SocketAnyEvent = notifObject.object as! SocketAnyEvent
        
        switch event.event {
        case "message":
            let dicReceive: NSDictionary = event.items![0] as! NSDictionary
            typeChatSocket(type: dicReceive["type"] as! String, content: dicReceive["content"] as! String, user_id: String(format: "%@", dicReceive["user_id"] as! CVarArg), name: dicReceive["name"] as! String, link: dicReceive["link"]! as! String,create_at: dicReceive["created_at"] as! String)
            break
        default:
            break
        }
    }
    
    
    func loadMoreMessagesChat(type : String, content : String , user_id : String , name : String , link : String , create_at : String ){
        var message : MockMessage
        
        switch type {
        case "text":
            message = MockMessage(text:content, sender: Sender(id: user_id , displayName:  name), messageId: UUID().uuidString, date:formatDate(strDate: create_at) , link: link , type: type)
            self.messageList.insert(message, at: 0)
            
            break
        case "youtube":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type)
            self.messageList.insert(message, at: 0)
            
            break
        case "vimeo":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at), link: link, type : type)
            self.messageList.insert(message, at: 0)
            
            break
        case "video":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at), link: link, type : type)
            self.messageList.insert(message, at: 0)
            
            break
        case "document":
            let message = MockMessage(attributedText: docmentText(content ,andLink: link)!,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type)
            self.messageList.insert(message, at: 0)
            break
        case "token":
            let url = URL(string:link)
            let placeholderImage = UIImage(named: "bg (1)")!
            img.af_setImage( withURL: url! ,placeholderImage: placeholderImage)
            let message = MockMessage(attributedText: tokenImage(content ,andLink: link)!,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type)
            self.messageList.insert(message, at: 0)
            break
            
        default:
            break
        }
        
        
    }
    
    func typeChat(type : String, content : String , user_id : String , name : String , link : String , create_at : String ){
        var message : MockMessage
        
        switch type {
        case "text":
            message = MockMessage(text:content, sender: Sender(id: user_id , displayName:  name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link , type: type)
            self.messageList.append(message)
            
            break
        case "youtube":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type)
            self.messageList.append(message)
            
            break
        case "vimeo":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date:formatDate(strDate: create_at) , link: link, type : type)
            self.messageList.append(message)
            
            break
        case "video":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type)
            self.messageList.append(message)
            
            break
        case "document":
            let message = MockMessage(attributedText: docmentText(content ,andLink: link)!,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type)
            self.messageList.append(message)
            break
        case "token":
            let url = URL(string:link)
            let placeholderImage = UIImage(named: "bg (1)")!
            img.af_setImage( withURL: url! ,placeholderImage: placeholderImage)
            let message = MockMessage(attributedText: tokenImage(content ,andLink: link)!,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type)
            self.messageList.append(message)
            break
            
        default:
            break
        }
    }
    
    func typeChatSocket(type : String, content : String , user_id : String , name : String , link : String , create_at : String ){
        var message : MockMessage
        
        switch type {
        case "text":
            message = MockMessage(text:content, sender: Sender(id: user_id , displayName:  name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link , type: type)
            self.messageList.append(message)
            
            break
        case "youtube":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type)
            self.messageList.append(message)
            
            break
        case "vimeo":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type)
            self.messageList.append(message)
            
            break
        case "video":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type)
            self.messageList.append(message)
            
            break
        case "document":
            let message = MockMessage(attributedText: docmentText(content ,andLink: link)!,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type)
            self.messageList.append(message)
            break
        case "token":
            let url = URL(string:link)
            let placeholderImage = UIImage(named: "bg (1)")!
            img.af_setImage( withURL: url! ,placeholderImage: placeholderImage)
            let message = MockMessage(attributedText: tokenImage(content ,andLink: link)!,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type)
            self.messageList.append(message)
            break
            
        default:
            break
        }
        
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }else {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    
    
    
    func tokenImage(_ text: String?, andLink link: String?) -> NSMutableAttributedString? {
        
        let string = NSMutableAttributedString()
        
        imageToken.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        imageToken.sd_setImage(with: URL(string: link ?? ""), placeholderImage: UIImage(named: "badge-1"))
        
        let attachment = NSTextAttachment()
        
        attachment.image = imageToken.image
        attachment.bounds = CGRect(x: 0, y: 0, width: 60, height: 60)
        
        let font: UIFont? = UIFont(name: "Arial", size: 16)!
        let colour = UIColor.black
        
        let attributes: [NSString : AnyObject] = [NSString(string: NSAttributedString.Key.font.rawValue): font!, NSString(string: NSAttributedString.Key.foregroundColor.rawValue): colour]
        
        let attrStr = NSAttributedString(string: "  " + "\(text ?? "")", attributes: attributes as? [NSAttributedString.Key : Any])
        
        let attrStringWithImage = NSAttributedString(attachment: attachment)
        
        string.append(attrStringWithImage)
        string.append(attrStr)
        
        return string
    }
    
    func docmentText(_ text: String?, andLink link: String?) -> NSMutableAttributedString? {
        
        let string = NSMutableAttributedString()
        
        imageToken.sd_setImage(with: URL(string: link ?? ""), placeholderImage: UIImage(named: "icons8-Download From Cloud-30"))
        
        let attachment = NSTextAttachment()
        
        attachment.image = imageToken.image
        attachment.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let font: UIFont? = UIFont(name: "Arial", size: 16)!
        let colour = UIColor.black
        
        let attributes: [NSString : AnyObject] = [NSString(string: NSAttributedString.Key.font.rawValue): font!, NSString(string: NSAttributedString.Key.foregroundColor.rawValue): colour]
        
        let attrStr = NSAttributedString(string: "  "+"\(text ?? "")", attributes: attributes as? [NSAttributedString.Key : Any])
        
        let attrStringWithImage = NSAttributedString(attachment: attachment)
        
        string.append(attrStringWithImage)
        string.append(attrStr)
        
        return string
    }
}

extension ChatViewController : MessagesDataSource {
    func currentSender() -> Sender {
        return userSender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return self.messageList[indexPath.section] as MessageType
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        //        if indexPath.section % 3 == 0 {
        //            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        //        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func formatDate(strDate : String) -> Date {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatterGet.locale = Locale.current
        let date: Date = dateFormatterGet.date(from: strDate )!
        
        return date
    }
    
}



// MARK: - MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let message = messageList[indexPath.section]
            switch message.Type {
            case "youtube":
                let videoPlayer = YouTubePlayerView(frame: CGRect(x: 50, y: cell.frame.minY + 50, width: 300 , height: 190))
                videoPlayer.playerVars = [
                    "playsinline": "1",
                    "modestbranding": "1",
                    "rel": "0",
                    "showinfo" : "0"
                    ] as YouTubePlayerView.YouTubePlayerParameters
                
                let myVideoURL = NSURL(string: "https://www.youtube.com/watch?v=" + message.Link)
                videoPlayer.loadVideoURL(myVideoURL! as URL)
                messagesCollectionView.addSubview(videoPlayer)
                break
            case "vimeo":
                let myVideoURL = NSURL(string: "https://vimeo.com/" + message.Link)
                
                UIApplication.shared.open(myVideoURL! as URL, options: [:], completionHandler: nil)
                break
            case "video":
                player?.pause()
//                player = nil
                player = AVPlayer(url: URL(string:message.Link)!)
                
                if indexold == indexPath.section{
                    clickVideo = 1
                }else {
                    clickVideo = 0
                }
                
                if clickVideo == 0  {
                    playerLayer = AVPlayerLayer(player: player)
                    
                    playerLayer!.frame = CGRect(x: 50, y: cell.frame.minY + 10, width: 300 , height: 250)
                    player?.play()
                    playerLayer?.setValue(1, forKey: "tag")
                    clickVideo = 1;
                    messagesCollectionView.layer.addSublayer(playerLayer!)
                    indexold = indexPath.section
                }else {
                    let window = UIApplication.shared.keyWindow!
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    playerViewController.view.frame = CGRect(x: 50, y: cell.frame.minY + 10, width: cell.frame.width , height: cell.frame.height + 20)
                    playerViewController.showsPlaybackControls = true
                    playerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                    window.addSubview(playerViewController.view)
                    clickVideo = 0;
                }
                break
            case "document":
                let docLink = NSURL(string: message.Link)
                UIApplication.shared.open(docLink! as URL, options: [:], completionHandler: nil)
                break
            case "token":
                break
            default:
                break
            }
        }
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
}

// MARK: - MessageLabelDelegate
extension ChatViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
}

// MARK: - MessageInputBarDelegate
extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        let timestamp = "\(Date().timeIntervalSince1970 * 1000)"
        
        SocketIOManager.sharedInstance.socketSendMessage(text: "text", message: text, link: "", timeStamp: String(format:"%@", timestamp))
        
        inputBar.inputTextView.text = String()
        //  messagesCollectionView.scrollToBottom(animated: true)
    }
    
}
