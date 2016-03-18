//
//  ChatsViewController.swift
//  Firebase-Chat-Research
//
//  Created by Amit kumar Swami on 18/03/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit
import Firebase

class ChatsViewController: UITableViewController {
    
    var userName: String = ""
    var chats = [Chat]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Chats"
        
        let ref = Firebase(url:Constants.FIREBASE_BASE_URL.stringByAppendingString("/users/\(userName)/activeChats"))
        
        //        ref.observeEventType(.Value, withBlock: { [weak self]
        //            snapshot in
        //            guard let weakSelf = self else {return}
        //
        //            for child in snapshot.children {
        //                let childSnapshot = snapshot.childSnapshotForPath(child.key)
        //                let user = childSnapshot.key
        //                let from = childSnapshot.value[Chat.FireBasePropertyKey.from] as? String ?? ""
        //                let to = childSnapshot.value[Chat.FireBasePropertyKey.to] as? String ?? ""
        //                let channelName = childSnapshot.value[Chat.FireBasePropertyKey.channelName] as? String ?? ""
        //                weakSelf.chats.append(Chat(user: user, from: from, to: to, channelName: channelName))
        //                weakSelf.tableView.reloadData()
        //            }
        //            }, withCancelBlock: { error in
        //                print(error.description)
        //        })
        
        //        ref.observeEventType(.Value, withBlock: { snapshot in
        //            println("initial data loaded! \(count == snapshot.childrenCount)")
        //        })
        
        ref.queryOrderedByChild("timestamp").observeEventType(.ChildAdded, withBlock: { [weak self]
            snapshot in
            guard let weakSelf = self else {return}
            print(snapshot.value)
            let user = snapshot.key
            let from = snapshot.value[Chat.FireBasePropertyKey.from] as? String ?? ""
            let to = snapshot.value[Chat.FireBasePropertyKey.to] as? String ?? ""
            let channelName = snapshot.value[Chat.FireBasePropertyKey.channelName] as? String ?? ""
            let timeStamp = snapshot.value[Chat.FireBasePropertyKey.timeStamp] as? NSDate ?? NSDate()
            let chat = Chat(user: user, from: from, to: to, channelName: channelName, timeStamp: timeStamp)
            weakSelf.insertChat(chat)
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        ref.observeEventType(.ChildRemoved, withBlock: { [weak self]
            snapshot in
            guard let weakSelf = self else {return}
            print(snapshot.value)
            let user = snapshot.key
            weakSelf.removeChat(forUser: user)
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }
    
    func insertChat(chat: Chat) {
        var count = 0
        for previousChat in chats {
            if previousChat.timeStamp.compare(chat.timeStamp) == .OrderedAscending {
                break
            }
            count++
        }
        let index = count++
        chats.insert(chat, atIndex: index)
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func removeChat(forUser user: String) {
        guard let index = chats.indexOf({$0.user == user}) else {return}
        chats.removeAtIndex(index)
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryBoardIdentifier.showMessages && segue.destinationViewController.isKindOfClass(ChatMessagesViewController) {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let chat = chats[indexPath.row]
                let chatMessageVieeController = segue.destinationViewController as! ChatMessagesViewController
                chatMessageVieeController.chat = chat
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let chat = chats[indexPath.row]
        cell.textLabel!.text = chat.user
        cell.detailTextLabel?.text = chat.channelName
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier(StoryBoardIdentifier.showMessages, sender: indexPath)
    }
    
    
}

