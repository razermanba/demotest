//
//  URLServer.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/17/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import Foundation

struct METHOD {
    static let kGET = "GET"
    static let kPOST = "POST"
    static let kPUT = "PUT"
    static let kPATCH = "PATCH"
}

struct API {
    static let base_url = "https://acp.brainfitstudio.com/" // pro
    //    "https://brainfit-sg.powerdigital.sg/" //dev
    
    
    static let SOCKET_URL =  "https://broadcast.brainfitstudio.com" // pro
    //    "https://socket-brainfit.dev.powerdigital.sg/" // dev
    
    //    "https://brainfitstudiosocket.puresolutions.com.sg"
    
    static let BASE_URL_API = "/api/v1/"
    static let base_URL_API_V4 = "/api/v4/"
    static let BASE_URL_API_Auth = "/api/v1/auth/"
    static let BASE_URL_API_User = "/api/v1/users"
    static let BASE_URL_API_Chat = "/api/v1/chat"
    static let BASE_URL_API_Room = "/api/v1/rooms"
    static let BASE_URL_API_SendFile = "/api/v1/chat/room/"
    //    static let BASE_URL_API = "/categories"
    
    //    #define RESOURCES_URL(key)      [NSString stringWithFormat:@"%@%@", BASE_URL, key]
}

enum LOG_TYPE {
    case kSESSION
    case kREWARD
    case kGAME
}

