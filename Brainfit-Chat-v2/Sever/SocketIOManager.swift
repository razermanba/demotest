//
//  SocketManager.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/18/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import Foundation
import AFNetworking
import SocketIO
import ObjectMapper
import Alamofire
import AlamofireObjectMapper

class SocketIOManager{
    class var sharedInstance: SocketIOManager {
        struct Static {
            static let instance = SocketIOManager()
        }
        return Static.instance
    }
    
    fileprivate init() {
    
    }
    
    
    let socket = SocketIOClient(socketURL: URL(string: API.SOCKET_URL)!, config: [.connectParams(["room":  UserDefaults.standard.value(forKey: "room")! as! CVarArg ,
                                                                                                  "token": UserDefaults.standard.value(forKey: "token")! as! CVarArg,
                                                                                                  "role":  UserDefaults.standard.value(forKey: "role")! as! CVarArg ,
                                                                                                  "id":   UserDefaults.standard.value(forKey: "id")! as! CVarArg,
                                                                                                  "name": UserDefaults.standard.value(forKey: "name")! as! CVarArg ,
                                                                                                  "username": UserDefaults.standard.value(forKey: "username")! as! CVarArg ,
                                                                                                  "avatar":   UserDefaults.standard.value(forKey: "avatar")! as! CVarArg ])])
   
    let NotificationMessage_DidGotSocketEvent = "NotificationMessage_DidGotSocketEvent"

    func socketConnect (){
        socket.connect()

        socket.onAny({(_ event: SocketAnyEvent) -> Void in
            print(event.event)
            if event.event == "room connected" {
                print("room connected")
            }else if event.event == "message"{
                print("event message")
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.NotificationMessage_DidGotSocketEvent), object: event)
        })

    }

    func socketSendMessage(text : String , message : String , link : String , timeStamp : String) {
        socket.emit("send message", with: [["type":"text","content":message,"link":link,"client_id":timeStamp]])
//        socket.emit("send message", "text",message,"",timeStamp)
    }
}
