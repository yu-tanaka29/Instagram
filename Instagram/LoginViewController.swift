//
//  LoginViewController.swift
//  Instagram
//
//  Created by 田中 勇輝 on 2022/05/11.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
// MARK: - IBOutlet
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var addAcountButton: UIButton!
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mailAddressTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        displayNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        loginButton.isEnabled = false
        addAcountButton.isEnabled = false
    }
    
    // MARK: - IBAction
    
    /// ログインボタンをタップしたときに呼ばれるメソッド
    /// 
    /// - Parameter sender: UIButton
    @IBAction func handleLoginButton(_ sender: UIButton) {
        // アンラップできた = 箱がある
        if let address = self.mailAddressTextField.text, let password = self.passwordTextField.text {
            // HUDで処理中を表示
            SVProgressHUD.show()

            Auth.auth().signIn(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
                
                // HUDを消す
                SVProgressHUD.dismiss()

                // 画面を閉じてタブ画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    /// アカウント作成ボタンをタップしたときに呼ばれるメソッド
    ///
    /// - Parameter sender: UIButton
    @IBAction func handleCreateAccountButton(_ sender: UIButton) {
        if let address = self.mailAddressTextField.text, let password = self.passwordTextField.text, let displayName = self.displayNameTextField.text {
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            Auth.auth().createUser(withEmail: address, password: password) { authResult, error in
                if let error = error {
                    // エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                // 表示名を設定する
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest() // リクエスト作成
                    changeRequest.displayName = displayName // リクエスト内容を入れる
                    changeRequest.commitChanges { error in // リクエスト送信
                        if let error = error {
                            // プロフィールの更新でエラーが発生
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました。")
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                        
                        // HUDを消す
                        SVProgressHUD.dismiss()

                        // 画面を閉じてタブ画面に戻る
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    @objc private func textFieldDidChange(sender: UITextField) {
        // ログインの入力チェック
        if let address = self.mailAddressTextField.text, let password = self.passwordTextField.text {

            // アドレスとパスワード6文字以上入力されていない場合はボタンを押せなくする
            if !address.isEmpty && password.count >= 6 {
                loginButton.isEnabled = true
            } else {
                loginButton.isEnabled = false
            }
        }
        
        // アカウント作成の入力チェック
        if let address = self.mailAddressTextField.text, let password = self.passwordTextField.text, let displayName = self.displayNameTextField.text {
            
            // // アドレスとパスワード6文字以上と表示名が入力されていない場合はボタンを押せなくする
            if !address.isEmpty && password.count >= 6 && !displayName.isEmpty {
                addAcountButton.isEnabled = true
            } else {
                addAcountButton.isEnabled = false
            }
        }
    }
}
