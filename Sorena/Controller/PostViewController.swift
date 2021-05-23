//
//  PostViewController.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/01/21.
//

import UIKit
import Firebase
import FirebaseFirestore


class PostViewController: UIViewController {
    
    //投稿ボタンを扱うための変数
    @IBOutlet weak var postButton: UIButton!
    //キャンセルボタンを扱うための変数
    @IBOutlet weak var cancelButton: UIButton!
    //TextViewを扱うための変数
    @IBOutlet weak var textView: PlaceHolderTextView!
    //ユーザ名を扱う変数
    var userName = String()
    //ユーザのメールアドレスを扱う変数
    var userEmail = String()
    //ユーザIDを扱う変数
    var userId = String()
    //ユーザのプロフィール画像のURLを扱う変数
    var userProfileUrl = String()
    //Firestoreを扱うための変数
    let db = Firestore.firestore()
    let db2 = Firestore.firestore()
    //
    var idString = String()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //投稿ボタンの枠線の幅を指定
        postButton.layer.borderWidth = 1.0
        //投稿ボタンの枠線の色を指定
        postButton.layer.borderColor = UIColor.orange.cgColor
        //投稿ボタンの角丸のサイズ
        postButton.layer.cornerRadius = 20.0
        
        //UINavigationControllerの戻るボタンを消す
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUserData()
        
        if UserDefaults.standard.object(forKey: "documentID") != nil {
            idString = String(idString.dropFirst(9))
            idString = UserDefaults.standard.object(forKey: "documentID") as! String
        }else{
            idString = db.collection("PostData").document().path
            idString = String(idString.dropFirst(9))
            UserDefaults.standard.setValue(idString, forKey: "documentID")
        }
    }
    
    func loadUserData() {
        let docRef = db2.collection("RegisterdUsers").document(userId)
        docRef.getDocument{ (document, error) in
            let userId = document?.data()!["userId"]
            let userName = document?.data()!["userName"]
            let userEmail = document?.data()!["userEmail"]
            let userProfileUrl = document?.data()!["userProfileUrl"]
            self.userId = userId as! String
            self.userName = userName as! String
            self.userEmail = userEmail as! String
            self.userProfileUrl = userProfileUrl as! String
        }
    }
    
    
    //投稿ボタンが押された時のアクション
    @IBAction func postButtonAction(_ sender: Any) {
        if textView.text != "" {
            //Firestoreのコレクション「PostData」にデータを送信
            idString = db.collection("PostData").document().path
            idString = String(idString.dropFirst(9))
            UserDefaults.standard.setValue(idString, forKey: "documentID")
            
            db.collection("PostData").document(idString).setData(
                ["mistake": textView.text as? Any, "userName": userName as? Any, "postDate": Date().timeIntervalSince1970, "likeCount": 0, "likeFlagDic": [idString: false],
                 "heartCount": 0, "heartFlagDic": [idString: false], "empathyCount": 0, "empathyFlagDic": [idString: false], "fightCount": 0, "fightFlagDic": [idString: false], "profileImageUrl": userProfileUrl
                ]
            )
        }
        //TextViewのテキストを初期化する
        textView.text = ""
        //キーボードを閉じる
        textView.endEditing(true)
    }
    
    //キャンセルボタンが押された時のアクション
    @IBAction func cancelButtonAction(_ sender: Any) {
        //textViewのテキストを初期化する
        textView.text = ""
        //キーボードを閉じる
        self.view.endEditing(true)
        
    }
    
    //TextView以外がの部分をタッチした時のアクション
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //キーボードを閉じる
        self.view.endEditing(true)
    }
}
