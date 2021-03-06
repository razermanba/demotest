/*
 MIT License
 
 Copyright (c) 2017-2018 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import MapKit
import MessageKit
import MessageInputBar
import SDWebImage
import SwiftLinkPreview
import JGProgressHUD
import Nuke

final class BasicExampleViewController: ChatViewController {
    private let slp = SwiftLinkPreview(cache: InMemoryCache())
    
    let hud = JGProgressHUD(style: .dark)
    
    override func configureMessageCollectionView() {
        super.configureMessageCollectionView()
        
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        UserDefaults.standard.set(true, forKey: "Photo Messages")
        UserDefaults.standard.set(true, forKey: "Video Messages")
    }
    
}

// MARK: - MessagesDisplayDelegate

extension BasicExampleViewController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let message = messageList[indexPath.section]
        
        if isFromCurrentSender(message: message) == true {
            switch message.file_type {
            case "png","jpg","video","mov","mp4":
                return .clear
            case "html":
                return UIColor(red:1.00, green:0.60, blue:0.00, alpha:1.00)
            default:
                return UIColor(red:0.00, green:0.64, blue:1.00, alpha:1.0)
            }
        }else {
            switch message.file_type {
            case "png","jpg","video","mov","mp4","html":
                return .clear
            default:
                return UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
            }
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let message = messageList[indexPath.section]
        switch message.file_type {
        case "html":
            return .bubbleOutline(.orange)
        default:
            let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
            return .bubbleTail(tail, .curved)
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let timestamp = "\(Date().timeIntervalSince1970 * 1000)"
        //        var message = messageList[indexPath.row]
        
        if userSender.id == self.messageList[indexPath.section].sender.senderId{
            let url = URL(string: String(format: "%@?v=%@",UserDefaults.standard.value(forKey: "avatar")! as! String, timestamp))!
            let placeholderImage = UIImage(named: "avatar_student (1)")!
            DispatchQueue.main.async {
                avatarView.sd_setImage(with: url, placeholderImage: placeholderImage)
            }
        }else {
            let placeholderImage = UIImage(named: "avatar_student (1)")!
            let url = URL(string: String(format: "%@/api/v1/users/%@/avatar?v=%@",API.base_url,self.messageList[indexPath.section].sender.senderId, timestamp))!
            DispatchQueue.main.async {
                avatarView.sd_setImage(with: url, placeholderImage: placeholderImage)
            }
        }
    }
    
    
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let message = messageList[indexPath.section]
        
        switch message.file_type {
        case "png","jpg":
            for subView in imageView.subviews {
                subView.removeFromSuperview()
            }
            let placeholderImage = UIImage(named: "placeholder")!
            let url = URL(string: message.Link)!
            DispatchQueue.main.async {
                imageView.backgroundColor = .clear
                imageView.contentMode = .scaleAspectFill
                imageView.sd_setShowActivityIndicatorView(true)
                imageView.sd_setIndicatorStyle(.gray)
                
                imageView.sd_setImage(with: url, placeholderImage: placeholderImage)
            }
            
            //            SDImageCache.shared().clearMemory()
            //            SDImageCache.shared().clearDisk()
            break
        case "html":
            
            let previewLink = (Bundle.main.loadNibNamed("PreviewLink", owner: self, options: nil)?.first as? PreviewLink)!
            previewLink.bounds = imageView.bounds
            previewLink.center = imageView.center
            
            imageView.addSubview(previewLink)
            previewLink.showLoading()
            
            self.slp.preview( message.Link,onSuccess: { result in
                print(result)
                previewLink.loadImage(url: result.image ?? "")
                previewLink.urlTitle.text = result.title
                let attributedString = NSMutableAttributedString(string: result.canonicalUrl ?? "", attributes:[NSAttributedString.Key.link: result.finalUrl ?? ""])
                previewLink.urlLink.attributedText = attributedString
                previewLink.descriptionUrl.text = result.description
                
                previewLink.viewWithTag(5) // set view load HTML is 5
                
                previewLink.dismissLoading()
            },onError: { error in
                print(error)
                previewLink.dismissLoading()
            })
            SDImageCache.shared().clearMemory()
            SDImageCache.shared().clearDisk()
            
            imageView.image = nil
            imageView.setNeedsDisplay()
            
            break
        default:
            for subView in imageView.subviews {
//                if subView.tag == 5 {
                    subView.removeFromSuperview()
//                }
            }
            break
        }
    }
    
    
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }
    
    func showLoading(imageview : UIImageView ){
        hud.textLabel.text = ""
        hud.show(in: imageview)
    }
    
    func dismissLoading(){
        hud.dismiss(afterDelay: 0.0)
    }
    
    
}

// MARK: - MessagesLayoutDelegate

extension BasicExampleViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}
