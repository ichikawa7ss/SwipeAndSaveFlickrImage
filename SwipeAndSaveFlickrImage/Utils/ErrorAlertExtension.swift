//
//  ErrorAlertExtension.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/14.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
        
    /// エラーメッセージ表示用エクステンション
    /// - Parameter title: エラーメッセージ
    /// - Parameter completionDo: 完了ハンドラ
    func showOkAlert (title : String, completionDo:@escaping () -> ()) {
        let alert: UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: UIAlertController.Style.alert)
        let reserve: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            
            completionDo()
            
            return
        })
        alert.addAction(reserve)
        self.present(alert, animated: true, completion: nil)
    }
    
    /// メッセージとOKボタンのアラート文を表示
    func showOkAlert (title : String) {
        showOkAlert(title: title) {
        }
    }
    
    
    /// 画像保存確認のアラートを表示
    /// - Parameter completion:
    func showAlertForPhotoSave(completion: @escaping () -> ()) {
        let alertController = UIAlertController(title: "iPhoneへの保存", message: "この画像をiPhoneへ保存しますか？", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            /// OKが選択されればアルバムに画像を保存し、アラートの表示設定について確認
            completion()
        }

        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (cancel) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    /// 保存時のアラート省略を促す
    func showOmitAlert() {
        /// 画像の保存に成功
        let alert = UIAlertController(title: "今後はアラートを非表示にしますか？", message: "非表示にするとよりスムーズに画像の管理ができます", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
            /// 非表示希望者にはユーザデフォルトでフラグを立てる
            UserDefaults.standard.set(1, forKey: "omitConfirmationFlg")
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (cancel) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        //OKとCANCELを表示追加し、アラートを表示
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// 画像保存失敗時のアラートを表示
    func showAlertForSaveImageFailuer() {
        /// 画像の保存に失敗
        let alert = UIAlertController(title: "写真を保存できませんでした", message: "設定から「写真」へのアクセスを許可してください", preferredStyle: .alert)
        // OKボタンを追加
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        // UIAlertController を表示
        self.present(alert, animated: true, completion: nil)
    }
}



