//
//  CommentListViewController.swift
//  Instagram
//
//  Created by 田中 勇輝 on 2022/05/23.
//

import UIKit
import Firebase

class CommentListViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - メンバ変数
    var name: String = "" // 投稿者名
    var caption: String = "" // 投稿文
    var comments: [[String: Any]] = [] // コメント内容
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // カスタムセルを登録する
        let nib = UINib(nibName: "CommentListTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CommentCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 投稿者名と投稿文表示
        self.postLabel.text = "\(self.name) : \(self.caption)"
    }
    
    // MARK: - IBAction
    /// コメント一覧から投稿一覧へ戻る
    /// 
    /// - Parameter sender: UIButton
    @IBAction func backButton(_ sender: UIButton) {
        // CommentListViewControllerを閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension CommentListViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// セクション数を設定
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - section: セクション情報
    /// - Returns: セクション数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.comments.count
    }
    
    /// 各セルの情報を設定
    ///
    /// - Parameters:
    ///   - tableView: UITableView
    ///   - indexPath: セクション情報およびセル番号情報
    /// - Returns: セル
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentListTableViewCell
        cell.commentLabel.text = "\(self.comments[indexPath.row]["name"] as! String) : \(self.comments[indexPath.row]["comment"] as! String)"
        if let date = self.comments[indexPath.row]["date"] as? Timestamp {
            let formatter = DateFormatter() // フォーマットのインスタンス生成
            formatter.dateFormat = "yyyy/MM/dd HH:mm" // フォーマット指定
            let dateString = formatter.string(from: date.dateValue()) // 変更
            cell.dateLabel.text = dateString
        }
        return cell
    }
    
    
}


