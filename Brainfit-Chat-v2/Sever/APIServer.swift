//
//  APIServer.swift
//  Brainfit-Chat-v2
//
//  Created by macbook on 4/17/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import Foundation
import Alamofire
import AFNetworking
import SwiftyJSON


class APIService {
    class var sharedInstance: APIService {
        struct Static {
            static let instance = APIService()
        }
        return Static.instance
    }
    
    fileprivate init() {
        
    }
    
    func getURL(_ method: String, url: String, params: [String : Any],headers:[String : String]?, completionHandle:@escaping (_ result: AnyObject ,_ error:AnyObject?) -> Void) {
        var my_headers : [String : String] = [:]
        if let _ = headers {
            my_headers = headers!
            
        } else {
            my_headers["Content-type"] = "application/json"
        }
        
        if (UserDefaults.standard.value(forKey: "token") != nil && String(describing: UserDefaults.standard.value(forKey: "token")).count > 0) {
            print(String(format: "Token token=\"%@\"", UserDefaults.standard.value(forKey: "token")! as! CVarArg))
            
            let authorizationValue = String(format: "Token token=\"%@\"", UserDefaults.standard.value(forKey: "token")! as! CVarArg)
            
            my_headers["Authorization"] = authorizationValue
        }
        
        if (method == METHOD.kGET) {
            Alamofire.request(url, method:.get, parameters:params, headers:my_headers)
                .validate(statusCode: 200..<300)
                .responseJSON(completionHandler: { (Response) in
                    switch Response.result {
                    case .success:
                        completionHandle(Response.result.value as AnyObject,nil)
                    case .failure:
                        if let data = Response.data, let responseString = String(data: data, encoding: String.Encoding.utf8) {
                            print(responseString)
                            var errorMessage:String?
                            errorMessage = responseString
                            completionHandle([[String:Any]]() as AnyObject,errorMessage as AnyObject)
                        }
                    }
                })
            
            
            
        } else if (method == METHOD.kPUT) {
            print (params)
            Alamofire.request(url, method: .put, parameters: params, headers: my_headers)
                .validate(statusCode: 200..<300)
                .responseJSON(completionHandler: { (Response) in
                    switch Response.result {
                    case .success:
                        completionHandle(Response.result.value as AnyObject ,nil)
                    case .failure:
                        if let data = Response.data, let responseString = String(data: data, encoding: String.Encoding.utf8) {
                            print(responseString)
                            var errorMessage:String?
                            errorMessage = responseString
                            completionHandle([[String:Any]]() as AnyObject,errorMessage as AnyObject)
                        }
                    }
                })
        } else if (method == METHOD.kPATCH) {
            Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default , headers: my_headers)
                .validate(statusCode: 200..<300)
                .responseJSON(completionHandler: { (Response) in
                    switch Response.result {
                    case .success:
                        completionHandle(Response.result.value as AnyObject ,nil)
                    case .failure:
                        if let data = Response.data, let responseString = String(data: data, encoding: String.Encoding.utf8) {
                            print(responseString)
                            var errorMessage:String?
                            errorMessage = responseString
                            completionHandle([[String:Any]]() as AnyObject,errorMessage as AnyObject)
                        }
                    }
                })
        } else {
            Alamofire.request(url, method: .post, parameters: params ,  encoding: JSONEncoding.default , headers: my_headers)
                .validate(statusCode: 200..<300)
                .responseJSON(completionHandler: { (Response) in
                    switch Response.result {
                    case .success:
                        completionHandle(Response.result.value as AnyObject,nil)
                    case .failure:
                        if let data = Response.data, let responseString = String(data: data, encoding: String.Encoding.utf8) {
                            var errorMessage:String?
                            errorMessage = responseString
                            completionHandle([[String:Any]]() as AnyObject,errorMessage as AnyObject)
                        }
                    }
                })
            
        }
    }
    
    
    func login(_ params : [String : AnyObject], completionHandle:@escaping (_ result:AnyObject,_ error:AnyObject?) -> Void) {
        getURL(METHOD.kPOST, url: API.base_url + API.BASE_URL_API_Auth + "/login", params: params, headers: [:], completionHandle: completionHandle)
    }
    
    func getProfile(_ params : [String : AnyObject], completionHandle:@escaping (_ result:AnyObject,_ error:AnyObject?) -> Void) {
        getURL(METHOD.kGET, url: API.base_url + API.BASE_URL_API_Chat + "/profile" , params: params, headers: [:], completionHandle: completionHandle)
    }
    
    func logOutUser(_ params : [String : AnyObject], completionHandle:@escaping (_ result:AnyObject,_ error:AnyObject?) -> Void) {
        getURL(METHOD.kPOST, url: API.base_url + API.BASE_URL_API_User + "/logout", params: params, headers: [:], completionHandle: completionHandle)
    }
    
    func getListRoom(_ params : [String : AnyObject], pagenumber: String, completionHandle:@escaping (_ result:AnyObject,_ error:AnyObject?) -> Void) {
        getURL(METHOD.kGET, url: API.base_url + API.BASE_URL_API_Chat + "/rooms?page=" +  pagenumber , params: params, headers: [:], completionHandle: completionHandle)
    }
    
    func getHistoryChat(_ params : [String : AnyObject], roomId : String ,pagenumber: String, completionHandle:@escaping (_ result:AnyObject,_ error:AnyObject?) -> Void) {
        print (API.base_url + API.BASE_URL_API_Chat + "/room/" + roomId + "/messages?page=" + pagenumber)
        getURL(METHOD.kGET, url: API.base_url + API.BASE_URL_API_Chat + "/room/" + roomId + "/messages?page=" + pagenumber , params: params, headers: [:], completionHandle: completionHandle)
    }
    
    func changePassword(_ params : [String : AnyObject], completionHandle:@escaping (_ result:AnyObject,_ error:AnyObject?) -> Void) {
        print(API.base_url + API.BASE_URL_API_User + "/update-password")
        getURL(METHOD.kPUT, url: API.base_url + API.BASE_URL_API_User + "/update-password", params: params, headers: [:], completionHandle: completionHandle)
    }
    
    func getListMember(_ params : [String : AnyObject], roomId : String , completionHandle:@escaping (_ result:AnyObject,_ error:AnyObject?) -> Void) {
        getURL(METHOD.kGET, url: API.base_url + API.BASE_URL_API_Room + "/" + roomId , params: params, headers: [:], completionHandle: completionHandle)
    }
    
    func submitDeviceToken(_ params : [String : AnyObject], completionHandle:@escaping (_ result:AnyObject,_ error:AnyObject?) -> Void) {
        getURL(METHOD.kPOST, url: API.base_url + API.BASE_URL_API_User + "/device_token", params: params, headers: [:], completionHandle: completionHandle)
    }
    
    func getStandardScore(_ params : [String : AnyObject], user_id : String , completionHandle:@escaping (_ result:AnyObject,_ error:AnyObject?) -> Void) {
        getURL(METHOD.kGET, url: API.base_url + API.BASE_URL_API + "/students/" + user_id + "/cogmap-report", params: params, headers: [:], completionHandle: completionHandle)
    }
    
    func getProgressScore(_ params : [String : AnyObject], user_id : String , completionHandle:@escaping (_ result:AnyObject,_ error:AnyObject?) -> Void) {
        getURL(METHOD.kGET, url: API.base_url + API.BASE_URL_API + "/students/" + user_id + "/progress-report", params: params, headers: [:], completionHandle: completionHandle)
    }
    
    func getListCourses(_ params : [String : AnyObject], completionHandle:@escaping (_ result:AnyObject,_ error:AnyObject?) -> Void) {
        print(API.base_url + API.BASE_URL_API + "/courses")
        getURL(METHOD.kGET, url: API.base_url + API.BASE_URL_API + "/courses" , params: params, headers: [:], completionHandle: completionHandle)
    }
    
    func coursesDetail(_ params : [String : AnyObject], courses_id : String , completionHandle:@escaping (_ result:AnyObject,_ error:AnyObject?) -> Void) {
        getURL(METHOD.kGET, url: API.base_url + API.BASE_URL_API + "/courses/" + courses_id , params: params, headers: [:], completionHandle: completionHandle)
    }
    func uploadImage(_ keyUpload : String ,_ photo: UIImage, completionHandle:@escaping (_ result:[String:AnyObject]?,_ error:AnyObject?) -> Void) {
        
        guard let imageData = photo.jpegData(compressionQuality: 1) else { return }
        
        let manager = AFHTTPSessionManager()
        
        //        print(String(format: "Token token=\"%@\"", UserDefaults.standard.value(forKey: "token")! as! CVarArg))
        //
        //        print(API.base_url + API.BASE_URL_API_User + "/avatar" )
        
        
        manager.requestSerializer.setValue(String(format: "Token token=\"%@\"", UserDefaults.standard.value(forKey: "token")! as! CVarArg), forHTTPHeaderField: "Authorization")
        
        
        let request: NSMutableURLRequest = manager.requestSerializer.multipartFormRequest(withMethod: "PUT", urlString: API.base_url + API.BASE_URL_API_User + "/avatar" , parameters: nil, constructingBodyWith: {(formData: AFMultipartFormData!) -> Void in
            
            formData.appendPart(withFileData: imageData, name: "avatar" , fileName: "avatar.jpg", mimeType: "image/jpeg")
            
        }, error: nil)
        
        manager.dataTask(with: request as URLRequest) { (response, responseObject, error) -> Void in
            if((error == nil)) {
                print(responseObject!)
                completionHandle(responseObject as? [String : AnyObject],nil)
            }
            else {
                
                completionHandle(nil,error as AnyObject )
            }
            
        }.resume()
    }
    
    func uploadFile(roomId : String , fileUrl : Data , fileType : String , filename : String ,imageData: Data?, parameters: [String : Any] , completionHandle:@escaping (_ result:[String:AnyObject]?,_ error:AnyObject?) -> Void) {
        let url = API.base_url + API.BASE_URL_API_SendFile + roomId + "/send-file"
        
        let headers: HTTPHeaders = [
            "Authorization": String(format:"Token token=\"%@\"", UserDefaults.standard.value(forKey: "token")! as! CVarArg), //in case you need authorization header
            "Content-Type": "multipart/form-data"
        ]
        
        //        guard let imageData = fileUrl.jpegData(compressionQuality: 1) else { return }
//        var filename : String = ""
        var mimetype : String = ""
        let timestamp = "\(Date().timeIntervalSince1970 * 1000)"
        
        switch fileType {
        case "video":
//            filename = timestamp + ".mov"
            mimetype = "video/mp4"
            break
        case "image":
//            filename = timestamp + ".png"
            mimetype = "image/jpeg"
            break
        case "doc":
//            filename = timestamp + ".pdf"
            mimetype = "application/pdf"
            break
        default:
            break
        }
                    
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileUrl, withName: "file", fileName:filename, mimeType:mimetype)
        }, to: url, method: .post, headers: headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
                    if let err = response.error{
                        completionHandle(nil,err as AnyObject)
                        print(err)
                        return
                    }
                 
                    completionHandle(response.result.value as? [String : AnyObject],nil)
                    
                }
                
            case .failure(let encodingError):
                print(encodingError)
                completionHandle(nil,encodingError as AnyObject)
            }
        }
    }
}



