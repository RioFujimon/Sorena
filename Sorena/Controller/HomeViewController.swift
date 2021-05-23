//
//  HomeViewController.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/01/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseUI
import SDWebImage

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
    //構造体PostDataModelの配列を扱うための変数
    var dataSets:[PostDataModel] = []
    
    //tableViewを扱うための変数
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        //カスタムセル「PostCell.xib」を登録
        tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        if UserDefaults.standard.object(forKey: "documentID") != nil {
            idString = UserDefaults.standard.object(forKey: "documentID") as! String
        }
        
        //ナビゲーションアイテムのタイトルに画像を設定する。
        self.navigationController?.navigationItem.titleView = UIImageView(image: UIImage(named: "sorena"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    func loadData() {
        //FirebaseのコレクションPostDataのdocumentを取得
        db.collection("PostData").order(by: "postDate").addSnapshotListener { (snapShot, error) in
            
            //PostData型が入る配列を初期化
            self.dataSets = []
            
            //エラー処理を行う
            if error != nil {
                return
            }
            
            if let snapShotDoc = snapShot?.documents {
                for doc in snapShotDoc {
                    //documentのデータにアクセスする
                    let data = doc.data()
                    
                    let date = NSDate(timeIntervalSince1970: data["postDate"] as! TimeInterval)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd HH:mm"
                    let dateStr: String = formatter.string(from: date as Date)
                    
                    
                    
                    
                    if  let mistake = data["mistake"] as? String,let userName = data["userName"] as? String,let likeCount = data["likeCount"] as? Int, let likeFlagDic = data["likeFlagDic"] as? Dictionary<String,Bool>, let heartCount = data["heartCount"] as? Int, let heartFlagDic = data["heartFlagDic"] as? Dictionary<String, Bool>, let empathyCount = data["empathyCount"] as? Int, let empathyFlagDic = data["empathyFlagDic"] as? Dictionary<String, Bool>, let fightCount = data["fightCount"] as? Int,let fightFlagDic = data["fightFlagDic"] as? Dictionary<String, Bool>, let profileImageUrl = data["profileImageUrl"] as? String{
                        
                        if likeFlagDic["\(doc.documentID)"] != nil, heartFlagDic["\(doc.documentID)"] != nil, empathyFlagDic["\(doc.documentID)"] != nil, fightFlagDic["\(doc.documentID)"] != nil {
                            
                            let postDataModel = PostDataModel(mistake: mistake, userName: userName, docId: doc.documentID, likeCount: likeCount, likeFlagDic: likeFlagDic, heartCount: heartCount, heartFlagDic: heartFlagDic, empathyCount: empathyCount, empathyFlagDic: empathyFlagDic, fightCount: fightCount, fightFlagDic: fightFlagDic, profileImageUrl: profileImageUrl, postDate: dateStr)
                            
                            self.dataSets.append(postDataModel)
                        }
                    }
                }
                self.dataSets.reverse()
                //テーブルビューをリロード
                self.tableView.reloadData()
            }
        }
    }
    
    //ハンバーガーメニューを表示する
    @IBAction func humbergerMenuAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showMenu", sender: nil)
    }
    
    //TableViewCellを何個表示するかを指定するメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //表示するセルの数を返す
        return dataSets.count
    }
    
    //表示するTableViewCellの設定を行うfunction()
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? PostCell
        
        tableView.rowHeight = 250
        
        //可変セルにする
        cell?.mistakeLabel.numberOfLines = 0
        //ユーザのプロフィール画像を設定する
        cell?.profileImageView.sd_setImage(with: URL(string: dataSets[indexPath.row].profileImageUrl), completed: nil)
        cell?.profileImageView.layer.cornerRadius = 30
        //ユーザ名用のラベルにユーザ名を設定する
        cell?.userNameLabel.text = dataSets[indexPath.row].userName
        //日付用のラベルに日付を設定する
        cell?.dateLabel.text = dataSets[indexPath.row].postDate
        //投稿されたミスの内容をラベルに設定する
        cell?.mistakeLabel.text = "\(self.dataSets[indexPath.row].mistake)"
        
        
        //likeButtonにタグをつける
        cell?.likeButton.tag = indexPath.row
        //likeCountLabelにlike数を設定する
        cell?.likeCountLabel.text = String(self.dataSets[indexPath.row].likeCount)
        //likeButton押された時のアクションを設定する
        cell?.likeButton.addTarget(self, action: #selector(like(_ :)), for: .touchUpInside)
        //いいねを押された時の処理
        if (self.dataSets[indexPath.row].likeFlagDic[idString] != nil) == true {
            //定数flagにtrueまたはfalseを代入
            let flag = self.dataSets[indexPath.row].likeFlagDic[idString]
            //flagがtrueの時の処理
            if flag! == true {
                //画像をいいねされた時のものにする
                cell?.likeButton.setImage(UIImage(named: "like_red"), for: .normal)
            }else {
                //画像をいいねされていない時のものにする
                cell?.likeButton.setImage(UIImage(named: "like"), for: .normal)
            }
        }
        
        
        //ハートボタンにタグを設定する
        cell?.heartButton.tag = indexPath.row
        //ハートボタンが押された数をラベルに設定する
        cell?.heartCountLabel.text = String(self.dataSets[indexPath.row].heartCount)
        //ハートボタンが押された時の処理を設定する
        cell?.heartButton.addTarget(self, action: #selector(heart(_ :)), for: .touchUpInside)
        //ハートボタンが押された時の処理
        if (self.dataSets[indexPath.row].heartFlagDic[idString] != nil) == true {
            //定数flagにtrueまたはfalseを代入
            let flag = self.dataSets[indexPath.row].heartFlagDic[idString]
            //flagがtrueの時の処理
            if flag! as! Bool == true {
                //画像をハートが押された時のものにする
                cell?.heartButton.setImage(UIImage(named: "heart_red"), for: .normal)
            }else {
                //画像をハートが押されていない時のものにする
                cell?.heartButton.setImage(UIImage(named: "heart"), for: .normal)
            }
        }
        
        
        //共感ボタンにタグを設定する
        cell?.empathyButton.tag = indexPath.row
        //共感数をラベルに設定する
        cell?.empathyCountLabel.text = String(self.dataSets[indexPath.row].empathyCount)
        //共感ボタンにアクションを設定する
        cell?.empathyButton.addTarget(self, action: #selector(empathy(_ :)), for: .touchUpInside)
        //共感ボタンが押された時の処理
        if (self.dataSets[indexPath.row].empathyFlagDic[idString] != nil) == true {
            //定数flagにtrueまたはfalseを設定する
            let flag = self.dataSets[indexPath.row].empathyFlagDic[idString]
            //flagがtrueの時の処理
            if flag! as! Bool == true {
                //画像を共感が押されたときのものにする
                cell?.empathyButton.setImage(UIImage(named: "empathy_red"), for: .normal)
            }else {
                //画像を共感ボタンが押されていない時のものにする
                cell?.empathyButton.setImage(UIImage(named: "empathy"), for: .normal)
            }
        }
        
        
        //fightButtonにタグを設定する
        cell?.fightButton.tag = indexPath.row
        //fightButtonが押された数をラベルに反映する
        cell?.fightCountLabel.text = String(self.dataSets[indexPath.row].fightCount)
        //fightButtonが押された時の処理を設定
        cell?.fightButton.addTarget(self, action: #selector(fight(_ :)), for: .touchUpInside)
        //fightButtonが押された時の処理
        if (self.dataSets[indexPath.row].fightFlagDic[idString] != nil) == true {
            //定数flagにtrueまたはfalseを設定する
            let flag = self.dataSets[indexPath.row].fightFlagDic[idString]
            //flagがtrueの時の処理
            if flag! as! Bool == true {
                //fightButtonが押された時の画像を設定する
                cell?.fightButton.setImage(UIImage(named: "fight_red"), for: .normal)
            }else {
                //fightButtonが押されていない時の画像を設定する
                cell?.fightButton.setImage(UIImage(named: "fight"), for: .normal)
            }
        }
        
        //commentボタンにタグを設定する
        cell?.commentButton.tag = indexPath.row
        //commentボタンが押された時の処理を設定
        cell?.commentButton.addTarget(self, action: #selector(comment(_ :)), for: .touchUpInside)
        
        //cellを返す
        return cell!
    }
    
    //likeButtonが押された時の処理
    @objc func like(_ sender: UIButton) {
        //senderはボタンの内容
        //いいね数をカウントするための変数
        var count = Int()
        //いいねが押されているかを判定する変数
        let flag = self.dataSets[sender.tag].likeFlagDic[idString]
        
        //いいねが始めている押される場合
        if flag == nil {
            //いいね数を1プラスする
            count = self.dataSets[sender.tag].likeCount + 1
            //likeFlagDicをcollection「PostData」に追加する(mergeがないと他の人のデータが消えるので注意)
            db.collection("PostData").document(dataSets[sender.tag].docId).setData(["likeFlagDic":[idString:true]], merge: true)
        }else {
            //いいねが一度は押している場合
            //いいねがtrueの時
            if flag! as! Bool == true {
                //いいね数を1マイナスする
                count = self.dataSets[sender.tag].likeCount - 1
                //likeFlagDicをcollection「PostData」に追加する(mergeがないと他の人のデータが消えるので注意)
                db.collection("PostData").document(dataSets[sender.tag].docId).setData(["likeFlagDic":[idString:false]], merge: true)
            }else {
                //いいねがfalseの時
                //いいね数を1プラスする
                count = self.dataSets[sender.tag].likeCount + 1
                //likeFlagDicをcollection「PostData」に追加する(mergeがないと他の人のデータが消えるので注意)
                db.collection("PostData").document(dataSets[sender.tag].docId).setData(["likeFlagDic":[idString:true]], merge: true)
            }
        }
        
        //collection「PostData」のlikeCountをアップデートする
        db.collection("PostData").document(dataSets[sender.tag].docId).updateData(["likeCount": count], completion: nil)
        //tableViewをリロードする
        tableView.reloadData()
    }
    
    //heartボタンが押された時の処理
    @objc func heart(_ sender: UIButton) {
        //senderはボタンの内容
        //ハートが押された数をカウントするための変数
        var count = Int()
        //ハートボタンが押されているかを判定する変数
        let flag = self.dataSets[sender.tag].heartFlagDic[idString]
        
        //初めてハートボタンが押される場合
        if flag == nil {
            //ハートボタンが押されている数を1プラスする
            count = self.dataSets[sender.tag].heartCount + 1
            //heartFlagDicをcollection「PostData」に追加する(mergeがないと他の人のデータが消えるので注意)
            db.collection("PostData").document(dataSets[sender.tag].docId).setData(["heartFlagDic":[idString:true]], merge: true)
        }else {
            //一度はハートボタンが押されている場合
            //ハートボタンが押されている時
            if flag! as! Bool == true {
                //ハートが押されている数を1マイナスする
                count = self.dataSets[sender.tag].heartCount - 1
                //heartFlagDicをcollection「PostData」に追加する(mergeがないと他の人のデータが消えるので注意)
                db.collection("PostData").document(dataSets[sender.tag].docId).setData(["heartFlagDic":[idString:false]], merge: true)
            }else {
                //ハートボタンが押されていない時
                //ハートボタンが押されている数を1プラスする
                count = self.dataSets[sender.tag].heartCount + 1
                //heartFlagDicをcollection「PostData」に追加する(mergeがないと他の人のデータが消えるので注意)
                db.collection("PostData").document(dataSets[sender.tag].docId).setData(["heartFlagDic":[idString:true]], merge: true)
            }
        }
        //collection「PostData」のheartCountをアップデートする
        db.collection("PostData").document(dataSets[sender.tag].docId).updateData(["heartCount": count], completion: nil)
        //tableViewをリロードする
        tableView.reloadData()
    }
    
    
    //empathyボタンが押された時の処理
    @objc func empathy(_ sender: UIButton) {
        //senderはボタンの内容
        
        //empathyボタンが押された数をカウントするための変数
        var count = Int()
        //empathyボタンが押されているかを判定するための変数
        let flag = self.dataSets[sender.tag].empathyFlagDic[idString]
        //flagが一度も押されていない場合
        if flag == nil {
            //empathyボタンが押された数を1プラスする
            count = self.dataSets[sender.tag].empathyCount + 1
            //empathyFlagDicをcollection「PostData」に追加する(mergeがないと他の人のデータが消えるので注意)
            db.collection("PostData").document(dataSets[sender.tag].docId).setData(["empathyFlagDic":[idString:true]], merge: true)
        }else {
            //一度はempathyボタンを押している時
            //empathyボタンが押されている時
            if flag! as! Bool == true {
                //empathyボタンが押された数を1マイナスする
                count = self.dataSets[sender.tag].empathyCount - 1
                //empathyFlagDicをcollection「PostData」に追加する(mergeがないと他の人のデータが消えるので注意)
                db.collection("PostData").document(dataSets[sender.tag].docId).setData(["empathyFlagDic":[idString:false]], merge: true)
            }else {
                //empathyボタンが押された数を1プラスする
                count = self.dataSets[sender.tag].empathyCount + 1
                //empathyFlagDicをcollection「PostData」に追加する(mergeがないと他の人のデータが消えるので注意)
                db.collection("PostData").document(dataSets[sender.tag].docId).setData(["empathyFlagDic":[idString:true]], merge: true)
            }
        }
        //collection「PostData」のempathyCountをアップデートする
        db.collection("PostData").document(dataSets[sender.tag].docId).updateData(["empathyCount": count], completion: nil)
        //tableViewをリロードする
        tableView.reloadData()
    }
    
    
    //fightボタンが押された時の処理
    @objc func fight(_ sender: UIButton) {
        //senderはボタンの内容
        //fightボタンが押された数をカウントする変数
        var count = Int()
        //fightボタンが押されているかを判定する変数
        let flag = self.dataSets[sender.tag].fightFlagDic[idString]
        
        //fightボタンが初めて押された時
        if flag == nil {
            //fightボタンが押された数を1プラスする
            count = self.dataSets[sender.tag].fightCount + 1
            //fightFlagDicをcollection「PostData」に追加する(mergeがないと他の人のデータが消えるので注意)
            db.collection("PostData").document(dataSets[sender.tag].docId).setData(["fightFlagDic":[idString:true]], merge: true)
            
        }else {
            //fightボタンを一度押している場合
            //fightボタンが押されている時
            if flag! as! Bool == true {
                //fightボタンが押された数を1マイナスする
                count = self.dataSets[sender.tag].fightCount - 1
                //fightFlagDicをcollection「PostData」に追加する(mergeがないと他の人のデータが消えるので注意)
                db.collection("PostData").document(dataSets[sender.tag].docId).setData(["fightFlagDic":[idString:false]], merge: true)
            }else {
                //fightボタンが押されていない時
                //fightボタンが押された数を1プラスする
                count = self.dataSets[sender.tag].fightCount + 1
                //fightFlagDicをcollection「PostData」に追加する(mergeがないと他の人のデータが消えるので注意)
                db.collection("PostData").document(dataSets[sender.tag].docId).setData(["fightFlagDic":[idString:true]], merge: true)
            }
        }
        
        //collection「PostData」のfightCountをアップデートする
        db.collection("PostData").document(dataSets[sender.tag].docId).updateData(["fightCount": count], completion: nil)
        //tableViewをリロードする
        tableView.reloadData()
    }
    
    //コメントボタンが押された時の処理
    @objc func comment(_ sender: UIButton){
        let commentVC = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! CommentViewController
        commentVC.userId = userId
        commentVC.userName = userName
        commentVC.userEmail = userEmail
        commentVC.userProfileUrl = userProfileUrl
        commentVC.date = dataSets[sender.tag].postDate
        commentVC.mistake = dataSets[sender.tag].mistake
        commentVC.likeCount = String(dataSets[sender.tag].likeCount)
        commentVC.heartCount = String(dataSets[sender.tag].heartCount)
        commentVC.empathyCount = String(dataSets[sender.tag].empathyCount)
        commentVC.fightCount = String(dataSets[sender.tag].fightCount)
        commentVC.idString = dataSets[sender.tag].docId
        
        commentVC.contributorName = dataSets[sender.tag].userName
        commentVC.contributorProfileImageUrl = dataSets[sender.tag].profileImageUrl
        
        self.present(commentVC, animated: true, completion: nil)
    }
    
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 250
        //可変にする
        return UITableView.automaticDimension
    }
}
