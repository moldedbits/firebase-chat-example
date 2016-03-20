//
//  User.swift
//  Firebase-Chat-Research
//
//  Created by Amit kumar Swami on 20/03/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import SwiftyJSON

class User {
    var userId: Int?
    var userName: String?
}

extension User: JSONImport {
    struct Keys {
        static let userId = "id"
        static let userName = "name"
    }
    
    func fromJson(json:JSON) {
        userId = json[Keys.userId].int
        userName = json[Keys.userName].string
    }
    
    class func fromJson(json:JSON) -> [User] {
        var users = [User]()
        
        if json.type == Type.Array {
            for (_, value) in json {
                let user = User()
                user.fromJson(value)
                users.append(user)
            }
        }
        else {
            let user = User()
            user.fromJson(json)
            users.append(user)
        }
        return users
    }

}
