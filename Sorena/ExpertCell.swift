//
//  ExpertCell.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/02/02.
//

import UIKit

class ExpertCell: UITableViewCell {

    //プロフィール画像を貼り付けるView
    @IBOutlet weak var profileImageView: UIImageView!
    //名前用のラベル
    @IBOutlet weak var nameLabel: UILabel!
    //プロフィールの詳細用のラベル
    @IBOutlet weak var detailLabel: UILabel!
    //DM用のボタン
    @IBOutlet weak var DMButton: UIButton!
    //相談用のボタン
    @IBOutlet weak var consulButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderColor = UIColor.orange.cgColor
        self.layer.borderWidth = 0.5
        DMButton.layer.cornerRadius = 10
        consulButton.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
