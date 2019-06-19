//
//  chatRoomViewController.swift
//  FriendsChat
//
//  Created by Tariq M.fathy on 6/16/19.
//  Copyright © 2019 Tariq M.fathy. All rights reserved.
//

import UIKit
import Firebase

class chatRoomViewController: UIViewController {
    @IBOutlet weak var chatText: UITextField!
    
    var room:Rooms?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }
    
    func getUsenameWithId(userId: String, completion: @escaping (_ username: String?) -> ()){
        let databaseReference = Database.database().reference()
        let user = databaseReference.child("users").child(userId)
        user.child("username").observeSingleEvent(of: .value) { (snapshot) in
            if let username = snapshot.value as? String{
                completion(username)
            }
        }
    }
    
    func sendMessage(messageText: String, completion: @escaping (_ isSuccess: Bool) -> ()){
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let databaseReference = Database.database().reference()
        getUsenameWithId(userId: userID) { (userName) in
            if let username = userName{
                if let roomId = self.room?.roomId{
                    let dataArray: [String: Any] = ["senderName": username, "meassage": messageText]
                    let room = databaseReference.child("rooms").child(roomId)
                    room.child("message").childByAutoId().setValue(dataArray, withCompletionBlock: { (error, ref) in
                        if(error == nil){
                            completion(true)
                            self.chatText.text = ""
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func didPressedSend(_ sender: UIButton) {
        guard let chatTextMessage = self.chatText.text, chatTextMessage.isEmpty == false else {
            return
        }
        sendMessage(messageText: chatTextMessage) { (isSuccess) in
            if(isSuccess){
                print("Message Sent again")
            }
        }

    }
    

}

