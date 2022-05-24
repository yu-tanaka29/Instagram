//
//  PostData.swift
//  Instagram
//
//  Created by 田中 勇輝 on 2022/05/13.
//

import UIKit
import Firebase

class PostData: NSObject {
    var id: String
    var name: String?
    var caption: String?
    var date: Date?
    var likes: [String] = []
    var comments: [[String: Any]] = []
    var isLiked: Bool = false
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID

        let postDic = document.data()

        self.name = postDic["name"] as? String // 名前

        self.caption = postDic["caption"] as? String // 本文

        let timestamp = postDic["date"] as? Timestamp // 日付
        self.date = timestamp?.dateValue() // Date型に変更

        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        
        if let comments = postDic["comments"] as? [[String: Any]] {
            self.comments = comments
        }
        
        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil { // 配列の先頭から要素を検索・インデックス取得
                // myidがあれば、いいねを押していると認識する。
                self.isLiked = true
            }
        }
    }
}
