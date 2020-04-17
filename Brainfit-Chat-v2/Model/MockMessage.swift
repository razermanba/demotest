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

import Foundation
import CoreLocation
import MessageKit
import AVFoundation

private struct CoordinateItem: LocationItem {
    
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
    
}

private struct ImageMediaItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage, type : String) {
        //        self.url = url
        self.image = image
        switch type{
        case "video","mov","mp4":
            self.size = CGSize(width: 240, height: 135)// sua o day
        case "html":
            self.size = CGSize(width: 194, height: 220)
        default:
            self.size = CGSize(width: 100, height: 135)// sua o day
        }
        self.placeholderImage = UIImage()
    }
    
}

internal struct MockMessage: MessageType {
    var sender: SenderType
    var messageId: String
    //    var sender: Sender
    var sentDate: Date
    var kind: MessageKind
    var Link : String
    var `Type` : String
    var file_type : String
    
    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date , link : String, type : String, file_type : String) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.Link = link
        self.Type = type
        self.file_type = file_type
    }
    
    private struct MockAudiotem: AudioItem {
        
        var url: URL
        var size: CGSize
        var duration: Float
        
        init(duration: Float , url : URL) {
            self.url = url
            self.size = CGSize(width: 160, height: 35)
            self.duration = duration
        }
        
    }
    
    init(custom: Any?, sender: Sender, messageId: String, date: Date,link : String , type : String, file_type : String) {
        self.init(kind: .custom(custom), sender: sender, messageId: messageId, date: date , link: link , type: type , file_type : file_type )
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date , link : String , type : String, file_type : String) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date ,link : link , type: type, file_type : file_type)
    }
    
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date ,link : String , type : String, file_type : String) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date ,link : link , type: type, file_type : file_type)
    }
    
    init(image: UIImage, sender: Sender, messageId: String, date: Date, link : String , type : String, file_type : String) {        
        let mediaItem = ImageMediaItem(image: image,type: file_type)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date,link : link , type: type, file_type: file_type)
    }
    
    init(thumbnail: UIImage, sender: Sender, messageId: String, date: Date, link : String , type : String, file_type : String){
        let mediaItem = ImageMediaItem(image: thumbnail,type: file_type)
        self.init(kind: .video(mediaItem), sender: sender, messageId: messageId, date: date,link : link , type: type, file_type : file_type)
    }
    
    init(location: CLLocation, sender: Sender, messageId: String, date: Date, link : String , type : String, file_type : String) {
        let locationItem = CoordinateItem(location: location)
        self.init(kind: .location(locationItem), sender: sender, messageId: messageId, date: date,link : link , type: type, file_type : file_type)
    }
    
    init(emoji: String, sender: Sender, messageId: String, date: Date, link : String , type : String, file_type : String) {
        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date,link : link , type: type, file_type : file_type)
    }
    
    init(sender: Sender, messageId: String, date: Date, link : String , type : String, file_type : String) {
        let url = URL(string: link)!
        let asset = AVURLAsset(url: url, options: nil)
        
        let audio = MockAudiotem(duration: Float(CMTimeGetSeconds(asset.duration)), url: url)
        self.init(kind: .audio(audio), sender: sender, messageId: messageId, date: date,link : link , type: type, file_type : file_type)
    }
    
}
