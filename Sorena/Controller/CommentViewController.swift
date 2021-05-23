//
//  CommentViewController.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/01/26.
//

import UIKit
import SDWebImage
import FirebaseFirestore

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var uiView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var mistakeLabel: UILabel!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet weak var heartCountLabel: UILabel!
    
    @IBOutlet weak var empathyCountLabel: UILabel!
    
    @IBOutlet weak var fightCountLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textView: PlaceHolderTextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    
    var userId = String()
    var userName = String()
    var userEmail = String()
    var userProfileUrl = String()
    var date = String()
    var mistake = String()
    var likeCount = String()
    var heartCount = String()
    var empathyCount = String()
    var fightCount = String()
    var idString = String()
    var dataSets:[CommentModel] = []
    var commentDate = String()
    
    
    var contributorName = String()
    var contributorProfileImageUrl = String()
    
    
    
    
    
    
    let screenSize = UIScreen.main.bounds.size
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //カスタムセル「PostCell.xib」を登録
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "commentCell")
        
        
        // Do any additional setup after loading the view.s
        uiView.layer.borderColor = UIColor.orange.cgColor
        uiView.layer.borderWidth = 1.0
        
        userNameLabel.text = contributorName
        dateLabel.text = date
        mistakeLabel.text = mistake
        likeCountLabel.text = likeCount
        heartCountLabel.text = heartCount
        empathyCountLabel.text = empathyCount
        fightCountLabel.text = fightCount
        let url = URL(string: contributorProfileImageUrl)
        var data = Data()
        
        do {
            data = try Data(contentsOf: url!)
        } catch let error {
            print("Error:\(error)")
        }
        profileImageView.image = UIImage(data: data)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommentViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue?.height
        
        textView.frame.origin.y = screenSize.height - keyboardHeight! - textView.frame.height
        sendButton.frame.origin.y = screenSize.height - keyboardHeight! - sendButton.frame.height
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
//        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue?.height
        
        textView.frame.origin.y = screenSize.height - textView.frame.height - 20
        sendButton.frame.origin.y = screenSize.height - sendButton.frame.height - 20
        guard let duration  = notification.userInfo? [UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {return
        }
        
        UIView.animate(withDuration: duration) {
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
            
        }
        
    }
    
    func loadData() {
        db.collection("PostData").document(idString).collection("comments").order(by: "postDate").addSnapshotListener { (snapShot, error) in
            self.dataSets = []
            
            if error != nil {
                return
            }
            
            if let snapShotDoc = snapShot?.documents {
                
                for doc in snapShotDoc {
                    let data = doc.data()
                    
                    if let userName = data["userName"] as? String, let comment = data["comment"] as? String, let postDate = data["postDate"] as? Double, let profileImageUrl = data["profileImageUrl"] as? String{
                        
                        let date = NSDate(timeIntervalSince1970: postDate )
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy/MM/dd HH:mm"
                        let dateStr: String = formatter.string(from: date as Date)
                        
                        let commentModel = CommentModel(userName: userName, comment: comment, postDate: dateStr, profileImageUrl: profileImageUrl)
                        
                        self.dataSets.append(commentModel)
                    }
                }
                self.dataSets.reverse()
                self.tableView.reloadData()
            }
        }
    }
    
    //返信を投稿するためのアクション
    @IBAction func postAction(_ sender: Any) {
        //textFieldに文字が入力されていない時
        if textView.text.isEmpty == true {
            return
        }
        
        db.collection("PostData").document(idString).collection("comments").document().setData(["userName": userName as Any, "comment": textView.text! as Any, "postDate": Date().timeIntervalSince1970, "profileImageUrl": userProfileUrl])
        
        textView.text = ""
        
        //テキストフィールドを閉じる
        textView.resignFirstResponder()
    }
    
    //戻るボタンが押された時のアクション
    @IBAction func back(_ sender: Any) {
        let homeTBC = self.storyboard?.instantiateViewController(withIdentifier: "homeTBC") as! HomeTabBarController
        homeTBC.modalTransitionStyle = .crossDissolve
        homeTBC.userId = userId
        homeTBC.userName = userName
        homeTBC.userEmail = userEmail
        homeTBC.userProfileUrl = userProfileUrl
        self.present(homeTBC, animated: true, completion: nil)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as? CommentCell
        
        tableView.rowHeight = 126
        cell?.commentLabel.numberOfLines = 0
        cell?.nameLabel.text = dataSets[indexPath.row].userName
        cell?.date.text = dataSets[indexPath.row].postDate
        cell?.commentLabel.text = dataSets[indexPath.row].comment
        let url = URL(string: dataSets[indexPath.row].profileImageUrl)
        var data = Data()
        do {
            data = try Data(contentsOf: url!)
        } catch let error {
            print(error)
        }
        cell?.uiImageView.image = UIImage(data: data)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        tableView.estimatedRowHeight = 126
        //可変にするために書く
        return UITableView.automaticDimension
        
    }
}
