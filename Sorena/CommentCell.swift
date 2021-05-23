//
//  CommentCell.swift
//  Sorena
//
//  Created by 藤門莉生 on 2021/01/26.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var uiImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderColor = UIColor.orange.cgColor
        self.layer.borderWidth = 0.5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
