//
//  PostViewController.swift
//  Instagram
//
//  Created by 田中 勇輝 on 2022/05/11.
//

import UIKit
import Firebase
import SVProgressHUD

class PostViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - メンバ変数
    var image: UIImage!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 受け取った画像をImageViewに設定する
        self.imageView.image = self.image
    }
    
    // MARK: - IBAction
    /// 投稿ボタンをタップしたときに呼ばれるメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func handlePostButton(_ sender: UIButton) {
        // 画像をJPEG形式に変換する(1.0が1番画質高く、0が1番低い)
        let imageData = self.image.jpegData(compressionQuality: 0.75)
        // 画像と投稿データの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document() // 投稿場所
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg") // 画像保存場所
        
        // HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        
        // Storageに画像をアップロードする
        // 参考記事(https://qiita.com/yuji_azama/items/e080ef8b0777cdf53fcb)
        let metadata = StorageMetadata() // タイプを決定したりプレビューを表示できるようにする
        metadata.contentType = "image/jpeg"
        if let imageData = imageData {
            imageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                if let error = error {
                    // 画像のアップロード失敗
                    print(error)
                    SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                    // 投稿処理をキャンセルし、先頭画面に戻る(アプリ起動時、最初に表示されるViewController)
                   self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    return
                }
                // FireStoreに投稿データを保存する
                let name = Auth.auth().currentUser?.displayName
                let postDic = [
                    "name": name ?? "", // 表示名
                    "caption": self.textField.text ?? "", // 投稿文章
                    "date": FieldValue.serverTimestamp(), // 投稿時刻
                    ] as [String : Any]
                postRef.setData(postDic)
                // HUDで投稿完了を表示する
                SVProgressHUD.showSuccess(withStatus: "投稿しました")
                // 投稿処理が完了したので先頭画面に戻る(アプリ起動時、最初に表示されるViewController)
              self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /// キャンセルボタンをタップしたときに呼ばれるメソッド
    /// - Parameter sender: UIButton
    @IBAction func handleCancelButton(_ sender: UIButton) {
    }
}
