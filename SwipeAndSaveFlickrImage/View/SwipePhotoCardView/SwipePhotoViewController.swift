//
//  SwipePhotoViewController.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/15.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import UIKit

final class SwipePhotoViewController: UIViewController {

    public var photos: [Photo]?
    public var currentNum = 0
    
    // カード表示用のViewを格納するための配列
    fileprivate var swipePhotoList: [SwipePhotoCardView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初回は５枚分PhotoCardを追加
        for _ in 1...5  {
            self.addPhotoCardSetViews()
        }
    }
    
    // MARK: - Fileprivate Function
    
    /// 画面上にカードを追加する
    fileprivate func addPhotoCardSetViews() {
        if currentNum >= photos!.count { return }
        
        // photoCardのインスタンス作成・プロトコル宣言・タッチイベントの初期設定を行う
        let photoCardSetView = SwipePhotoCardView()
        photoCardSetView.delegate = (self as SwipePhotoCardViewDelegate)
        photoCardSetView.setViewData(self.photos![currentNum])
        photoCardSetView.isUserInteractionEnabled = false
        
        // 表示用配列に追加
        self.swipePhotoList.append(photoCardSetView)
            
        /// 現在表示されているカードの背面へ新たに作成したカードを追加する
        self.view.addSubview(photoCardSetView)
        self.view.sendSubviewToBack(photoCardSetView)
        
        /// swipePhotoListに格納されているViewのうち、先頭にあるViewのみを操作可能にする
        enableUserInteractionToFirstCardSetView()
        
        /// 画面上にあるカードの山の拡大縮小比を調節する
        changeScaleToCardSetViews(skipSelectedView: false)
        
        // 表示Photoをインクリメント
        currentNum += 1
    }

    /// 画面上にあるカードの山のうち、一番上にあるViewのみを操作できるようにする
    fileprivate func enableUserInteractionToFirstCardSetView() {
        if !swipePhotoList.isEmpty {
            if let firstPhotoCardSetView = swipePhotoList.first {
                firstPhotoCardSetView.isUserInteractionEnabled = true
            }
        }
    }

    /// 現在配列に格納されている(画面上にカードの山として表示されている)Viewの拡大縮小を調節する
    fileprivate func changeScaleToCardSetViews(skipSelectedView: Bool = false) {

        /// アニメーション関連の定数値
        let duration: TimeInterval = 0.26
        let reduceRatio: CGFloat   = 0.1

        var targetCount: CGFloat = 0
        for (targetIndex, photoCardSetView) in swipePhotoList.enumerated() {

            /// 現在操作中のViewの縮小比を変更しない場合は、以降の処理をスキップする
            if skipSelectedView && targetIndex == 0 { continue }

            /// 後ろに配置されているViewほど小さく見えるように縮小比を調節する
            let targetScale: CGFloat = 1 - reduceRatio * targetCount
            UIView.animate(withDuration: duration, animations: {
                photoCardSetView.transform = CGAffineTransform(scaleX: targetScale, y: targetScale)
            })
            targetCount += 1
        }
    }
    
    // MARK: - スワイプ後の処理
    
    // model
    /**
     画像保存する際のアラートを表示
     OKであれば画像を保存する
     画像取得後、希望者にはアラートを非表示にする設定を付与
     :param: targetImage : 保存対象の画像
     */
    fileprivate func saveImage (targetImage: UIImage?) {
        guard let image = targetImage else { return }

        // TODO info.plistの設定追加
        if UserDefaults.standard.object(forKey: "omitConfirmationFlg") == nil {
            /// 非表示希望者以外（初回のユーザ含む）には保存についての確認をアラートで表示
            let alertController = UIAlertController(title: "iPhoneへの保存", message: "この画像をiPhoneへ保存しますか？", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default) { (ok) in
                /// OKが選択されればアルバムに画像を保存し、アラートの表示設定について確認
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.showConfirmOfOmitAlert(_:didFinishSavingWithError:contextInfo:)), nil)
            }

            let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (cancel) in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
        } else {
            /// 非表示希望者はアラートなしで画像を保存
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }
    }
    
    // TODO Utilsへ移動
    /**
     画像保存実行後のアラートを表示する
     保存成功した場合、今後の非表示希望についての確認アラートを表示
     保存失敗時は簡易なアラートを表示
     */
    @objc func showConfirmOfOmitAlert(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {

        if error == nil {
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

        } else {
            /// 画像の保存に失敗
            let alert = UIAlertController(title: "エラー", message: "保存に失敗しました", preferredStyle: .alert)
            // OKボタンを追加
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            // UIAlertController を表示
            self.present(alert, animated: true, completion: nil)
        }
    }

}

// MARK: - PhotoCardSetDelegate

extension SwipePhotoViewController: SwipePhotoCardViewDelegate {
    /// ドラッグ処理が開始された際にViewController側で実行する処理
    func cardViewDidBeginDragging(_ cardView: SwipePhotoCardView) {
        changeScaleToCardSetViews(skipSelectedView: true)
    }
    /// ドラッグ処理中に位置情報が更新された際にViewController側で実行する処理
    func cardViewDidUpdatePosition(_ cardView: SwipePhotoCardView, centerX: CGFloat, centerY: CGFloat) {
    }
    /// 左方向へのスワイプが完了した際にViewController側で実行する処理
    func cardViewDidSwipeLeftPosition(_ cardView: SwipePhotoCardView) {
        self.addPhotoCardSetViews()
        swipePhotoList.removeFirst()
        enableUserInteractionToFirstCardSetView()
        changeScaleToCardSetViews(skipSelectedView: false)
    }
    /// 右方向へのスワイプが完了した際にViewController側で実行する処理
    func cardViewDidSwipeRightPosition(_ cardView: SwipePhotoCardView) {
        saveImage(targetImage: cardView.photoImageView.image)
        self.addPhotoCardSetViews()
        swipePhotoList.removeFirst()
        enableUserInteractionToFirstCardSetView()
        changeScaleToCardSetViews(skipSelectedView: false)
    }
    /// 元の位置へ戻った際にViewController側で実行する処理
    func cardViewDidReturnToOriginalPosition(_ cardView: SwipePhotoCardView) {
        changeScaleToCardSetViews(skipSelectedView: false)
    }
}


