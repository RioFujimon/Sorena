//
//  ChatRoom.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/02/05.
//

import Foundation
import FirebaseFirestore

class ChatRoom {
    
    let latestMessageId: String
    let members: [String]
    let createdAt: Timestamp
    
    var latestMessage: Message?
    var documentId: String?
    var partnerUser: User?
    
    
    init(dic: [String: Any]) {
        self.latestMessageId = dic["latestMessageId"] as? String ?? ""
        self.members = dic["members"] as? [String] ?? [String]()
        self.createdAt = dic as? Timestamp ?? Timestamp()
    }
}
