//
//  SettingsViewController.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 1/17/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SettingsViewController: UIViewController {
    @IBOutlet weak var userInfo: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBAction func train(_ sender: Any) {
        Trainer.shared.train(name: "train", extension: "txt")
    }

    @IBAction func login(_ sender: Any) {
        let auth = Auth.auth()
//        do {try auth.signOut()}
//        catch let signOutError as NSError {print ("No logged in user: %@", signOutError)}
        auth.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            self.loadUserInfo()
        }
    }
//    @IBAction func register(_ sender: Any) {
////        let registerViewController = self.storyboard?.instantiateViewController(withIdentifier: "registerViewController") as! RegisterViewController
////        registerViewController.modalPresentationStyle = .popover
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let registerViewController = storyboard.instantiateViewController(withIdentifier: "registerViewController")
//        self.present(registerViewController, animated: true, completion: nil)
//    }
    @IBAction func logout(_ sender: Any) {
        do {try Auth.auth().signOut()}
        catch let signOutError as NSError {print ("Error signing out: %@", signOutError)}
        self.loadUserInfo()
    }
    
    func loadUserInfo() {
        self.userInfo.text = ""
        let authUser = Auth.auth().currentUser
//        do {try Auth.auth().signOut()}
//        catch let error as NSError{}
        if let user = authUser {
            Firestore.firestore().collection("users").document(user.uid).getDocument { (document, error) in
                if let document = document {
//                    print("Document data: \(document.data())")
                    if let data = document.data() {
                        self.userInfo.text = self.userInfo.text! + (data["first_name"] as! String)  + " " + (data["last_name"] as! String) + "\n"
                        self.userInfo.text = self.userInfo.text! + (data["username"] as! String) + "\n"
                        self.userInfo.text = self.userInfo.text! + (data["email"] as! String)
                    }
                }
                else {print("Document does not exist")}
            }

//            var _ = Database.database().reference(withPath: "users/" + user.uid).observe(DataEventType.value, with: { (snapshot) in
//                let postDict = snapshot.value as? [String : AnyObject] ?? [:]
//                self.userInfo.text = self.userInfo.text! + (postDict["first_name"] as! String)  + " " + (postDict["last_name"] as! String) + "\n"
//                self.userInfo.text = self.userInfo.text! + (postDict["username"] as! String) + "\n"
//                self.userInfo.text = self.userInfo.text! + (postDict["email"] as! String)
//            })
        }
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
    }
    
    @IBAction func addWord(_ sender: Any) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Add word", message: "Enter the new word here", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            //getting the input values from user
            if let textWord = alertController.textFields?[0].text?.lowercased() {
                if !(VocabDatabase.shared.doesWordExist(withText: textWord)) {
                    let word = Word(value: textWord)
                    //FIXME!!!
                    VocabDatabase.shared.create(word: word)
                }

//                if let user = Auth.auth().currentUser {
//                    let uid = user.uid
//                    Firestore.firestore().collection("users").document(user.uid).collection("words").addDocument(data: [word: word]) { err in
//                        if let err = err {print("Error writing document: \(err)")}
//                        else {print("Document successfully written!")}
//                    }
//                    //                    let updateSuccess = VocabDatabase.shared.update(word: Word(value: word))
//                }
            }
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Word"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
