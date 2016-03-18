//
//  ChatMessage.swift
//  Firebase-Chat-Research
//
//  Created by Amit kumar Swami on 18/03/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit

class ChatMessage: NSObject {
    
    var id: String = ""
    var message: String?
    var read: Bool = false
    var timeStamp: NSDate?
    var from: String?
    var to: String?
    
    struct FireBasePropertyKey {
        static let message = "message"
        static let read = "read"
        static let timeStamp = "timestamp"
        static let from = "from"
        static let to = "to"
    }
    
    init(id: String, from: String, to: String, message: String, timeStamp: NSDate, read: Bool) {
        self.id = id
        self.from = from
        self.to = to
        self.message = message
        self.timeStamp = timeStamp
        self.read = read
    }

}