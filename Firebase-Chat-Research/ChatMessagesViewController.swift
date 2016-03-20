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
    
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    var userName: String?
    var chat: Chat?
    var chatMessages = [ChatMessage]()
    var ref: Firebase?
    var channelRef: Firebase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        observerKeyboard()
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.tableView.addGestureRecognizer(tap)
        ref = Firebase(url:Constants.FIREBASE_BASE_URL.stringByAppendingString("/chats/\(chat?.channelName ?? "")/messages"))
        channelRef = Firebase(url:Constants.FIREBASE_BASE_URL.stringByAppendingString("/chats/\(chat?.channelName ?? "")"))
        
        
        
        
        
//        channelRef?.observeSingleEventOfType(.Value, withBlock: { snapshot in
//            print(snapshot.value["totalCount"] )
//            print(snapshot.value["unreadCount"])
//        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ref?.removeAllObservers()
        channelRef?.removeAllObservers()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerMsgAddedObserver()
        registerMsgRemovedObserver()
    }
    
    func registerMsgAddedObserver() {
        ref?.queryOrderedByChild("timestamp").queryLimitedToLast(50).observeEventType(.ChildAdded, withBlock: { [weak self]
            snapshot in
            guard let weakSelf = self else {return}
            print(snapshot.value)
            let id = snapshot.key
            let from = snapshot.value[ChatMessage.FireBasePropertyKey.from] as? String ?? ""
            let to = snapshot.value[ChatMessage.FireBasePropertyKey.to] as? String ?? ""
            let message = snapshot.value[ChatMessage.FireBasePropertyKey.message] as? String ?? ""
            let timeStamp = snapshot.value[ChatMessage.FireBasePropertyKey.timeStamp] as? NSDate ?? NSDate()
            let read = snapshot.value[ChatMessage.FireBasePropertyKey.read] as? Bool ?? true
            let chatMessage = ChatMessage(id: id, from: from, to: to, message: message, timeStamp: timeStamp, read: read)
            weakSelf.chatMessages.append(chatMessage)
            weakSelf.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: weakSelf.chatMessages.count-1, inSection: 0)], withRowAnimation: .Automatic)
            weakSelf.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: weakSelf.chatMessages.count-1, inSection: 0), atScrollPosition: .Bottom, animated: true)
            if (from != weakSelf.userName) && !read{
                guard let messageRef = weakSelf.ref else {return}
                weakSelf.updateReadMsgCount(forRefrence: messageRef.childByAppendingPath(id))
            }
            
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func registerMsgRemovedObserver() {
        ref?.observeEventType(.ChildRemoved, withBlock: { [weak self]
            snapshot in
            guard let weakSelf = self else {return}
            print(snapshot.value)
            let id = snapshot.key
            let index = weakSelf.chatMessages.indexOf {$0.id == id}
            if index != nil && index! >= 0 && index! < weakSelf.chatMessages.count {
                weakSelf.chatMessages.removeAtIndex(index!)
                weakSelf.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index!, inSection: 0)], withRowAnimation: .Automatic)
            }
            })
    }
    
    func updateReadMsgCount(forRefrence reference: Firebase) {
        reference.runTransactionBlock({ (messageData) -> FTransactionResult! in
            let read = messageData.childDataByAppendingPath("read")
            read.value = true
            return FTransactionResult.successWithValue(messageData)
            }) { (error, commited, snapshot) -> Void in
                if error == nil && commited {
                    self.channelRef?.runTransactionBlock({
                        (currentData:FMutableData!) in
                        guard let userName = self.userName else {return FTransactionResult.successWithValue(currentData)}
                        let unreadCountData = currentData.childDataByAppendingPath("\(userName)_unreadCount")
//                        let totalCountData = currentData.childDataByAppendingPath("\(self.userName ?? "")_totalCount")
//                        
//                        var totalCount = totalCountData.value as? Int
//                        if totalCount == nil {
//                            totalCount = 0
//                        }
//                        totalCountData.value = totalCount! - 1
                        
                        var unreadCount = unreadCountData.value as? Int
                        if unreadCount == nil {
                            unreadCount = 0
                        }
                        unreadCountData.value = unreadCount! - 1
                        return FTransactionResult.successWithValue(currentData)
                    })
                }
        }
    }
    
    func updateTotalAndUnreadCount() {
        self.channelRef?.runTransactionBlock({
            (currentData:FMutableData!) in
            let unreadCountData = currentData.childDataByAppendingPath("\(self.chat?.user ?? "")_unreadCount")
            let totalCountData = currentData.childDataByAppendingPath("\(self.chat?.user ?? "")_totalCount")
            
            var totalCount = totalCountData.value as? Int
            if totalCount == nil {
                totalCount = 0
            }
            totalCountData.value = totalCount! + 1
            
            var unreadCount = unreadCountData.value as? Int
            if unreadCount == nil {
                unreadCount = 0
            }
            unreadCountData.value = unreadCount! + 1
            
            
            return FTransactionResult.successWithValue(currentData)
        })
        
    }
    
    @IBAction func sendMesageButtonTapped(sender: UIButton) {
        
        if !(messageTextField.text ?? "").isEmpty {
            guard let messageRef = ref else {return}
            let to = (chat?.to ?? "") == userName ? (chat?.from ?? "") : (chat?.to ?? "")
            let newMessage: [String:AnyObject] = [ChatMessage.FireBasePropertyKey.from : userName ?? "",
                ChatMessage.FireBasePropertyKey.to : to,
                ChatMessage.FireBasePropertyKey.read : false,
                ChatMessage.FireBasePropertyKey.message : messageTextField.text!,
                ChatMessage.FireBasePropertyKey.timeStamp : Int(NSDate().timeIntervalSince1970 * 1000)]
            print(newMessage)
            messageRef.childByAutoId().setValue(newMessage, withCompletionBlock: {
                (error:NSError?, ref:Firebase!) in
                if (error != nil) {
                    print("Data could not be saved.")
                } else {
                    self.updateTotalAndUnreadCount()
                    print("Data saved successfully!")
                }
            })
            messageTextField.text = ""
            
        }
    }
    
    
    private func observerKeyboard() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObserver() {
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillChangeFrameNotification)
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillHideNotification)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        guard let info: NSDictionary = notification.userInfo else {return}
        let keyboardFrame = info.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue
        let timeInterval: NSTimeInterval = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)!.doubleValue
        let height = keyboardFrame?.height
        if height != 0 {
            bottomViewConstraint.constant = height!
        }
        UIView.animateWithDuration(timeInterval) { () -> Void in
            self.view.layoutIfNeeded()
            if self.chatMessages.count > 0 {
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.chatMessages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let info: NSDictionary = notification.userInfo else {return}
        let timeInterval: NSTimeInterval = info.objectForKey(UIKeyboardAnimationDurationUserInfoKey)!.doubleValue
        bottomViewConstraint.constant = 0
        UIView.animateWithDuration(timeInterval) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        messageTextField.endEditing(true)
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
        cell.textLabel?.text = chatMessage.from
        cell.detailTextLabel?.text = chatMessage.message
        return cell
    }
}


