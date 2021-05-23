//
//  User.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/02/05.
//

import Foundation
import FirebaseFirestore
import Firebase

class User {
    
    let email:String
    let username: String
    var createdAt = Timestamp()
    let profileImageUrl: String
    let userId:String
    
    
    //ユーザ情報を保存するための変数
    var uid: String?
    

    init(dic: [String: Any]) {
        self.email = dic["userEmail"] as? String ?? ""
        self.userId = dic["userId"] as? String ?? ""
        self.username = dic["userName"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.profileImageUrl = dic["userProfileUrl"] as? String ?? ""
    }
    
    
}
