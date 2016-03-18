//
//  Chat.swift
//  Firebase-Chat-Research
//
//  Created by Amit kumar Swami on 18/03/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit

class Chat: NSObject {
    var user: String = ""
    var from: String = ""
    var channelName: String = ""
    var to: String = ""
    var timeStamp: NSDate = NSDate()

    struct FireBasePropertyKey {
        static let from = "from"
        static let channelName = "name"
        static let to = "to"
        static let timeStamp = "timestamp"
    }
    
    init(user: String, from: String, to: String, channelName: String, timeStamp: NSDate) {
        self.user = user
        self.from = from
        self.to = to
        self.channelName = channelName
        self.timeStamp = timeStamp
    }
}



