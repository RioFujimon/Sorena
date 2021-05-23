//
//  ConsulViewController.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/01/30.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseUI
import SDWebImage

class FindViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //plan選択画面を表示するView
    @IBOutlet weak var planUIView: UIView!
    //相談相手を探す画面を表示するUIView
    @IBOutlet weak var findConsulPersonUIView: UIView!
    //相談相手の検索結果が表示されるUIView
    @IBOutlet weak var findResultUIView: UIView!
    //相談相手を探すボタン
    @IBOutlet weak var findConsulPersonButton: UIButton!
    //職種を入力するテキストフィールド
    @IBOutlet weak var occupationTextField: UITextField!
    //職歴を入力するテキストフィールド
    @IBOutlet weak var careerTextField: UITextField!
    //相談相手の年齢を入力するテキストフィールド
    @IBOutlet weak var ageTextField: UITextField!
    //相談相手の性別を入力するテキストフィールド
    @IBOutlet weak var sexTextField: UITextField!
    //tableViewを扱うための変数
    @IBOutlet weak var tableView: UITableView!
    //DM500円プランを選択するボタン
    @IBOutlet weak var DMPlanButton: UIButton!
    //面談プランボタンを選択するボタン
    @IBOutlet weak var consulPlanButton: UIButton!
    //DM月額プランを選択するボタン
    @IBOutlet weak var monthlyDMPlanButton: UIButton!
    //コンプリートプランを選択するボタン
    @IBOutlet weak var completePlanButton: UIButton!
    
    //Firestoreを利用する準備
    let db = Firestore.firestore()
    let db2 = Firestore.firestore()
    let storage = Storage.storage()
    
    
    //ConsulPersonModel型を扱う配列
    var dataSets:[ConsulPersonModel] = []
    
    var userId = String()
    var userName = String()
    var userEmail = String()
    var userProfileUrl = String()
    var partnerUids = [String]()
    var isDMPlan: Bool = false
    var isComplete: Bool = false
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        //planUIViewを表示
        planUIView.isHidden = false
        //findConsulPersonUIViewを非表示にする
        findConsulPersonUIView.isHidden = true
        //findResultUIViewを非表示
        findResultUIView.isHidden = true
        setupViews()
        //カスタムセル「PostCell.xib」を登録
        tableView.register(UINib(nibName: "ExpertCell", bundle: nil), forCellReuseIdentifier: "ExpertCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //planUIViewを表示
        planUIView.isHidden = false
        //findConsulPersonUIViewを非表示にする
        findConsulPersonUIView.isHidden = true
        //findResultUIViewを非表示
        findResultUIView.isHidden = true
        loadUserData()
        //tabBarItemが選択された時の画像をセット
        self.tabBarItem.selectedImage = UIImage(named: "find")
        //tabBarItemに画像をセット
        self.tabBarItem.image = UIImage(named: "find")
    }
    
    private func setupViews() {
        self.DMPlanButton.layer.cornerRadius = 15
        
        self.consulPlanButton.layer.cornerRadius = 15
        
        self.monthlyDMPlanButton.layer.cornerRadius = 15
        
        self.completePlanButton.layer.cornerRadius = 15
        
        //相談相手を探すボタンを装飾
        findConsulPersonButton.layer.cornerRadius = 15
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
    
    //DMPlanActionが押された時のアクション
    @IBAction func DMPlanAction(_ sender: Any) {
        isDMPlan = true
        
        //planUIViewが表示されていて、findConsulPersonUIViewが非表示の時
        if planUIView.isHidden == false && findConsulPersonUIView.isHidden == true {
            //planUIViewを非表示にする
            planUIView.isHidden = true
            //findConsulPersonUIViewを表示する
            findConsulPersonUIView.isHidden = false
        }
    }
    
    
    @IBAction func consulPlanAction(_ sender: Any) {
        isDMPlan = false
        
        //planUIViewが表示されていて、findConsulPersonUIViewが非表示の時
        if planUIView.isHidden == false && findConsulPersonUIView.isHidden == true {
            //planUIViewを非表示にする
            planUIView.isHidden = true
            //findConsulPersonUIViewを表示する
            findConsulPersonUIView.isHidden = false
        }
    }
    
    
    @IBAction func monthlyDMPlanAction(_ sender: Any) {
        isDMPlan = true
        
        //planUIViewが表示されていて、findConsulPersonUIViewが非表示の時
        if planUIView.isHidden == false && findConsulPersonUIView.isHidden == true {
            //planUIViewを非表示にする
            planUIView.isHidden = true
            //findConsulPersonUIViewを表示する
            findConsulPersonUIView.isHidden = false
        }
    }
    
    
    @IBAction func completePlanAction(_ sender: Any) {
        isComplete = true
        
        //planUIViewが表示されていて、findConsulPersonUIViewが非表示の時
        if planUIView.isHidden == false && findConsulPersonUIView.isHidden == true {
            //planUIViewを非表示にする
            planUIView.isHidden = true
            //findConsulPersonUIViewを表示する
            findConsulPersonUIView.isHidden = false
        }
    }
    
    //有識者を探すボタンが押された時のアクション
    @IBAction func findConsulPersonAction(_ sender: Any) {
        if occupationTextField.text != "", careerTextField.text != "", ageTextField.text != "", sexTextField.text != "" {
            //Firestoreのコレクション「Experts」から全てのdocumentを取得する
            db.collection("Experts").getDocuments() { (querySnapshot, err) in
                //エラーがあった場合
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.partnerUids = [String]()
                    //documentsからdocumentを1つずつ取得
                    for document in querySnapshot!.documents {
                        if (document.data()["sex"] as! String == self.sexTextField.text!), document.data()["occupation"] as! String == self.occupationTextField.text!, (document.data()["age"] as? Int == Int(self.ageTextField.text!) || document.data()["carrier"] as? Int == Int(self.careerTextField.text!)) {
                            //自分のuidと違うものであれば
                            if self.userId.trimmingCharacters(in: .whitespacesAndNewlines)  != document.documentID.trimmingCharacters(in: .whitespacesAndNewlines)  {
                                let partnerUid = document.documentID
                                self.partnerUids.append(partnerUid)
                            }
                            let name = document.data()["userName"] as! String
                            let sex  = document.data()["sex"] as! String
                            let age = document.data()["age"] as! Int
                            let occupation = document.data()["occupation"] as! String
                            let carrier = document.data()["carrier"] as! Int
                            let profileImageUrl = document.data()["userProfileUrl"] as! String
                            let consulPersonModel = ConsulPersonModel(name: name, age: age, sex: sex, occupation: occupation, career: carrier, profileImageUrl: profileImageUrl)
                            self.dataSets.append(consulPersonModel)
                            
                            self.occupationTextField.text = ""
                            self.careerTextField.text = ""
                            self.ageTextField.text = ""
                            self.sexTextField.text = ""
                        }
                    }
                }
                //テーブルビューをリロード
                self.tableView.reloadData()
            }
        }
        
        //planUIViewを非表示
        planUIView.isHidden = true
        //findConsulPersonUIViewを非表示にする
        findConsulPersonUIView.isHidden = true
        //findResultUIViewを表示
        findResultUIView.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpertCell", for: indexPath) as? ExpertCell
        
        tableView.rowHeight = 270
        
        cell?.profileImageView.sd_setImage(with: URL(string: dataSets[indexPath.row].profileImageUrl), completed: nil)
        
        cell?.nameLabel.text = dataSets[indexPath.row].name
        cell?.detailLabel.text = "職種：\(dataSets[indexPath.row].occupation)\n職歴：\(String(dataSets[indexPath.row].career))\n年齢：\(String(dataSets[indexPath.row].age))\n性別：\(dataSets[indexPath.row].sex)"
        
        if isComplete == true {
            cell?.DMButton.isEnabled = true
            cell?.consulButton.isEnabled = true
        }else if isDMPlan == true {
            cell?.DMButton.isEnabled = true
            cell?.consulButton.isEnabled = false
        }else {
            cell?.DMButton.isEnabled = false
            cell?.consulButton.isEnabled = true
        }
        
        
        
        //DMButtonにタグを設定する
        cell?.DMButton.tag = indexPath.row
        //DMButtonが押された時の処理を設定
        cell?.DMButton.addTarget(self, action: #selector(startDM(_ :)), for: .touchUpInside)
        
        //consulButtonにタグを設定する
        cell?.consulButton.tag = indexPath.row
        //consulButtonが押された時の処理
        cell?.consulButton.addTarget(self, action: #selector(startConsul(_ :)), for: .touchUpInside)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 270
        //可変にする
        return UITableView.automaticDimension
    }
    
    @objc func startDM(_ sender: UIButton) {
        
        //自分のユーザIDを取得
        let uid = self.userId
        //相手のユーザIDを取得
        if self.partnerUids.count != 0 {
            let partnerUid = self.partnerUids[sender.tag].trimmingCharacters(in: .whitespacesAndNewlines)
            //自分と誰が話しているのかを取得
            let members = [uid, partnerUid]
            //partnerUidから相談相手の情報を取得
            //コレクション「chatRoom」のドキュメントに追加する情報を作成
            let docData = ["members": members, "latestMessageId": "", "createdAt": Timestamp()] as [String : Any]
            
            Firestore.firestore().collection("chatRooms").addDocument(data: docData) { (error) in
                //エラー処理
                if let error = error {
                    print("ChatRoom情報の保存に失敗しました。\(error)")
                    return
                }
                print("ChatRoom情報の保存に成功しました。")
            }
        }
    }
    
    @objc func startConsul(_ sender: UIButton) {
        let calendarViewController = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as! CalendarViewController
        calendarViewController.modalPresentationStyle = .fullScreen
        calendarViewController.userId = self.userId
        calendarViewController.userName = self.userName
        calendarViewController.partnerId = self.partnerUids[sender.tag].trimmingCharacters(in: .whitespacesAndNewlines)
        calendarViewController.partnerName = self.dataSets[sender.tag].name
        self.present(calendarViewController, animated: true, completion: nil)
    }
    
    //TextView以外がの部分をタッチした時のアクション
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //キーボードを閉じる
        self.view.endEditing(true)
    }
    
    
    
}
