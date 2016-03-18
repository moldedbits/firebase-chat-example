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

    @IBOutlet weak var tableView: UITableView!
    var chat: Chat?
    var chatMessages = [ChatMessage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        let ref = Firebase(url:Constants.FIREBASE_BASE_URL.stringByAppendingString("/chats/\(chat?.channelName ?? "")/messages"))
        ref.queryOrderedByChild("timestamp").queryLimitedToFirst(50).observeEventType(.ChildAdded, withBlock: { [weak self]
            snapshot in
            guard let weakSelf = self else {return}
            print(snapshot.value)
            let id = snapshot.key
            let from = snapshot.value[ChatMessage.FireBasePropertyKey.from] as? String ?? ""
            let to = snapshot.value[ChatMessage.FireBasePropertyKey.to] as? String ?? ""
            let message = snapshot.value[ChatMessage.FireBasePropertyKey.message] as? String ?? ""
            let timeStamp = snapshot.value[ChatMessage.FireBasePropertyKey.timeStamp] as? NSDate ?? NSDate()
            let read = snapshot.value[ChatMessage.FireBasePropertyKey.read] as? Bool ?? false
            let chatMessage = ChatMessage(id: id, from: from, to: to, message: message, timeStamp: timeStamp, read: read)
            weakSelf.chatMessages.append(chatMessage)
            weakSelf.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: weakSelf.chatMessages.count-1, inSection: 0)], withRowAnimation: .Automatic)
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ChatMessagesViewController: UITableViewDataSource, UITableViewDelegate {
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.clearColor()
        self.edgesForExtendedLayout = UIRectEdge.None
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath)
        let chatMessage = chatMessages[indexPath.row]
        cell.textLabel?.text = chatMessage.to
        cell.detailTextLabel?.text = chatMessage.message
        return cell
        
    }
}


