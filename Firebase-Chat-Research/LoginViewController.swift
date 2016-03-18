//
//  LoginViewController.swift
//  Firebase-Chat-Research
//
//  Created by Amit kumar Swami on 18/03/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTapped(sender: UIButton) {
        if userNameTextField.text?.isEmpty ?? true {
            return
        }
        performSegueWithIdentifier(StoryBoardIdentifier.showChats, sender: sender)
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryBoardIdentifier.showChats && segue.destinationViewController.isKindOfClass(ChatsViewController) {
            let chatsViewController = segue.destinationViewController as! ChatsViewController
            chatsViewController.userName = userNameTextField.text!
        }
    }
  

}
