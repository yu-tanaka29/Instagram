//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by 田中 勇輝 on 2022/05/13.
//

import UIKit
import FirebaseStorageUI

class PostTableViewCell: UITableViewCell {

    // MARK: - IBOutlet
    @IBOutlet weak var postImageView:  UIImageView! // 画像
    @IBOutlet weak var likeButton: UIButton! // いいねボタン
    @IBOutlet weak var likeLabel: UILabel! // いいね数
    @IBOutlet weak var dateLabel: UILabel! // 日付
    @IBOutlet weak var captionLabel: UILabel! // 内容
    @IBOutlet weak var commentField: UITextField! // コメント入力欄
    @IBOutlet weak var sendCommentButton: UIButton! // コメント送信ボタン
    @IBOutlet weak var commentStackview: UIStackView! // コメント一覧
    @IBOutlet weak var numCommentLabel: UILabel! // コメント数
    @IBOutlet weak var detailButton: UIButton! // コメント一覧画面へ遷移ボタン
    @IBOutlet weak var detailButtonConstraint: NSLayoutConstraint! // detailButtonの高さ
    
    // MARK: - Life Cycle
    // xibファイルが読み込まれたあとに実行
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.commentField.delegate = self
        // commentFieldに入力されるたびにtextFieldDidChangeメソッドを呼ぶ
        self.commentField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    /// 画面タップでキーボードを閉じる
    ///
    /// - Parameters:
    ///   - touches: Set<UITouch>
    ///   - event: タップ
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.commentField.resignFirstResponder()
    }
    
    // MARK: - Private Methods
    /// PostDataの内容をセルに表示
    /// 
    /// - Parameter postData: PostData
    func setPostData(_ postData: PostData) {
        // 画像の表示
        // Cloud Storageから画像をダウンロードしている間、ダウンロード中であることを示すインジケーターを表示する指定
        // ぐるぐる回るようなやつ
        self.postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        // 取ってくる画像の場所を指定
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        // 画像をダウンロードして表示(sd_setimage)
        self.postImageView.sd_setImage(with: imageRef)

        // キャプションの表示
        if let name = postData.name , let caption = postData.caption { // アンラップ
            if caption.isEmpty {
                self.captionLabel.text = name
            } else {
                self.captionLabel.text = "\(name) : \(caption)"
            }
        }

        // 日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter() // フォーマットのインスタンス生成
            formatter.dateFormat = "yyyy/MM/dd HH:mm" // フォーマット指定
            let dateString = formatter.string(from: date) // 変更
            self.dateLabel.text = dateString
        }
    
        // いいね数の表示
        let likeNumber = postData.likes.count
        self.likeLabel.text = "\(likeNumber)"

        // いいねボタンの表示
        if postData.isLiked {
            // いいねを押している場合
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            // いいねを押していない場合
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        // コメント数表示
        self.numCommentLabel.text = "\(postData.comments.count) 件"
        
        // コメント一覧画面のボタンの非表示
        if postData.comments.count < 3 {
            self.detailButton.isHidden = true
        } else {
            self.detailButton.isHidden = false
        }
        
        // コメント内容表示
        if self.commentStackview.arrangedSubviews.count != 0 {
            for _ in 0 ..< self.commentStackview.arrangedSubviews.count {
                self.commentStackview.arrangedSubviews[0].removeFromSuperview()
            }
        }
        
        if postData.comments.count != 0 {
            postData.comments.reverse()
            for i in 0 ..< postData.comments.count {
                if i < 2 {
                    let commentLabel = UILabel()
                    commentLabel.text = "\(postData.comments[i]["name"]!) : \(postData.comments[i]["comment"]!)"
                    
                    commentLabel.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
                    commentLabel.translatesAutoresizingMaskIntoConstraints = false
                    commentLabel.font = UIFont.systemFont(ofSize: 15)
                    self.commentStackview.addArrangedSubview(commentLabel)
                }  else {
                    break
                }
            }
        }
    }
    
    /// commntFieldの入力チェック
    /// - Parameter sender: UITextField
    @objc func textFieldDidChange(sender: UITextField) {
        if let comment = self.commentField.text {
            if comment.isEmpty {
                // commntFieldに値がなければ送信ボタン(sendCommentButton)を押せなくする
                self.sendCommentButton.isEnabled = false
                self.sendCommentButton.tintColor = .gray
            } else {
                // commntFieldに値があれば送信ボタン(sendCommentButton)を押せるようにする
                self.sendCommentButton.isEnabled = true
                self.sendCommentButton.tintColor = .systemBlue
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension PostTableViewCell: UITextFieldDelegate {
    /// returnキーが押されたときにキーボードを閉じる
    ///
    /// - Parameter textField: UItextField
    /// - Returns: true
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
}
