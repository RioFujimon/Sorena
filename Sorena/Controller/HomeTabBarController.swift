//
//  HomeTabBarController.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/01/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeTabBarController: UITabBarController, UITabBarControllerDelegate{
    
    //ユーザ名を扱う変数
    var userName = String()
    //ユーザのメールアドレスを扱う変数
    var userEmail = String()
    //ユーザIDを扱う変数
    var userId = String()
    //ユーザのプロフィール画像のURLを扱う変数
    var userProfileUrl = String()
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        //HomeViewControllerにGoogleのアカウントのユーザ名・メールアドレス・ユーザID・プロフィール画像のURLを渡す
        let homeVC = self.viewControllers![0] as! HomeViewController
        homeVC.userId = userId
        homeVC.userName = userName
        homeVC.userEmail = userEmail
        homeVC.userProfileUrl = userProfileUrl
        
        //PostViewControllerにGoogleのアカウントのユーザ名・メールアドレス・ユーザID・プロフィール画像のURLを渡す
        let postVC = self.viewControllers![1] as! PostViewController
        postVC.userId = userId
        postVC.userName = userName
        postVC.userEmail = userEmail
        postVC.userProfileUrl = userProfileUrl
        
        //PostViewControllerにGoogleのアカウントのユーザ名・メールアドレス・ユーザID・プロフィール画像のURLを渡す
        let findVC = self.viewControllers![2] as! FindViewController
        findVC.userId = userId
        findVC.userName = userName
        findVC.userEmail = userEmail
        findVC.userProfileUrl = userProfileUrl
        
        //ChatListViewControllerにGoogleのアカウントのユーザ名・メールアドレス・ユーザID・プロフィール画像のURLを渡す
        let chatListVC = self.viewControllers![3] as! ChatListViewController
        chatListVC.userId = userId
        chatListVC.userName = userName
        chatListVC.userEmail = userEmail
        chatListVC.userProfileUrl = userProfileUrl
        
        //バーナビゲーションを消す
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController != self.viewControllers![2] as! FindViewController {
            let findVC = self.viewControllers![2] as! FindViewController
            findVC.dataSets = []
        }
    }
}
