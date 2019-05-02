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

class ChatViewController: MessagesViewController  {
    var arrayListChat = Mapper<listChat>().mapArray(JSONArray: [])
    var messageList: [MockMessage] = []
    let pageNumber : Int = 0
    let refreshControl = UIRefreshControl()
    let userSender = Sender(id:String(format: "%@", UserDefaults.standard.value(forKey: "id")! as! CVarArg), displayName: String(format: "%@", UserDefaults.standard.value(forKey: "name")! as! CVarArg))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(userSender)
        
        configureMessageCollectionView()
        
        configureMessageInputBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didGotSocketEvent), name: NSNotification.Name(rawValue: "NotificationMessage_DidGotSocketEvent"), object: nil)
        
        SocketIOManager.sharedInstance.socketConnect()
        
        loadHistoryChat()
        
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
            self.arrayListChat = Mapper<listChat>().mapArray(JSONArray: result as! [[String : Any]])
           
            for chat in self.arrayListChat {
                let message = MockMessage(text: chat.content! , sender: Sender(id: String(chat.user_id) , displayName: chat.name!), messageId: "0000456", date: Date())
                self.messageList.append(message)
            }
            
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
        })
    }
    
    @objc func loadMoreMessages()  {
        APIService.sharedInstance.getHistoryChat([:], roomId: String(format: "%@", UserDefaults.standard.value(forKey: "room")  as! CVarArg) , pagenumber: String(pageNumber + 1), completionHandle: {(result, error) in
            self.arrayListChat = Mapper<listChat>().mapArray(JSONArray: result as! [[String : Any]])
            
            for chat in self.arrayListChat {
                let message = MockMessage(text: chat.content! , sender: Sender(id: String(chat.user_id) , displayName: chat.name!), messageId: "0000456", date: Date())
                self.messageList.append(message)
            }
            
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
            self.refreshControl.endRefreshing()
        })
    }
    
    
    @objc func didGotSocketEvent(_ notifObject : NSNotification) {
        let event : SocketAnyEvent = notifObject.object as! SocketAnyEvent
    
        print(event)
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
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    //    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    //
    ////        let dateString = Formatter.string(for:message.sentDate)
    ////        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    //    }
}

// MARK: - MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
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
        
//                for component in inputBar.inputTextView.components {
//
//        //            if let str = component as? String {
//        //                let message = MockMessage(text: str, sender: currentSender(), messageId: UUID().uuidString, date: Date())
//        //                insertMessage(message)
//        //            } else if let img = component as? UIImage {
//        //                let message = MockMessage(image: img, sender: currentSender(), messageId: UUID().uuidString, date: Date())
//        //                insertMessage(message)
//        //            }
//        
//                }
        
        let timestamp = "\(Date().timeIntervalSince1970 * 1000)"
        
        SocketIOManager.sharedInstance.socketSendMessage(text: "text", message: text, link: "", timeStamp: String(format:"%@", timestamp))
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
}
