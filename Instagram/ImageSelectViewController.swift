//
//  ImageSelectViewController.swift
//  Instagram
//
//  Created by 田中 勇輝 on 2022/05/11.
//

import UIKit
import CLImageEditor

class ImageSelectViewController: UIViewController {

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBAction
    @IBAction func handleLibraryButton(_ sender: Any) {
        // ライブラリ（カメラロール）を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) { // 利用可能かどうかを確かめるメソッド
            let pickerController = UIImagePickerController() // インスタンス生成
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary // 移動先をフォトライブラリに指定
            self.present(pickerController, animated: true, completion: nil) // 画面遷移
        }
    }
    
    @IBAction func handleCameraButton(_ sender: Any) {
        // カメラを指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.camera) { // 利用可能かどうかを確かめるメソッド
            let pickerController = UIImagePickerController() // インスタンス生成
            pickerController.delegate = self
            pickerController.sourceType = .camera // 移動先をカメラに指定
            self.present(pickerController, animated: true, completion: nil) // 画面遷移
        }
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ImageSelectViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// 写真を撮影/選択したときに呼ばれるメソッド
    ///
    /// - Parameters:
    ///   - picker: UIImagePickerController
    ///   - info: [UIImagePickerController.InfoKey : Any]
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
        // 画像加工処理(info[.originalImage]に撮影/選択した画像が入っている)
        // 省略せず書くと、info[UIImagePickerController.InfoKey.originalImage]に入っている
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage
            // あとでCLImageEditorライブラリで加工する
            print("DEBUG_PRINT: image = \(image)")
            let editor = CLImageEditor(image: image)! // 確実に画像は取得しているため強制アンラップOK？
            editor.delegate = self
            self.present(editor, animated: true, completion: nil)
        }
    }
    
    /// キャンセルボタンが押されたときに呼ばれるメソッド
    ///
    /// - Parameter picker: UIImagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // UIImagePickerController画面を閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - CLImageEditorDelegate
extension ImageSelectViewController: CLImageEditorDelegate {
    /// CLImageEditorで加工が終わったときに呼ばれるメソッド
    ///
    /// - Parameters:
    ///   - editor: CLImageEditor
    ///   - image: UIImage
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        // 投稿画面を開く
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
        // postViewControllerのimageプロパティに画像を代入
        postViewController.image = image! // ここも確実に画像は取得しているため強制アンラップOK？
        // 投稿画面に遷移
        editor.present(postViewController, animated: true, completion: nil)
    }
    
    /// CLImageEditorの編集がキャンセルされた時に呼ばれるメソッド
    ///
    /// - Parameter editor: CLImageEditor
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        // CLImageEditor画面を閉じる
        editor.dismiss(animated: true, completion: nil)
    }
}
