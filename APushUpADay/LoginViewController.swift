    //
//  LoginViewController.swift
//  APushUpADay
//
//  Created by Teo Lee on 4/4/20.
//  Copyright © 2020 Teo Lee. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
    
class LoginViewController: UIViewController, GIDSignInDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().signIn()
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("Google sign in error: \(error.localizedDescription)")
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        self.performSegue(withIdentifier: "successfulLogIn", sender: self)
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

}
