//
//  LoginViewController.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/01/23.
//

import UIKit
import Firebase
import FirebaseFirestore
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate {
    
    //Googleログインを行うためのボタンを扱う変数
    @IBOutlet var googleSignInButton: GIDSignInButton!
    
    @IBOutlet weak var SignInButton: UIButton!
    
    //Firestoreを扱う変数
    let db = Firestore.firestore()
    
    
    var userId = String()
    var userName = String()
    var userEmail = String()
    var userProfileUrl = String()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        SignInButton.layer.cornerRadius = 10
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        //自動ログイン処理（ログアウトしていない場合）
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    }
    
    
    @IBAction func googleLoginAction(_ sender: Any) {
        //Googleログインを実装
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            //エラーがあった場合の処理
            print("\(error.localizedDescription)")
        } else {
            //エラーがなかった場合の処理
            userId = user.userID
            userName = user.profile.name
            userEmail = user.profile.email
            userProfileUrl = user.profile.imageURL(withDimension: .min)!.absoluteString
            
            //ログイン成功時にuserをコレクション「RegisterdUsers」に登録する
            db.collection("RegisterdUsers").document(userId).setData(
                ["userId": userId, "userName": userName, "userEmail": userEmail, "userProfileUrl": userProfileUrl, "createdAt": Timestamp()]
            )
            
            //HomeTabBarControllerに画面遷移
            self.performSegue(withIdentifier: "homeTBC", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeTBC" {
            let nextVC = segue.destination as! HomeTabBarController
            nextVC.userId = userId
            nextVC.userName = userName
            nextVC.userEmail = userEmail
            nextVC.userProfileUrl = userProfileUrl
        }
    }
    
    //追記部分(デリゲートメソッド)エラー来た時
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        print(error.localizedDescription)
    }
}
