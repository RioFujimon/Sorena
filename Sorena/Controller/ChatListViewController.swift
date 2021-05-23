//
//  ChatListViewController.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/02/03.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Nuke

class ChatListViewController: UIViewController{
    let cellId = "cellId"
    var userId = String()
    var userName = String()
    var userEmail = String()
    var userProfileUrl = String()
    private var chatrooms = [ChatRoom]()
    private var user: User?
    
    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatListTableView.tableFooterView = UIView()

        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        
        fetchLoginUserInfo()
        
        //ユーザの情報を引っ張ってくる関数を記述
        fetchChatroomsInfoFromFirestore()
    }
    
    //コレクション「chatRooms」からチャット情報を取得するメソッド(Sorenaに重要)
    private func fetchChatroomsInfoFromFirestore(){
        Firestore.firestore().collection("chatRooms")
            .addSnapshotListener { (snapshots, error) in
            //エラー処理
            if let error = error {
                print("ChatRoom情報の取得に失敗しました。\(error)")
                return
            }
                
                snapshots?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                    case .modified, .removed:
                        print("nothing to do")
                    }
                })
            }
    }
    
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        
        let dic = documentChange.document.data()
        let chatroom = ChatRoom(dic: dic)
        //ログインしているユーザのuidを取得
        let uid = self.userId
        
        chatroom.documentId = documentChange.document.documentID
        
        chatroom.members.forEach { (memberUid) in
            if uid != memberUid {
                Firestore.firestore().collection("RegisterdUsers").document(memberUid).getDocument { (snapshot, error) in
                    
                    if let error = error {
                        print("ユーザ情報の取得に失敗しました。\(error)")
                        return
                    }
                    
                    guard let dic = snapshot?.data() else {return}
                    let user = User(dic: dic)
                    user.uid = documentChange.document.documentID.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    
                    guard let chatroomId = chatroom.documentId else {return}
                    let latestMessageId = chatroom.latestMessageId
                    chatroom.partnerUser = user
                    
                    if latestMessageId == "" {
                        self.chatrooms.append(chatroom)
                        self.chatListTableView.reloadData()
                        return
                    }
                    
                    Firestore.firestore().collection("chatRooms").document(chatroom.documentId ?? "").collection("messages").document(latestMessageId).getDocument { (snapshot, err) in
                        
                        if let err = err {
                            print("最新情報の取得に失敗しました。\(err)")
                            return
                        }
                        
                        guard let dic = snapshot?.data() else {return}
                        let message = Message(dic: dic)
                        chatroom.latestMessage = message
                        
                        self.chatrooms.append(chatroom)
                        self.chatListTableView.reloadData()
                        
                    }
                }
            }
        }
    }
    
    
    private func fetchLoginUserInfo() {
        
        Firestore.firestore().collection("RegisterdUsers").document(self.userId).getDocument { (snapshot, error) in
            if let error = error {
                print("ユーザ情報の取得に失敗しました。\(error)")
                return
            }
            
            guard let snapshot = snapshot, let  dic = snapshot.data() else {return}
            let user = User(dic: dic)
            self.user = user
        }
        
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! ChatListTableViewCell
        
        cell.chatroom = chatrooms[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatRoomViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewController") as! ChatRoomViewController
        chatRoomViewController.user = user
        chatRoomViewController.chatroom = chatrooms[indexPath.row]
        chatRoomViewController.userId = self.userId
        self.present(chatRoomViewController, animated: true, completion: nil)
    }
}

class ChatListTableViewCell: UITableViewCell {
    var chatroom: ChatRoom? {
        didSet {
            if let chatroom = chatroom {
                partnerLabel.text = chatroom.partnerUser?.username
                guard let url = URL(string: chatroom.partnerUser?.profileImageUrl ?? "") else {return}
                Nuke.loadImage(with: url, into: userImageView)
                
                dateLabel.text = dateFormatterForDateLabel(date: chatroom.latestMessage?.createdAt.dateValue() ?? Date())
                latestMessageLabel.text = chatroom.latestMessage?.message
            }
        }
    }
    
    
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 30
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func dateFormatterForDateLabel(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
}
