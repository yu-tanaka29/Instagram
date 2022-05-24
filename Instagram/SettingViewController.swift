//
//  SettingViewController.swift
//  Instagram
//
//  Created by 田中 勇輝 on 2022/05/11.
//

import UIKit
import Firebase
import SVProgressHUD

class SettingViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var displayNameTextField: UITextField!
    
    // MARK: - メンバ変数
    var oldName: String = ""
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 現在登録している表示名を取得して、TextFieldに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            self.displayNameTextField.text = user.displayName
            self.oldName = user.displayName!
        }
    }
    
    // MARK: - IBAction
    /// 表示名変更ボタンをタップしたときに呼ばれるメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func handleChangeButton(_ sender: UIButton) {
        if let displayName = self.displayNameTextField.text { // アンラップ

            // 表示名が入力されていない時はHUDを出して何もしない
            if displayName.isEmpty {
                SVProgressHUD.showError(withStatus: "表示名を入力して下さい")
                return
            }
            
            // 表示名を設定する
            let user = Auth.auth().currentUser
            if let user = user {
                let changeRequest = user.createProfileChangeRequest() // 変更リクエストのインスタンス生成
                changeRequest.displayName = displayName // リクエスト内容登録
                changeRequest.commitChanges { error in // リクエスト送信
                    if let error = error {
                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBUG_PRINT: [displayName = \(user.displayName ?? "")]の設定に成功しました。")

                    // HUDで完了を知らせる
                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
                }
                
                // 登録データの変更（投稿関連）
                let postsRef = Firestore.firestore().collection(Const.PostPath)
                postsRef.getDocuments() { (querySnapshot, error) in
                    if let err = error {
                        print("Error getting documents: \(err)")  // エラーハンドリング
                    } else {
                        for document in querySnapshot!.documents {
                            var updateData: [String: Any] = [:]
                            
                            // commentsフィールド内のデータ取得
                            guard let comments: [[String : Any]] = document.get("comments") as? [[String : Any]] else {
                                // コメントフィールドがない場合(コメントが0の場合)
                                // 以前投稿したものの投稿者名変更
                                if document.get("name") as! String == self.oldName {
                                    updateData = ["name": displayName]
                                    
                                    let ref = Firestore.firestore().collection(Const.PostPath).document(document.documentID)
                                    ref.updateData(updateData)
                                }
                                continue
                            }
                            
                            var changeComment: [[String: Any]] = [] // 名前変更後のコメント一覧格納用配列
                            // コメントを全て取得し、以前投稿したコメントの名前を変更する
                            for comment in comments {
                                if comment["name"] as! String == self.oldName { // コメントが自分の場合
                                    changeComment.append(["name": displayName, "comment": comment["comment"]!])
                                } else { // コメントが他の人の場合
                                    changeComment.append(comment) // 配列に格納
                                }
                            }
                            
            
                            if document.get("name") as! String == self.oldName { // 投稿者が自分の場合
                                updateData = [
                                    "name": displayName,
                                    "comments": changeComment
                                ]
                            } else { // 投稿者が他の人の場合
                                updateData = [
                                    "comments": changeComment
                                ]
                            }
                            let ref = Firestore.firestore().collection(Const.PostPath).document(document.documentID)
                            ref.updateData(updateData) // 更新依頼
                        }
                    }
                }
            }
        }
        
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    /// ログアウトボタンをタップしたときに呼ばれるメソッド
    /// - Parameter sender: UIButton
    @IBAction func handleLogoutButton(_ sender: UIButton) {
        // ログアウトする
        try! Auth.auth().signOut()

        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        // ログイン画面遷移
        self.present(loginViewController!, animated: true, completion: nil)

        // ログイン画面から戻ってきた時のためにホーム画面（index = 0）を選択している状態にしておく
        tabBarController?.selectedIndex = 0
    }
    
    
}
