//
//  ChatViewController.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/18/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import AlamofireImage
import SocketIO
import YouTubePlayer
import VIMVideoPlayer
import AVKit
import AVFoundation
import SwiftLinkPreview
import LinkPresentation
import MobileCoreServices
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
    let appdelgate = UIApplication.shared.delegate as? AppDelegate
    var videoPlayer: YouTubePlayerView!
    let imagePickerController = UIImagePickerController()
    
    private let slp = SwiftLinkPreview(cache: InMemoryCache())
    
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
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(true)
        player?.pause()
        player = nil
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        
        UserDefaults.standard.removeObject(forKey: "room")
        SocketIOManager.sharedInstance.socketDissconectRoom()
        
        performSegue(withIdentifier: "backVC", sender: nil)
    }
    
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        messageInputBar.delegate = self
        
        //        messageInputBar.butt
        
        messagesCollectionView.scrollIndicatorInsets.bottom = messageInputBar.frame.height
        
        scrollsToBottomOnKeyboardBeginsEditing = false // default false
        maintainPositionOnKeyboardFrameChanged = false // default false
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    
    
    func configureMessageInputBar() {
        messageInputBar.inputTextView.tintColor = UIColor.gray
        messageInputBar.sendButton.tintColor = UIColor.gray
        configureInputBarItems()
    }
    
    private func configureInputBarItems() {
        let bottomItems = [makeButton(named: "ic_at"),makeButton(named: "ic_at"),.flexibleSpace]
        messageInputBar.middleContentViewPadding.left = 16
        messageInputBar.setLeftStackViewWidthConstant(to: 16, animated: false)
        
        messageInputBar.setStackViewItems(bottomItems, forStack: .left, animated: false)
        
        //        // This just adds some more flare
        //        messageInputBar.sendButton
        //            .onEnabled { item in
        //                UIView.animate(withDuration: 0.3, animations: {
        //                    item.imageView?.backgroundColor = .red
        //                })
        //            }.onDisabled { item in
        //                UIView.animate(withDuration: 0.3, animations: {
        //                    item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        //                })
        //        }
    }
    
    private func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 40, height: 40), animated: false)
                $0.tintColor = UIColor(white: 0.8, alpha: 1)
        }.onSelected {
            $0.tintColor = .gray
        }.onDeselected {
            $0.tintColor = UIColor(white: 0.8, alpha: 1)
        }.onTouchUpInside { _ in
            print("Item Tapped")
            //            self.clickFunction()
            self.getFile()
            //            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            //            do {
            //
            //                let objectsToShare = ["fileURL"]
            //                let activityVC = UIActivityViewController(activityItems: objectsToShare as [Any], applicationActivities: nil)
            //
            //                self.present(activityVC, animated: true, completion: nil)
            //
            //            } catch {
            //                print("cannot write file")
            //            }
        }
    }
    
}

