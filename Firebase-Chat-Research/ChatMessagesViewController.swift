//
//  ChatMessagesViewController.swift
//  Firebase-Chat-Research
//
//  Created by Amit kumar Swami on 18/03/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit
import Firebase

class ChatMessagesViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var chat: Chat?
    var chatMessages = [ChatMessage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = Firebase(url:Constants.FIREBASE_BASE_URL.stringByAppendingString("/chats/\(chat?.channelName ?? "")/messages"))
        ref.queryOrderedByChild("timestamp").queryLimitedToFirst(50).observeEventType(.ChildAdded, withBlock: { [weak self]
            snapshot in
            guard let weakSelf = self else {return}
            print(snapshot.value)
            let id = snapshot.key
            let from = snapshot.value[ChatMessage.FireBasePropertyKey.from] as? String ?? ""
            let to = snapshot.value[ChatMessage.FireBasePropertyKey.from] as? String ?? ""
            let message = snapshot.value[ChatMessage.FireBasePropertyKey.from] as? String ?? ""
            let timeStamp = snapshot.value[ChatMessage.FireBasePropertyKey.from] as? NSDate ?? NSDate()
            let read = snapshot.value[ChatMessage.FireBasePropertyKey.from] as? Bool ?? false
            let chatMessage = ChatMessage(id: id, from: from, to: to, message: message, timeStamp: timeStamp, read: read)
            weakSelf.chatMessages.append(chatMessage)
            
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

