//
//  ViewController.swift
//  FriendsChat
//
//  Created by Tariq M.fathy on 6/14/19.
//  Copyright © 2019 Tariq M.fathy. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.hideKeyboardWhenTappedAround()
        
    }
     
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "formCell", for: indexPath) as! formCell
        if (indexPath.row == 0){
            cell.usernameContainer.isHidden = true
            cell.actionButton.setTitle("Login", for: .normal)
            cell.moveButton.setTitle("Sign up 👉 ", for: .normal)
            cell.moveButton.addTarget(self, action: #selector(slideToSignin(_:)), for: .touchUpInside)
            cell.actionButton.addTarget(self, action: #selector(pressSignIn(_:)), for: .touchUpInside)
        }else if(indexPath.row == 1){
            cell.usernameContainer.isHidden = false
            cell.actionButton.setTitle("Sign up", for: .normal)
            cell.moveButton.setTitle(" 👈 Login ", for: .normal)
            cell.moveButton.addTarget(self, action: #selector(slideToSignUp(_:)), for: .touchUpInside)
            cell.actionButton.addTarget(self, action: #selector(pressSignUp(_:)), for: .touchUpInside)
        }
        return cell
    }
    
    @objc func pressSignUp(_ sender: UIButton){
        let indexpath = IndexPath(item: 1, section: 0)
        let cell = self.collectionView.cellForItem(at: indexpath) as! formCell
        guard let emailAddress = cell.emailAddressText.text, let password = cell.passwordText.text, let username = cell.usernameText.text else{
            return
        }
        if (emailAddress.isEmpty == true || password.isEmpty == true || username.isEmpty == true){
            self.displayErrors(errorText: "Empty Fields")
        }else {
        Auth.auth().createUser(withEmail: cell.emailAddressText.text ?? "", password: cell.passwordText.text ?? "") { (result, error) in
            if (error == nil){
                guard let userId = result?.user.uid, let username = cell.usernameText.text else{
                    return
                }
                let reference = Database.database().reference()
                let user = reference.child("users").child(userId)
                let dataArray:[String: Any] = ["username": username, "Email": emailAddress]
                user.setValue(dataArray, withCompletionBlock: { (error, ref) in
                    self.dismiss(animated: true, completion: nil)
                })
                
            }
            }
        }
    }
    
    @objc func pressSignIn(_ sender: UIButton){
        let indexpath = IndexPath(item: 0, section: 0)
        let cell = self.collectionView.cellForItem(at: indexpath) as! formCell
        guard let emailAddress = cell.emailAddressText.text, let password = cell.passwordText.text else{
            return
        }
        if (emailAddress.isEmpty == true || password.isEmpty == true){
            self.displayErrors(errorText: "Email or Password is empty")
        }else {
            Auth.auth().signIn(withEmail: emailAddress, password: password) { (result, error) in
                if (error == nil){
                    self.dismiss(animated: true, completion: nil)
                    print(result?.user.email ?? "")
                }else{
                    self.displayErrors(errorText: "Email or Password incorrect")
                }
            }
        }
        }
    func displayErrors (errorText: String){
        let alert = UIAlertController.init(title: "Message", message: errorText, preferredStyle: .alert)
        let dismissAction = UIAlertAction.init(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func slideToSignin(_ sender: UIButton){
        let indexpath = IndexPath(item: 1, section: 0)
        self.collectionView.scrollToItem(at: indexpath, at: [.centeredHorizontally], animated: true)
    }
    
    @objc func slideToSignUp(_ sender: UIButton){
        let indexpath = IndexPath(item: 0, section: 0)
        self.collectionView.scrollToItem(at: indexpath, at: [.centeredHorizontally], animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.frame.size
    }


}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
