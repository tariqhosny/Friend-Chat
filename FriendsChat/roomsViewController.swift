//
//  roomsViewController.swift
//  FriendsChat
//
//  Created by Tariq M.fathy on 6/15/19.
//  Copyright © 2019 Tariq M.fathy. All rights reserved.
//

import UIKit
import Firebase

class roomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var roomsTable: UITableView!
    @IBOutlet weak var roomTextField: UITextField!
 
    var rooms = [Rooms]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.roomsTable.delegate = self
        self.roomsTable.dataSource = self
        hideKeyboardWhenTappedAround()
        observeation()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(Auth.auth().currentUser == nil){
            self.presrntLoginScreen()
            observeation()
        }
    }
    
    func observeation(){
        let databaseReference = Database.database().reference()
        databaseReference.child("rooms").observe(.childAdded) { (snapshot) in
            if let databaseArray = snapshot.value as? [String: Any]{
                if let roomName = databaseArray["roomName"] as? String{
                    let room = Rooms.init(roomId: snapshot.key, roomName: roomName)
                    self.rooms.append(room)
                    self.roomsTable.reloadData()
                }
            }
        }
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        try! Auth.auth().signOut()
        self.presrntLoginScreen()
    }
    func presrntLoginScreen (){
        let formScreen = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreen") as! ViewController
        self.present(formScreen, animated: true, completion: nil)
    }
    
    @IBAction func didPressedCreateRoom(_ sender: Any) {
        guard let roomName = self.roomTextField.text, roomName.isEmpty == false else{
            return
        }
        let databaseReference = Database.database().reference()
        let room = databaseReference.child("rooms").childByAutoId()
        let dataArray:[String: Any] = ["roomName": roomName]
        room.setValue(dataArray) { (error, reference) in
            if(error == nil){
                self.roomTextField.text = ""
                self.roomsTable.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let room = self.rooms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomsCell", for: indexPath)
        cell.textLabel?.text = room.roomName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedroom = self.rooms[indexPath.row]
        let chatRoomView = self.storyboard?.instantiateViewController(withIdentifier: "chatRoom") as! chatRoomViewController
        chatRoomView.room = selectedroom
        self.navigationController?.pushViewController(chatRoomView, animated: true)
        
    }
    
    

}
