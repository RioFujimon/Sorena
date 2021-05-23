//
//  PostCell.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/01/21.
//

import UIKit

class PostCell: UITableViewCell {

    //プロフィール画像を扱う変数
    @IBOutlet weak var profileImageView: UIImageView!
    //ユーザ名用のラベルを扱う変数
    @IBOutlet weak var userNameLabel: UILabel!
    //投稿日用のラベルを扱う変数
    @IBOutlet weak var dateLabel: UILabel!
    //ミスの投稿内容用のラベルを扱う変数
    @IBOutlet weak var mistakeLabel: UILabel!
    //likeボタン用の変数
    @IBOutlet weak var likeButton: UIButton!
    //いいね数を表示するための変数
    @IBOutlet weak var likeCountLabel: UILabel!
    //ハートボタン用の変数
    @IBOutlet weak var heartButton: UIButton!
    //ハート数をカウントするための変数
    @IBOutlet weak var heartCountLabel: UILabel!
    //共感ボタンを扱うための変数
    @IBOutlet weak var empathyButton: UIButton!
    //共感数を扱うラベルのための変数
    @IBOutlet weak var empathyCountLabel: UILabel!
    //ファイトボタンを扱うための変数
    @IBOutlet weak var fightButton: UIButton!
    //ファイト数を表示するための変数
    @IBOutlet weak var fightCountLabel: UILabel!
    //コメントを書き込む画面に遷移するためのボタン
    @IBOutlet weak var commentButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.borderWidth = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