extension ChatViewController {
    func loadHistoryChat(){
        self.appdelgate?.showLoading()
        APIService.sharedInstance.getHistoryChat([:], roomId: String(format: "%@", UserDefaults.standard.value(forKey: "room")  as! CVarArg) , pagenumber: String(pageNumber), completionHandle: {(result, error) in
            if  error == nil {
                print(result)
                self.arrayListChat = Mapper<listChat>().mapArray(JSONArray: result as! [[String : Any]])
                
                for chat in self.arrayListChat {
                    //                    self.typeChat(type: chat.type! , content: chat.content!, user_id: String(chat.user_id), name: chat.name!, link: chat.link! , create_at: chat.created_at!)
                }
                
                self.pageNumber = self.pageNumber + 1;
                
                self.messagesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
                self.messagesCollectionView.scrollToBottom(animated: true)
                self.appdelgate?.dismissLoading()
            }else {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.appdelgate?.dismissLoading()
                    self.messagesCollectionView.scrollToBottom(animated: true)
                }
            }
        })
    }
    
    @objc func loadMoreMessages()  {
        APIService.sharedInstance.getHistoryChat([:], roomId: String(format: "%@", UserDefaults.standard.value(forKey: "room")  as! CVarArg) , pagenumber: String(pageNumber), completionHandle: {(result, error) in
            if error == nil {
                print(result)
                self.arrayListChat = Mapper<listChat>().mapArray(JSONArray: result as! [[String : Any]])
                self.arrayListChat = Array(self.arrayListChat.reversed())
                self.pageNumber = self.pageNumber + 1;
                
                print(self.pageNumber);
                
                for chat in self.arrayListChat {
                    self.loadMoreMessagesChat(type: chat.type! , content: chat.content!, user_id: String(chat.user_id), name: chat.name!, link: chat.link! , create_at: chat.created_at!)
                    
                }
                
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                    
                    self.player?.pause()
                    
                    // remove subview video
                    for subview in self.messagesCollectionView.layer.sublayers! {
                        if subview.value(forKey: "tag") as? Int == 1{
                            subview.removeFromSuperlayer()
                        }
                    }
                    for subview in self.messagesCollectionView.subviews {
                        if subview.value(forKey: "tag") as? Int == 1{
                            subview.removeFromSuperview()
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
            print(event)
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
            //                        let message = MockMessage(attributedText:  ,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type)
            //            let message = MockMessage(image:thumbnailForVideoAtURL(urltext: "https://github.com/nathantannar4/InputBarAccessoryView/tree/master/Example/Example"), sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type)
            
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
            message = MockMessage(text:"<meta name=\"twitter:image\" content=\"http://www.example.com/image.jpg\">", sender: Sender(id: user_id , displayName:  name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link , type: type)
            self.messageList.append(message)
            //            let message = MockMessage(attributedText: thumbnailWebsite ,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type)
            //            self.messageList.append(message)
            
            
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
    
    func thumbnailWebsite() -> NSAttributedString {
        let attrStringhtml = NSAttributedString(string: "<meta name=\"twitter:image\" content=\"http://www.example.com/image.jpg\">")
        
        return attrStringhtml as! NSAttributedString
    }
    
    private func thumbnailForVideoAtURL(urltext: String) -> UIImage {
        
        if let url = self.slp.extractURL(text: urltext),
            let cached = self.slp.cache.slp_getCachedResponse(url: url.absoluteString) {
            print(cached)
            
        } else {
            self.slp.preview( urltext,onSuccess: { result in
                
                let url = URL(string: result.icon ?? "")
                
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url! ) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        return UIImage(data: data!)
                    }
                }
            },onError: { error in
                print(error)
            })
        }
        return UIImage()
    }
    
}

extension ChatViewController : MessagesDataSource {
    func currentSender() -> SenderType {
        return userSender
    }
    
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
                videoPlayer = YouTubePlayerView(frame: CGRect(x: 50, y: cell.frame.minY + 40, width: 300 , height: 190))
                videoPlayer.setValue(1, forKey: "tag")
                videoPlayer.delegate = self
                
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
        //        messageInputBar.inputTextView.resignFirstResponder()
        //        view.endEditing(true)
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
        //        messageInputBar.inputTextView.resignFirstResponder()
        //        view.endEditing(true)
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
        //        messageInputBar.inputTextView.resignFirstResponder()
        //        view.endEditing(true)
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
        //        messageInputBar.inputTextView.resignFirstResponder()
        //        view.endEditing(true)
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
//extension ChatViewController: MessageInputBarDelegate {

//    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
//
//        (text.count)
//
//        if text.count < 8000 {
//            let timestamp = "\(Date().timeIntervalSince1970 * 1000)"
//
//            SocketIOManager.sharedInstance.socketSendMessage(text: "text", message: text, link: "", timeStamp: String(format:"%@", timestamp))
//
//            inputBar.inputTextView.text = String()
//        }else {
//            let alert = UIAlertController(title: "Warning", message: "Maximum character limit has been exceeded. Please reduce your chat.", preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//
//        }
//    }

//}


extension ChatViewController : MessageInputBarDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        print(text.count)
        
        if text.count < 8000 {
            let timestamp = "\(Date().timeIntervalSince1970 * 1000)"
            
            SocketIOManager.sharedInstance.socketSendMessage(text: "text", message: text, link: "", timeStamp: String(format:"%@", timestamp))
            
            inputBar.inputTextView.text = String()
        }else {
            let alert = UIAlertController(title: "Warning", message: "Maximum character limit has been exceeded. Please reduce your chat.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        //  messagesCollectionView.scrollToBottom(animated: true)
        
    }
}

extension ChatViewController : YouTubePlayerDelegate{
    func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
        print("playerStateChanged")
        view.endEditing(true)
    }
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        print("playerReady")
    }
    func playerQualityChanged(_ videoPlayer: YouTubePlayerView, playbackQuality: YouTubePlaybackQuality) {
        print("playerQualityChanged")
    }
}

extension ChatViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func getFile(){
        
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        
        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.mediaURL] as! URL
//        guard let videoData = image.jpegData(compressionQuality: 1) else { return }
        
        let videoData = try! Data.init(contentsOf: image )
        
        APIService.sharedInstance.uploadFile(roomId: String(format: "%@", UserDefaults.standard.value(forKey: "room")  as! CVarArg) , fileUrl: videoData, imageData: nil, parameters: [:], completionHandle: {(result, error) in
            
        })
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}


extension ChatViewController : UIDocumentMenuDelegate,UIDocumentPickerDelegate{
    func clickFunction(){
        
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        self.present(importMenu, animated: true, completion: nil)
    }
    
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        //        let data = try! Data(contentsOf: myURL)
        let data = try! Data(contentsOf: myURL.asURL())
        
        
        APIService.sharedInstance.uploadFile(roomId: String(format: "%@", UserDefaults.standard.value(forKey: "room")  as! CVarArg) , fileUrl: data , imageData: nil, parameters: [:], completionHandle: {(result, error) in
            
        })
        
        print("import result : \(myURL)")
    }
    
    
    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
}
