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
    let formatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = chat?.from != apiManager.currentUser ? chat?.from : chat?.to
        setUpTableView()
        observerKeyboard()
        formatter.dateFormat = "hh:mm a dd-MM-YYYY"
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.tableView.addGestureRecognizer(tap)
        ref = Firebase(url:Constants.FIREBASE_BASE_URL.stringByAppendingString("/chats/\(chat?.channelName ?? "")/messages/"))
        channelRef = Firebase(url:Constants.FIREBASE_BASE_URL.stringByAppendingString("/chats/\(chat?.channelName ?? "")"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("Observer removed")
        ref?.removeAllObservers()
        channelRef?.removeAllObservers()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("Observer added")
        registerMsgAddedObserver()
//        registerMsgRemovedObserver()
        registerMsgChangedObserver()
    }
    
    func registerMsgAddedObserver() {
        ref?.observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot) -> Void in
            print("Single event\(snapshot.value)")
        })
        ref?.observeEventType(.ChildAdded, withBlock: { [weak self]
            snapshot in
            guard let weakSelf = self else {return}
            print("child added \(snapshot.value)")
            let id = snapshot.key
            let from = snapshot.value.objectForKey(ChatMessage.FireBasePropertyKey.from) as? String ?? ""
            let to = snapshot.value[ChatMessage.FireBasePropertyKey.to] as? String ?? ""
            let message = snapshot.value[ChatMessage.FireBasePropertyKey.message] as? String ?? ""
            let timeStamp = snapshot.value[ChatMessage.FireBasePropertyKey.timeStamp] as? Double ?? 0.0
            let read = snapshot.value[ChatMessage.FireBasePropertyKey.read] as? Bool ?? false
            if timeStamp != 0.0 {
                let chatMessage = ChatMessage(id: id, from: from, to: to, message: message, timeStamp: NSDate(timeIntervalSince1970: timeStamp * 0.001), read: read)
                weakSelf.chatMessages.append(chatMessage)
                weakSelf.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: weakSelf.chatMessages.count-1, inSection: 0)], withRowAnimation: .Top)
                let delay = 0.1 * Double(NSEC_PER_SEC)
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(time, dispatch_get_main_queue(), {
//                    weakSelf.tableView.selectRowAtIndexPath(NSIndexPath(forRow: weakSelf.chatMessages.count-1, inSection: 0), animated: true, scrollPosition: .Bottom)
                    weakSelf.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: weakSelf.chatMessages.count-1, inSection: 0), atScrollPosition: .None, animated: false)
                    })
                if (from != weakSelf.userName) && !read{
                   weakSelf.updateReadMsgCount(forMessageId: id)
                }
            }
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    func registerMsgRemovedObserver() {
        ref?.observeEventType(.ChildRemoved, withBlock: { [weak self]
            snapshot in
            guard let weakSelf = self else {return}
            print("Child Removed \(snapshot.value)")
            let id = snapshot.key
            let index = weakSelf.chatMessages.indexOf {$0.id == id}
            if index != nil && index! >= 0 && index! < weakSelf.chatMessages.count {
                weakSelf.chatMessages.removeAtIndex(index!)
                weakSelf.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index!, inSection: 0)], withRowAnimation: .Automatic)
            }
            })
    }
    
    func registerMsgChangedObserver() {
        ref?.observeEventType(.ChildChanged, withBlock: {
            [weak self]
            snapshot in
            guard let weakSelf = self else {return}
            print("child changed \(snapshot.value)")
            if let index = weakSelf.chatMessages.indexOf({$0.id == snapshot.key}) {
                let chatMessage = weakSelf.chatMessages[index]
                chatMessage.read = snapshot.value[ChatMessage.FireBasePropertyKey.read] as? Bool ?? false
                if chatMessage.from == apiManager.currentUser {
                    let cell = weakSelf.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! OutgoingMessageTableViewCell
                    cell.seenImageView.hidden = !chatMessage.read
//                    weakSelf.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
                }
            }
            })
    }
    
    
    func updateReadMsgCount(forMessageId messageId: String) {
        guard let messageRef = ref else {return}
        messageRef.childByAppendingPath(messageId).childByAppendingPath("read").runTransactionBlock({ (readData) -> FTransactionResult! in
            readData.value = true
            return FTransactionResult.successWithValue(readData)
            }) { (error, commited, snapshot) -> Void in
                if error == nil && commited {
                    
                    self.channelRef?.childByAppendingPath("\(apiManager.currentUser)_unreadCount").runTransactionBlock({
                        (unreadCountData:FMutableData!) in
                        var unreadCount = unreadCountData.value as? Int
                        if unreadCount == nil {
                            unreadCount = 0
                        }
                        unreadCountData.value = unreadCount! - 1
                        return FTransactionResult.successWithValue(unreadCountData)
                    })
                }
        }
    }
    
    func updateOpponentUnreadCount() {
        self.channelRef?.childByAppendingPath("\(self.chat?.user ?? "")_unreadCount").runTransactionBlock({
            (unreadCountData:FMutableData!) in
            var unreadCount = unreadCountData.value as? Int
            if unreadCount == nil {
                unreadCount = 0
            }
            unreadCountData.value = unreadCount! + 1
            return FTransactionResult.successWithValue(unreadCountData)
            }) { (error, commited, snapshot) -> Void in
                if error == nil && commited {
                    self.updateOpponentTotalCount()
                }
        }
        
    }
    
    func updateOpponentTotalCount() {
        self.channelRef?.childByAppendingPath("\(self.chat?.user ?? "")_totalCount").runTransactionBlock({
            (totalCountData:FMutableData!) in
            var totalCount = totalCountData.value as? Int
            if totalCount == nil {
                totalCount = 0
            }
            totalCountData.value = totalCount! + 1
            return FTransactionResult.successWithValue(totalCountData)
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
            messageRef.childByAutoId().setValue(newMessage, withCompletionBlock: {
                (error:NSError?, ref:Firebase!) in
                if (error != nil) {
                    print("Data could not be saved.")
                } else {
                    self.updateOpponentUnreadCount()
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
        
        let chatMessage = chatMessages[indexPath.row]
        if chatMessage.from == apiManager.currentUser {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(OutgoingMessageTableViewCell), forIndexPath: indexPath) as! OutgoingMessageTableViewCell
            cell.messageLabel.text = chatMessage.message
            cell.seenImageView.hidden = !chatMessage.read
            cell.timeLabel.text = formatter.stringFromDate(chatMessage.timeStamp ?? NSDate())
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(String(IncomingMessageTableViewCell), forIndexPath: indexPath) as! IncomingMessageTableViewCell
            cell.messageLabel.text = chatMessage.message
            cell.timeLabel.text = formatter.stringFromDate(chatMessage.timeStamp ?? NSDate())
            return cell
        }
    }
}


