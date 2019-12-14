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
    
    // メッセージとOKボタンのアラート文を表示
    func showOkAlert (title : String) {
        showOkAlert(title: title) {
        }
    }
}



