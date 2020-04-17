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
import Nuke

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
    let imageview = UIImageView()
    
    var viewFullImage = (Bundle.main.loadNibNamed("ViewFullImage", owner: self, options: nil)?.first as? ViewFullImage)!
    
    private let slp = SwiftLinkPreview(cache: InMemoryCache())
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
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
        messageInputBar.sendButton.setSize(CGSize(width: 50, height: 40), animated: true)
        configureInputBarItems()
    }
    
    private func configureInputBarItems() {
        let bottomItems = [makeButtonVideo(named: "bfchat-ic-camera"),makeButtonDoc(named: "bfchat-ic-file"),.flexibleSpace]
        messageInputBar.middleContentViewPadding.left = 0
        messageInputBar.leftStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0)
        messageInputBar.leftStackView.isLayoutMarginsRelativeArrangement = true
        messageInputBar.setLeftStackViewWidthConstant(to: 60, animated: false)
        
        messageInputBar.setStackViewItems(bottomItems, forStack: .left, animated: false)
        
    }
    
    private func makeButtonVideo(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(0)
                $0.setBackgroundImage(UIImage(named: named), for: .normal)// = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
                $0.tintColor = UIColor(red:0.00, green:0.60, blue:0.80, alpha:1.00)
        }.onSelected {
            $0.tintColor = .gray
        }.onDeselected {
            $0.tintColor = UIColor(red:0.00, green:0.60, blue:0.80, alpha:1.00)
        }.onTouchUpInside { _ in
            print("Item Tapped")
            self.getFileMedia()
            
        }
    }
    
    private func makeButtonDoc(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(0)
                $0.setBackgroundImage(UIImage(named: named), for: .normal) //= UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
                $0.tintColor = UIColor(red:1.00, green:0.20, blue:0.20, alpha:1.00)
        }.onSelected {
            $0.tintColor = .gray
        }.onDeselected {
            $0.tintColor = UIColor(red:1.00, green:0.20, blue:0.20, alpha:1.00)
        }.onTouchUpInside { _ in
            print("Item Tapped")
            self.clickFunction()
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
                    self.typeChat(type: chat.type ?? "" , file_type: chat.file_type ?? "" , content: chat.content ?? "", user_id: String(chat.user_id), name: chat.name ?? "", link: chat.link ?? "" , create_at: chat.created_at ?? "")
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
                    self.loadMoreMessagesChat(type: chat.type ?? ""  , file_type: chat.file_type ?? "" , content: chat.content ?? "" , user_id: String(chat.user_id), name: chat.name!, link: chat.link ?? ""  , create_at: chat.created_at ?? "" )
                    
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
            print(event)
            let dicReceive: NSDictionary = event.items![0] as! NSDictionary
            typeChatSocket(type: dicReceive["type"] as! String , file_type: dicReceive["file_type"] as! String , content: dicReceive["content"] as! String, user_id: String(format: "%@", dicReceive["user_id"] as! CVarArg), name: dicReceive["name"] as! String, link: dicReceive["link"]! as! String,create_at: dicReceive["created_at"] as! String)
            break
        default:
            print(event)
            break
        }
    }
    
    
    func loadMoreMessagesChat(type : String , file_type : String, content : String , user_id : String , name : String , link : String , create_at : String ){
        var message : MockMessage
        
        switch type {
        case "text":
            if  verifyUrl(urlString: content) {
                let url = URL(string: String(format: "%@",content))!

                let options = ImageLoadingOptions(
                    placeholder: UIImage(named: "placeholder"),
                    transition: .fadeIn(duration: 0.33)
                )
                Nuke.loadImage(with: url, options: options, into: imageview)

                let message = MockMessage(image:imageview.image!, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: content, type : "html" ,file_type: "html")
                self.messageList.append(message)

            }else {
                message = MockMessage(text:content, sender: Sender(id: user_id , displayName:  name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link , type: type,file_type: file_type)
                self.messageList.append(message)
            }
            break
        case "youtube":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
            self.messageList.insert(message, at: 0)
            
            break
        case "vimeo":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at), link: link, type : type,file_type: file_type)
            self.messageList.insert(message, at: 0)
            
            break
        case "video":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at), link: link, type : type,file_type: file_type)
            self.messageList.insert(message, at: 0)
            
            break
        case "document":
            switch file_type {
            case "mov","mp4":
                let placeholderImage = UIImage(named: "bg (1)")!
                
                let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date:formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
                self.messageList.insert(message, at: 0)
                break
            case "mp3":
                
                let message = MockMessage(sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
                self.messageList.append(message)
                break
                
            case "png","jpg","jpeg":
                let imageview = UIImageView()
                
                
                let url = URL(string: String(format: "%@",link))!
                let options = ImageLoadingOptions(
                    placeholder: UIImage(named: "placeholder"),
                    transition: .fadeIn(duration: 0.33)
                )
                
                Nuke.loadImage(with: url, options: options, into: imageview)
                
                let message = MockMessage(image:imageview.image!, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
                self.messageList.insert(message, at: 0)
                
                break
            default:
                let message = MockMessage(attributedText: docmentText(content ,andLink: link)!,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type,file_type: file_type)
                self.messageList.insert(message, at: 0)
                
            }
            break
        case "token":
            let url = URL(string:link)
            let placeholderImage = UIImage(named: "bg (1)")!
            img.af_setImage( withURL: url! ,placeholderImage: placeholderImage)
            let message = MockMessage(attributedText: tokenImage(content ,andLink: link)!,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type,file_type: file_type)
            self.messageList.insert(message, at: 0)
            break
            
        default:
            break
        }
        
        
    }
    
    func typeChat(type : String , file_type : String, content : String , user_id : String , name : String , link : String , create_at : String ){
        var message : MockMessage
        
        switch type {
        case "text":
            if  verifyUrl(urlString: content) {
                let url = URL(string: String(format: "%@",content))!

                let options = ImageLoadingOptions(
                    placeholder: UIImage(named: "placeholder"),
                    transition: .fadeIn(duration: 0.33)
                )
                Nuke.loadImage(with: url, options: options, into: imageview)

                let message = MockMessage(image:imageview.image!, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: content, type : "html" ,file_type: "html")
                self.messageList.append(message)

            }else {
                message = MockMessage(text:content, sender: Sender(id: user_id , displayName:  name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link , type: type,file_type: file_type)
                self.messageList.append(message)
            }
            break
        case "youtube":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
            self.messageList.append(message)
            
            break
        case "vimeo":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date:formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
            self.messageList.append(message)
            
            break
        case "video":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
            self.messageList.append(message)
            
            break
        case "document":
            switch file_type {
            case "mov","mp4":
                let placeholderImage = UIImage(named: "bg (1)")!
                
                let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date:formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
                self.messageList.append(message)
                
                break
            case "mp3":
                
                let message = MockMessage(sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
                self.messageList.append(message)
                break
                
            case "png","jpg","jpeg":
                print(link)
                let url = URL(string: link)!
                
                let options = ImageLoadingOptions(
                    placeholder: UIImage(named: "placeholder"),
                    transition: .fadeIn(duration: 0.33)
                )
                
                DispatchQueue.main.async {
                    Nuke.loadImage(with: url, options: options, into: self.imageview)
                }
                
                let message = MockMessage(image:self.imageview.image ?? UIImage(), sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: self.formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
                self.messageList.append(message)
                
                
                break
                
            default:
                let message = MockMessage(attributedText: docmentText(content ,andLink: link)!,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type,file_type: file_type)
                self.messageList.append(message)
                
            }
            break
        case "token":
            let url = URL(string:link)
            let placeholderImage = UIImage(named: "bg (1)")!
            img.af_setImage( withURL: url! ,placeholderImage: placeholderImage)
            let message = MockMessage(attributedText: tokenImage(content ,andLink: link)!,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type,file_type: file_type)
            self.messageList.append(message)
            break
            
        default:
            break
        }
    }
    
    func typeChatSocket(type : String ,file_type : String , content : String , user_id : String , name : String , link : String , create_at : String ){
        var message : MockMessage
        
        switch type {
        case "text":
            if  verifyUrl(urlString: content) {
                 let url = URL(string: String(format: "%@",content))!

                let options = ImageLoadingOptions(
                    placeholder: UIImage(named: "placeholder"),
                    transition: .fadeIn(duration: 0.33)
                )
                Nuke.loadImage(with: url, options: options, into: imageview)

                let message = MockMessage(image:imageview.image!, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: content, type : "html" ,file_type: "html")
                self.messageList.append(message)
            }else {
                message = MockMessage(text:content, sender: Sender(id: user_id , displayName:  name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link , type: type,file_type: file_type)
                self.messageList.append(message)
            }
            break
        case "youtube":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
            self.messageList.append(message)
            
            break
        case "vimeo":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
            self.messageList.append(message)
            
            break
        case "video":
            let placeholderImage = UIImage(named: "bg (1)")!
            
            let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
            self.messageList.append(message)
            
            break
        case "document":
            switch file_type {
            case "mov","mp4":
                let placeholderImage = UIImage(named: "bg (1)")!
                
                let message = MockMessage(image:placeholderImage, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
                self.messageList.append(message)
                break
            case "mp3":
                
                let message = MockMessage(sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
                self.messageList.append(message)
                break
            case "png","jpg","jpeg":
                let url = URL(string: String(format: "%@",link))!
                
                let options = ImageLoadingOptions(
                    placeholder: UIImage(named: "placeholder"),
                    transition: .fadeIn(duration: 0.33)
                )
                Nuke.loadImage(with: url, options: options, into: imageview)
                
                let message = MockMessage(image:imageview.image!, sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at) , link: link, type : type,file_type: file_type)
                self.messageList.append(message)
                
                break
            default:
                let message = MockMessage(attributedText: docmentText(content ,andLink: link)!,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type,file_type: file_type)
                self.messageList.append(message)
                
            }
            break
        case "token":
            let url = URL(string:link)
            let placeholderImage = UIImage(named: "bg (1)")!
            img.af_setImage( withURL: url! ,placeholderImage: placeholderImage)
            let message = MockMessage(attributedText: tokenImage(content ,andLink: link)!,  sender: Sender(id: user_id, displayName:name), messageId: UUID().uuidString, date: formatDate(strDate: create_at),link: link , type:type,file_type: file_type)
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
                let playerViewController = AVPlayerViewController()
                player = AVPlayer(url: URL(string:message.Link)!)
                playerViewController.player = player
                playerViewController.view.frame = CGRect(x: 50, y: cell.frame.minY + 15, width: 280 , height: cell.frame.height - 30)
                playerViewController.view.setValue(1, forKey: "tag")
                self.addChild(playerViewController)
                
                messagesCollectionView.addSubview(playerViewController.view)
                playerViewController.player!.play()
                playerViewController.didMove(toParent: self)
                
                break
            case "document":
                switch message.file_type {
                case "mov","mp4":
                    player?.pause()
                    let playerViewController = AVPlayerViewController()
                    player = AVPlayer(url: URL(string:message.Link)!)
                    playerViewController.player = player
                    playerViewController.view.frame = CGRect(x: 50, y: cell.frame.minY + 15, width: 280 , height: cell.frame.height - 30)
                    playerViewController.view.setValue(1, forKey: "tag")
                    self.addChild(playerViewController)
                    
                    messagesCollectionView.addSubview(playerViewController.view)
                    playerViewController.player!.play()
                    playerViewController.didMove(toParent: self)
                case "png","jpg","jpeg","gif":
                    //                    messageInputBar.resignFirstResponder()
                    inputAccessoryView?.isHidden = true
                    loadFullImage(url: message.Link)
                    break
                default:
                    let docLink = NSURL(string: message.Link)
                    UIApplication.shared.open(docLink! as URL, options: [:], completionHandler: nil)
                    break
                    
                }
            case "token":
                break
            case "html":
                let docLink = NSURL(string: message.Link)
                UIApplication.shared.open(docLink! as URL, options: [:], completionHandler: nil)
                break
            default:
                let docLink = NSURL(string: message.Link)
                UIApplication.shared.open(docLink! as URL, options: [:], completionHandler: nil)

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
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        //        guard let indexPath = messagesCollectionView.indexPath(for: cell),
        //            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
        //                print(message)
        //                print("Failed to identify message when audio cell receive tap gesture")
        //                return
        //        }
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let message = messageList[indexPath.section]
            
            guard audioController.state != .stopped else {
                // There is no audio sound playing - prepare to start playing for given audio message
                print(message)
                audioController.playSound(for: message, in: cell)
                return
            }
            if audioController.playingMessage?.messageId == message.messageId {
                // tap occur in the current cell that is playing audio sound
                if audioController.state == .playing {
                    audioController.pauseSound(for: message, in: cell)
                } else {
                    audioController.resumeSound()
                }
            } else {
                // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
                audioController.stopAnyOngoingPlaying()
                audioController.playSound(for: message, in: cell)
            }
        }
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
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
}

extension ChatViewController {
    func animateViewHeight(_ animateView: UIView, withAnimationType animType: String, andflagClose flag: Bool) {
        let animation = CATransition()
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype(rawValue: animType)
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animateView.layer.add(animation, forKey: kCATransition)
        if flag == false {
            animateView.isHidden = !animateView.isHidden
        }
    }
    func loadFullImage(url : String){
        let window = UIApplication.shared.keyWindow!
        viewFullImage = (Bundle.main.loadNibNamed("ViewFullImage", owner: self, options: nil)?.first as? ViewFullImage)!
        viewFullImage.bounds = window.bounds
        viewFullImage.center = window.center
        
        viewFullImage.btnClose.addTarget(self, action: #selector(self.actionCloseFullImage), for: .touchUpInside)
        
        let placeholderImage = UIImage(named: "avatar_student (1)")!
        let url = URL(string: url)!
        DispatchQueue.main.async {
            self.viewFullImage.imageView.backgroundColor = .clear
            self.viewFullImage.imageView.contentMode = .scaleAspectFit
            self.viewFullImage.imageView.sd_setShowActivityIndicatorView(true)
            self.viewFullImage.imageView.sd_setIndicatorStyle(.gray)
            self.viewFullImage.imageView.sd_setImage(with: url, placeholderImage: placeholderImage)
            
        }
        
        self.animateViewHeight(viewFullImage, withAnimationType: CATransitionSubtype.fromTop.rawValue, andflagClose: true)
        window.addSubview(viewFullImage)
        
    }
    
    @objc func actionCloseFullImage (){
        inputAccessoryView?.isHidden = false
        
        self.animateViewHeight(viewFullImage, withAnimationType: CATransitionSubtype.fromBottom.rawValue, andflagClose: false)
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}


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
    
    func getFileMedia(){
        let alert = UIAlertController(title: "Choose image or video", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Choose from Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        /*If you want work actionsheet on ipad
         then you have to use popoverPresentationController to present the actionsheet,
         otherwise app will crash on iPad */
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePickerController.sourceType = UIImagePickerController.SourceType.camera
            imagePickerController.allowsEditing = false
            
            imagePickerController.delegate = self
            
            imagePickerController.mediaTypes = ["public.image", "public.movie"]
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var datafile = Data()
        var fileType : String = ""
        var filename : String = ""
        let timestamp = "\(Date().timeIntervalSince1970 * 1000)"
        
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            
            if mediaType  == "public.image" {
                print("Image Selected")
                fileType = "image"
                filename = timestamp + ".png"
                // fix bug data rotate -90
                let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
                let imageupload = image?.fixOrientation()
                datafile = imageupload!.jpegData(compressionQuality: 1.0)!
                print("size of image in KB: %f ", Double(datafile.count) / 1000.0)
                
                print(datafile)
            }
            
            if mediaType == "public.movie" {
                print("Video Selected")
                fileType = "video"
                filename = timestamp + ".mov"
                let video = info[UIImagePickerController.InfoKey.mediaURL] as! URL
                datafile = try! Data.init(contentsOf: video )
            }
        }
        
        appdelgate?.showLoading()
        APIService.sharedInstance.uploadFile(roomId: String(format: "%@", UserDefaults.standard.value(forKey: "room")  as! CVarArg) , fileUrl: datafile, fileType: fileType, filename: filename, imageData: nil, parameters: [:], completionHandle: {(result, error) in
            if error == nil {
                let sendfile = Mapper<SendFIle>().map(JSONObject: result)
                let timestamp = "\(Date().timeIntervalSince1970 * 1000)"
                SocketIOManager.sharedInstance.sockectSendFile(type: "document", file_type: sendfile?.type ?? "", content: sendfile?.filename ?? "", link: sendfile?.link ?? "", timeStamp: timestamp)
            }else {
                let alert = UIAlertController(title: "Error", message: "Send failed. Please try again.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            self.appdelgate?.dismissLoading()
        })
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}


extension ChatViewController : UIDocumentMenuDelegate,UIDocumentPickerDelegate{
    func clickFunction(){
        
        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF),String(kUTTypeGIF),String(kUTTypeText),String("com.microsoft.word.doc")], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        
        self.present(importMenu, animated: true, completion: nil)
    }
    
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        guard let filename = urls.first?.lastPathComponent else  {
            return
        }
        
        print(filename)
        
        let data = try! Data(contentsOf: myURL.asURL())
        appdelgate?.showLoading()
        
        APIService.sharedInstance.uploadFile(roomId: String(format: "%@", UserDefaults.standard.value(forKey: "room")  as! CVarArg) , fileUrl: data, fileType: "doc" ,filename: filename, imageData: nil, parameters: [:], completionHandle: {(result, error) in
            if error == nil {
                if result?.count ?? 0 >= 3 {
                    let sendfile = Mapper<SendFIle>().map(JSONObject: result)
                    let timestamp = "\(Date().timeIntervalSince1970 * 1000)"
                    SocketIOManager.sharedInstance.sockectSendFile(type: "document", file_type: sendfile?.type ?? "", content: sendfile?.filename ?? "", link: sendfile?.link ?? "", timeStamp: timestamp)
                }else {
                    let error = result?["message"] as! String
                    let alert = UIAlertController(title: "Error", message:error, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }else {
                let alert = UIAlertController(title: "Error", message: "Send failed. Please try again.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            self.appdelgate?.dismissLoading()
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

extension UIImage {
    
    public static func loadFrom(url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    completion(UIImage(data: data))
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

extension UIImage {
    //https://stackoverflow.com/questions/51836652/swift-how-to-prevent-image-being-rotate-and-starch fix load image rotate 90
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
    
}
