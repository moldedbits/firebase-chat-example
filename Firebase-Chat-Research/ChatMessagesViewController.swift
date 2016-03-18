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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        observerKeyboard()
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        self.tableView.addGestureRecognizer(tap)
        ref = Firebase(url:Constants.FIREBASE_BASE_URL.stringByAppendingString("/chats/\(chat?.channelName ?? "")/messages"))
        
        ref?.queryOrderedByChild("timestamp").queryLimitedToFirst(50).observeEventType(.ChildAdded, withBlock: { [weak self]
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
            weakSelf.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: weakSelf.chatMessages.count-1, inSection: 0), atScrollPosition: .Bottom, animated: true)
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendMesageButtonTapped(sender: UIButton) {
        
        if !(messageTextField.text ?? "").isEmpty {
            let to = (chat?.to ?? "") == userName ? (chat?.from ?? "") : (chat?.to ?? "")
            let newMessage = [ChatMessage.FireBasePropertyKey.from : userName ?? "",
                ChatMessage.FireBasePropertyKey.to : to,
                ChatMessage.FireBasePropertyKey.read : String(false),
                ChatMessage.FireBasePropertyKey.message : messageTextField.text!,
                ChatMessage.FireBasePropertyKey.timeStamp : "\(Int(NSDate().timeIntervalSince1970 * 1000))"]
            print(newMessage)
            ref?.childByAutoId().setValue(newMessage)
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
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.chatMessages.count - 1, inSection: 0), atScrollPosition: .Bottom, animated: true)
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


