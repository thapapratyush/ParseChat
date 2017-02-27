//
//  ChatViewController.swift
//  ParseChat
//
//  Created by Pratyush Thapa on 2/24/17.
//  Copyright © 2017 Pratyush Thapa. All rights reserved.
//

import UIKit
import Parse

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let refreshTimeInterval: TimeInterval = 1
    
    @IBOutlet weak var chatMessage: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var messages : [PFObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 50
        
        Timer.scheduledTimer(timeInterval: refreshTimeInterval,
                             target: self,
                             selector: #selector(onTimer),
                             userInfo: nil,
                             repeats: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageCell,
            let messages = messages {
            
            let message = messages[indexPath.row]
            
            if let user = message.value(forKey: "user") as? PFUser, let username = user.username {
                cell.userNameLabel.isHidden = false
                cell.userNameLabel.text = "\(username): "
            } else {
                cell.userNameLabel.isHidden = true
            }
            
            let text = message.value(forKey: "text") as? String
            
            cell.messageLabel.text = text
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    @IBAction func chatButtonPressed(_ sender: AnyObject) {
        let msg = PFObject(className: "Message")
        msg["user"] = PFUser.current()!
        msg["text"] = chatMessage.text!
        msg.saveInBackground {
            (success: Bool, error: Error?) -> Void in
            if (success) {
                self.chatMessage.text = ""
            } else {
                print(error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    func onTimer() {
        // Cannot call by byAscending because the limited number of responses API returns
        // Must call byDescending first, then use the reversed method to show most recent message on the bottom
        let query = PFQuery(className: "Message").order(byDescending: "createdAt").includeKey("user")
        
        query.findObjectsInBackground { (response: [PFObject]?, error: Error?) in
            if let response = response {
                self.messages = response.reversed()
                self.tableView.reloadData()
                
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
            } else {
                print("error: \(error)")
            }
        }
    }
}
