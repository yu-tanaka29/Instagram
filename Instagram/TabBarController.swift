//
//  TabBarController.swift
//  Instagram
//
//  Created by 田中 勇輝 on 2022/05/11.
//

import UIKit
import Firebase // 先頭でFirebaseをimportしておく

class TabBarController: UITabBarController {

// MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // タブアイコンの色
        self.tabBar.tintColor = UIColor(red: 1.0, green: 0.44, blue: 0.11, alpha: 1)
        
        // タブバーの背景色を設定
        let appearance = UITabBarAppearance() // NavigationBarの外観設定を司るクラスのインスタンス生成
        appearance.backgroundColor = UIColor(red: 0.96, green: 0.91, blue: 0.87, alpha: 1) // 色を設定
        self.tabBar.standardAppearance = appearance // 通常のNavigationBarの外観設定
        self.tabBar.scrollEdgeAppearance = appearance // 画面のスクロール中とスクロールが終端に達した時の設定
        
        // UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理する。
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // currentUserがnilならログインしていない
        if Auth.auth().currentUser == nil {
            // ログインしていないときの処理
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            // ログイン画面遷移
            self.present(loginViewController!, animated: true, completion: nil)
            // completionはコールバック(遷移後に行いたい関数があれば指定)
        }
    }
}
    

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    /// タブバーのアイコンがタップされた時に呼ばれるdelegateメソッドを処理
    ///
    /// - Parameters:
    ///   - tabBarController: UITabBarController
    ///   - viewController: UIViewController
    /// - Returns: true or false (trueならtabBarを用いて画面切り替えを行う)
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is ImageSelectViewController {
            // ImageSelectViewControllerは、タブ切り替えではなくモーダル画面遷移する
            let imageSelectViewController = storyboard!.instantiateViewController(withIdentifier: "ImageSelect") // Storyboardに定義されている ImageSelectViewControllerを読み込む
            present(imageSelectViewController, animated: true) // 画面遷移
            return false // falseにするとタブで切り替わらなくなる
        } else {
            // その他のViewControllerは通常のタブ切り替えを実施
            return true
        }
    }
}
