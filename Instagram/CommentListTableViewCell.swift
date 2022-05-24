//
//  CommentListTableViewCell.swift
//  Instagram
//
//  Created by 田中 勇輝 on 2022/05/24.
//

import UIKit

class CommentListTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
