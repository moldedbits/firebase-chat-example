//
//  APIManager.swift
//  Firebase-Chat-Research
//
//  Created by Amit kumar Swami on 20/03/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

let apiManager = APIManager.sharedInstance
class APIManager: NSObject {
    
    static let sharedInstance = APIManager()
    var currentUser = ""
    
    struct URLPaths {
        static let userList = "/users/list_users"
        static let verifyUser = "/users/sign_in"
        static let startChat = "/users/start_chat"
    }
    
    func getAbsolutePath(forPath path: String) -> String {
        return Constants.BASE_URL.stringByAppendingString(path)
    }
    
    func makeRequest(path:String, action:Alamofire.Method = .GET, params:[String:AnyObject]? = nil, headers:[String:String] = [:],
        parameterEncoding:ParameterEncoding = .URL, completionHandler:(successful:Bool, response:JSON, serverError: String?, error:NSError?)->()) {
            
            let req = Alamofire.request(action, getAbsolutePath(forPath: path), encoding:parameterEncoding, parameters:params, headers:headers)
                .responseJSON { response in
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        switch response.result {
                        case .Success(let json):
                            let parsedJson = JSON(json)
                            if parsedJson["success"] && parsedJson["errors"] == nil {
                                completionHandler(successful:true, response:parsedJson, serverError:nil, error:nil)
                            }
                            else {
                                let error = parsedJson["errors"].string
                                completionHandler(successful:false, response:nil, serverError:error, error:nil)
                            }
                            break;
                        case .Failure(let error):
                            print("Error calling service: \(error)\n")
                            completionHandler(successful:false, response:nil, serverError:nil, error:error)
                            break;
                        }
                        
                    })
            }
            debugPrint(req)
    }
    
    func getUserLists(completionHandler:(successful:Bool, result:[User]?, serverError:AnyObject?, error:NSError?)->()) {
        makeRequest(URLPaths.userList, completionHandler: { (successful, response, serverError, error) -> () in
            if successful {
                let data = User.fromJson(response["user_array"])
                completionHandler(successful:true, result:data, serverError:serverError, error:error)
            } else {
                completionHandler(successful:false, result:nil, serverError:serverError, error:error)
            }
        })

    }
    
    func verifyUser(userName: String, completionHandler:(successful:Bool, result:String?, serverError:AnyObject?, error:NSError?)->()) {
        let params = ["name": userName]
        makeRequest(URLPaths.verifyUser, params: params, completionHandler: { (successful, response, serverError, error) -> () in
            if successful {
                let userName = response["user_name"].string
                completionHandler(successful:true, result:userName, serverError:serverError, error:error)
            } else {
                completionHandler(successful:false, result:nil, serverError:serverError, error:error)
            }
        })
    }
    
    func startChat(withUserName userName: String, completionHandler:(successful:Bool, result:String?, serverError:AnyObject?, error:NSError?)->()) {
        let params = ["to": userName, "from": currentUser]
        makeRequest(URLPaths.startChat, action: .POST, params: params, completionHandler: { (successful, response, serverError, error) -> () in
            if successful {
                completionHandler(successful:true, result:userName, serverError:serverError, error:error)
            } else {
                completionHandler(successful:false, result:nil, serverError:serverError, error:error)
            }
        })
    }


}
