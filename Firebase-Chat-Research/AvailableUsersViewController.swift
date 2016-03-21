//
//  AvailableUsersViewController.swift
//  Firebase-Chat-Research
//
//  Created by Amit kumar Swami on 20/03/16.
//  Copyright © 2016 moldedbits. All rights reserved.
//

import UIKit

class AvailableUsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var availableUser = [User]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: "Users", image: UIImage(named: "user"), tag: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Users"
        
        setUpTableView()
        apiManager.getUserLists { (successful, result, serverError, error) -> () in
            if successful {
                guard let users = result else {return}
                self.availableUser = users
                if let indexSelf = users.indexOf({$0.userName == apiManager.currentUser}) {
                    self.availableUser.removeAtIndex(indexSelf)
                }
                self.tableView.reloadData()
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension AvailableUsersViewController: UITableViewDataSource, UITableViewDelegate {
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.clearColor()
        self.edgesForExtendedLayout = UIRectEdge.None
        tableView.tableHeaderView = UIView()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableUser.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath)
        let user = availableUser[indexPath.row]
        cell.textLabel?.text = user.userName
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = availableUser[indexPath.row]
        guard let userName = user.userName where userName != "" else {return}
        apiManager.startChat(withUserName: userName) { (successful, result, serverError, error) -> () in
            if successful {
                self.tabBarController?.selectedIndex = 1
            }
            else {
                let alert = UIAlertController(title: "Wrong username", message: "Please enter correct username.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}