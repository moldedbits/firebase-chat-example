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
        apiManager.verifyUser(userNameTextField.text!) { (successful, result, serverError, error) -> () in
            if successful {
                guard let userName = result else {return}
                apiManager.currentUser = userName
                self.performSegueWithIdentifier(StoryBoardIdentifier.showChats, sender: sender)
            }
            else {
                let alert = UIAlertController(title: "Wrong username", message: "Please enter correct username.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == StoryBoardIdentifier.showChats && segue.destinationViewController.isKindOfClass(ChatHomeViewController) {
            let chatHomeViewController = segue.destinationViewController as! ChatHomeViewController
            //chatsViewController.userName = userNameTextField.text!
        }
    }
  

}
