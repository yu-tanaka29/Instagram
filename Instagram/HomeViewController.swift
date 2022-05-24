//
//  HomeViewController.swift
//  Instagram
//
//  Created by 田中 勇輝 on 2022/05/11.
//

import UIKit
import Firebase

struct Comment {
    var name: String
    var comment: String
}

class HomeViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - メンバ変数
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    // Firestoreのリスナーの定義
    var listener: ListenerRegistration?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
            // listenerを登録して投稿データの更新を監視する
            // 最初はデータを全て読み込み、その後はFirestoreの更新を監視し、更新があるたびに実行
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true) // 情報を取得する場所を決定
            self.listener = postsRef.addSnapshotListener() { (querySnapshot, error) in // 情報取得
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.postArray = querySnapshot!.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let postData = PostData(document: document)
                    return postData
                }
                // TableViewの表示を更新する
                self.tableView.reloadData()
                
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("DEBUG_PRINT: viewWillDisappear")
        // listenerを削除して監視を停止する
        self.listener?.remove()
    }
    
    // MARK: - Private Methods
    
    /// セル内のボタンがタップされた時に呼ばれるメソッド
    ///
    /// - Parameters:
    ///   - sender: UIButton
    ///   - event: UIEvent : タップ
    @objc private func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first // タッチイベント取得
        let point = touch!.location(in: self.tableView) // タッチの位置取得
        let indexPath = self.tableView.indexPathForRow(at: point) // 位置に対するインデックス取得

        // 配列からタップされたインデックスのデータを取り出す
        let postData = self.postArray[indexPath!.row]
        
        // 自分のユーザーID取得
        if let myid = Auth.auth().currentUser?.uid {
            
            // ボタンのタグによって処理分岐
            switch sender.tag {
                // likeボタンが押された場合
                case 1:
                    print("DEBUG_PRINT: likeボタンがタップされました。")
                    // 更新データを作成する
                    var updateValue: FieldValue
                    
                    if postData.isLiked {
                        // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                        updateValue = FieldValue.arrayRemove([myid]) // myid削除してねという指示追加
                    } else {
                        // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                        updateValue = FieldValue.arrayUnion([myid]) // myid追加してねという指示追加
                    }
                    // likesに更新データを書き込む
                    let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id) // 変更カラム取得
                    postRef.updateData(["likes": updateValue]) // 変更依頼送信
                
                // コメント送信ボタンが押された場合
                case 2:
                    print("DEBUG_PRINT: コメント送信ボタンがタップされました。")
                    // 更新データ作成
                    var value: [[String: Any]] = []
                    // インデックスからセル内容を取得
                    let cell = self.tableView.cellForRow(at: indexPath!) as! PostTableViewCell
                    let name = Auth.auth().currentUser?.displayName
                    
                    value = [
                        ["name": name!,
                        "comment": cell.commentField.text!,
                         "date": Timestamp()],
                    ]
                    
                    var updateValue: FieldValue
                    updateValue = FieldValue.arrayUnion(value)
                    
                    // likesに更新データを書き込む
                    let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id) // 変更カラム取得
                    postRef.updateData(["comments": updateValue])// 変更依頼送信
                    
                    cell.commentField.text = ""
                
                // コメント一覧が押された場合
                case 3:
                    print("DEBUG_PRINT: コメント一覧ボタンがタップされました。")
                    // 投稿画面を開く
                    let commentListViewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentListViewController") as! CommentListViewController
                
                    // 投稿画面に遷移
                    commentListViewController.name = postData.name! // 投稿者の名前
                    commentListViewController.caption = postData.caption! // 投稿文
                    commentListViewController.comments = postData.comments // コメント内容
                    self.present(commentListViewController, animated: true, completion: nil) // 遷移
                
                default:
                    return
            }
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// セクション数を設定
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - section: セクション情報
    /// - Returns: セクション数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postArray.count
    }

    /// 各セルの情報を設定
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: セクション情報およびセル番号情報
    /// - Returns: セル
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(self.postArray[indexPath.row])
        
        // セル作成時はコメントボタンを送信できなくする
        cell.sendCommentButton.isEnabled = false
        cell.sendCommentButton.tintColor = .gray
        
        // セル内のボタンのアクションをソースコードで設定する
        // addTarget内引数(1:自分自身（HomeViewController）を呼び出し対象 , 2:#selectorで飛び出すメソッドを指定)
        // for: UIイベント指定
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.sendCommentButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.detailButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }
}

