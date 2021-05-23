//
//  PostDataModel.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/01/24.
//

import Foundation

struct PostDataModel {
    //ミスの内容を扱う変数
    let mistake:String
    //ユーザの名前を扱う変数
    let userName:String
    //ドキュメントIDを扱う変数
    let docId:String
    //いいねの数をカウントするための変数
    let likeCount:Int
    //いいねをしたかどうかを判定する変数
    let likeFlagDic:Dictionary<String, Bool>
    //ハートの数をカウントするための変数
    let heartCount:Int
    //ハートを押したかどうかを判定する変数
    let heartFlagDic:Dictionary<String, Bool>
    //わかるの数をカウントするための変数
    let empathyCount:Int
    //わかるをしたかどうかを判定する変数
    let empathyFlagDic:Dictionary<String, Bool>
    //ファイトの数をカウントするための変数
    let fightCount:Int
    //ファイトをしたかどうかを判定する変数
    let fightFlagDic:Dictionary<String, Bool>
    //プロフィール画像のURL
    let profileImageUrl:String
    //投稿した日時
    let postDate: String
}
