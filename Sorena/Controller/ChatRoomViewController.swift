//
//  ChatRoomViewController.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/02/03.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChatRoomViewController: UIViewController {
    
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    var user:User?
    private var cellId = "cellId"
    var chatroom: ChatRoom?
    private var messages = [Message]()
    private let accessaryHeight:CGFloat = 100
    var userId = String()
    private let tableViewContentInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private let tableViewIndicatorInset: UIEdgeInsets = .init(top: 60, left: 0, bottom: 0, right: 0)
    private var safeAreaBottom: CGFloat {
        get {
            self.view.safeAreaInsets.bottom
        }
    }
    
    
    private lazy var chatInputAccessaryView: ChatInputAccessaryView = {
        let view = ChatInputAccessaryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessaryHeight)
        
        view.delegate = self
        return view
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        setupChatRoomTableView()
        fetchMessages()
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupChatRoomTableView() {
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        //別ファイルでcellを作成した際に必ずやる
        chatRoomTableView.register(UINib(nibName: "ChatRoomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        chatRoomTableView.backgroundColor = .rgb(red: 255, green: 255, blue: 255)
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
        chatRoomTableView.keyboardDismissMode = .interactive
        chatRoomTableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else {return}
        
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
           
            if keyboardFrame.height <= accessaryHeight {return}
            
            let top = keyboardFrame.height - safeAreaBottom
            var moveY = -(top - chatRoomTableView.contentOffset.y)
            if  chatRoomTableView.contentOffset.y != -60{
                moveY += 60
            }
            let contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
            chatRoomTableView.contentInset = contentInset
            chatRoomTableView.scrollIndicatorInsets = contentInset
            chatRoomTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
    }
    
    @objc func keyboardWillHide() {
        chatRoomTableView.contentInset = tableViewContentInset
        chatRoomTableView.scrollIndicatorInsets = tableViewIndicatorInset
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return chatInputAccessaryView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func fetchMessages() {
        guard let chatroomDocId = chatroom?.documentId else {return}
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").addSnapshotListener { (snapshots, error) in
            
            if let error = error {
                print("メッセージ情報の取得失敗しました。\(error)")
                return
            }
            
            snapshots?.documentChanges.forEach({ (documentChange) in
                switch documentChange.type {
                case .added:
                    let dic = documentChange.document.data()
                    let message = Message(dic: dic)
                    message.partnerUser = self.chatroom?.partnerUser
                    self.messages.append(message)
                    
                    self.messages.sort { (m1, m2) -> Bool in
                        let m1Date = m1.createdAt.dateValue()
                        let m2Date = m2.createdAt.dateValue()
                        return m1Date > m2Date
                    }
                    
                    self.chatRoomTableView.reloadData()
                    
                case .modified, .removed:
                    print("nothing to do")
                }
            })
            
        }
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ChatRoomViewController: ChatInputAccessaryViewDelegate {
    func tappedSendButton(text: String) {
        addMessageToFirestore(text: text)
    }
    
    
    private func addMessageToFirestore(text: String) {
        guard let chatroomDocId = chatroom?.documentId else {return}
        guard let name = user?.username else {return}
        let uid = userId
        chatInputAccessaryView.removeText()
        let messageId = rondomString(length: 20)
        
        let docData = ["name": name, "createdAt": Timestamp(), "uid": uid, "message": text] as [String : Any]
        
        
        Firestore.firestore().collection("chatRooms").document(chatroomDocId).collection("messages").document(messageId).setData(docData) {(error) in
            if let error = error {
                print("メッセージ情報の保存に失敗しました。\(error)")
                return
            }
            
            let latestMessageData = ["latestMessageId": messageId]
            
            Firestore.firestore().collection("chatRooms").document(chatroomDocId).updateData(latestMessageData) { (err) in
                if let error = err {
                    print("最新のメッセージの保存に失敗しました。\(error)")
                    return
                }
            }
            
            print("メッセージの保存に成功しました。")
        }
    }
    
    func rondomString(length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var rondomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            rondomString += NSString(characters: &nextChar, length: 1) as String
        }
        return rondomString
    }
}

extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //最低基準のcellの高さを指定
        chatRoomTableView.estimatedRowHeight = 20
        //cell中のテキストの長さでcellの高さが可変になる
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatRoomTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatRoomTableViewCell
        cell.uid = self.userId
        
        cell.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
        
        cell.message = messages[indexPath.row]
        return cell
    }
    
    
}
