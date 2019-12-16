//
//  SwipePhotoCardView.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/15.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import UIKit


/// Swipeでの動きに応じた動きをデリゲートパターンで実装
protocol SwipePhotoCardViewDelegate : NSObjectProtocol{
    /// ドラッグ開始時に実行されるアクション
    func cardViewDidBeginDragging(_ cardView: SwipePhotoCardView)
    /// 位置の変化が生じた際に実行されるアクション
    func cardViewDidUpdatePosition(_ cardView: SwipePhotoCardView,  centerX: CGFloat, centerY: CGFloat)
    /// 左側へのスワイプ動作が完了した場合に実行されるアクション
    func cardViewDidSwipeLeftPosition(_ cardView: SwipePhotoCardView)
    /// 右側へのスワイプ動作が完了した場合に実行されるアクション
    func cardViewDidSwipeRightPosition(_ cardView: SwipePhotoCardView)
    /// 元の位置に戻る動作が完了したに実行されるアクション
    func cardViewDidReturnToOriginalPosition(_ cardView: SwipePhotoCardView)
}

class SwipePhotoCardView: UIView {

    @IBOutlet weak var photoImageView: UIImageView!
    
    /// ドラッグ処理開始時のViewがある位置を格納する変数
    private var originalPoint: CGPoint = CGPoint.zero
    
    /// 中心位置からのX軸＆Y軸方向の位置を格納する変数
    private var xPositionFromCenter: CGFloat = 0.0
    private var yPositionFromCenter: CGFloat = 0.0

    /// 中心位置からのX軸方向へ何パーセント移動したか（移動割合）を格納する変数
    private var currentMoveXPercentFromCenter: CGFloat = 0.0
    private var currentMoveYPercentFromCenter: CGFloat = 0.0

    /// Viewの初期状態の傾きを決める変数(意図的に揺らぎを与えてランダムで少しずらす)
    private var initialTransform: CGAffineTransform = .identity

    /// PhotoCardSetDelegateのインスタンス宣言
    weak var delegate: SwipePhotoCardViewDelegate?
    
    /// Viewの初期状態の中心点を決める変数(意図的に揺らぎを与えてランダムで少しずらす)
    private var initialCenter: CGPoint = CGPoint(
        x: UIScreen.main.bounds.size.width / 2,
        y: UIScreen.main.bounds.size.height / 2
    )
    
    // 実行表示時間
    private let durationOfInitialize: TimeInterval = 0.93
    private let durationOfStartDragging: TimeInterval = 0.26
    private let durationOfReturnOriginal: TimeInterval = 0.26
    private let durationOfSwipeOut: TimeInterval = 0.48
    
    // 透明度
    private let startDraggingAlpha: CGFloat = 0.98
    private let stopDraggingAlpha: CGFloat = 1.00

    // カードの拡大縮小比率
    private let maxScaleOfDragging: CGFloat = 1.00

    // ドラッグ終了時にカードをリリースするポイントの割合
    private let swipeXPosLimitRatio: CGFloat = 0.4
    private let swipeYPosLimitRatio: CGFloat = 0.02
    
        // 初期化表示前の拡大縮小比
    private let beforeInitializeScale: CGFloat = 1.00
    private let afterInitializeScale: CGFloat  = 1.00
    
    /// このカスタムビューをコードで使用する際の初期化処理
    required override init(frame: CGRect) {
        super.init(frame: frame)
        initContentView()
        setupPhotoCardSetView()
        setupPanGestureRecognizer()
    }

    /// このカスタムビューをInterfaceBuilderで使用する際の初期化処理
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initContentView()
        setupPhotoCardSetView()
        setupPanGestureRecognizer()
    }
    
    /// コンテンツ表示用Viewの初期化処理
    private func initContentView() {

        /// コンテンツ表示用のView
        weak var contentView: UIView!

        /// 追加するcontentViewのクラス名を取得する
        let viewClass: AnyClass = type(of: self)

        /// 追加するcontentViewに関する設定をする
        contentView = Bundle(for: viewClass).loadNibNamed(String(describing: viewClass), owner: self, options: nil)?.first as? UIView

        contentView.autoresizingMask = autoresizingMask
        contentView.frame = bounds
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)

        /// 追加するcontentViewの制約を設定する ※上下左右へ0の制約を追加する
        let bindings = ["view": contentView as Any]

        let contentViewConstraintH = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[view]|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: bindings
        )
        let contentViewConstraintV = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[view]|",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: bindings
        )
        addConstraints(contentViewConstraintH)
        addConstraints(contentViewConstraintV)

    }
    
    // MARK: - Function

    internal func setViewData(_ photo: Photo) {
        let placeholderImage = UIImage(systemName: "photo")
        self.photoImageView.af_setImage(withURL: photo.url!, placeholderImage: placeholderImage)
        self.photoImageView.layer.cornerRadius = CGFloat(20.0)
        self.photoImageView.layer.masksToBounds = true
        self.photoImageView.contentMode = UIView.ContentMode.scaleAspectFill
    }
    
    // MARK: - Private Function
    
    /// ドラッグが開始された際に実行される処理
    @objc private func startDragging(_ sender: UIPanGestureRecognizer) {
        
        // 中心位置からのX軸＆Y軸方向の位置の値を更新する
        xPositionFromCenter = sender.translation(in: self).x
        yPositionFromCenter = sender.translation(in: self).y
        
        /// UIPangestureRecognizerの状態に応じた処理を行う
        switch sender.state {
            
        /// ドラッグ開始時の処理
        case .began:
            
            /// ドラッグ処理開始時のViewがある位置を取得する
            originalPoint = CGPoint(
                x: self.center.x - xPositionFromCenter,
                y: self.center.y - yPositionFromCenter
            )
            
            /// DelegeteメソッドのbeganDraggingを実行する
            self.delegate?.cardViewDidBeginDragging(self)
            
            /// ドラッグ処理開始時のViewのアルファ値を変更する
            UIView.animate(withDuration: durationOfStartDragging, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.alpha = self.startDraggingAlpha
            }, completion: nil)
            
            break
            
        /// ドラッグ最中の処理
        case .changed:
            
            /// 動かした位置の中心位置を取得する
            let newCenterX = originalPoint.x + xPositionFromCenter
            let newCenterY = originalPoint.y + yPositionFromCenter
            
            /// Viewの中心位置を更新して動きをつける
            self.center = CGPoint(x: newCenterX, y: newCenterY)
            
            /// DelegeteメソッドのcardViewDidUpdatePositionを実行する
            self.delegate?.cardViewDidUpdatePosition(self, centerX: newCenterX, centerY: newCenterY)
            
            /// 中心位置からのX軸方向へ何パーセント移動したか（移動割合）を計算する
            currentMoveXPercentFromCenter = min(xPositionFromCenter / UIScreen.main.bounds.size.width, 1)
            
            /// 中心位置からのY軸方向へ何パーセント移動したか（移動割合）を計算する
            currentMoveYPercentFromCenter = min(yPositionFromCenter / UIScreen.main.bounds.size.height, 1)
            
            let initialRotationAngle = atan2(initialTransform.b, initialTransform.a)
            let whenDraggingRotationAngel = initialRotationAngle + CGFloat.pi / 10 * currentMoveXPercentFromCenter
            let transforms = CGAffineTransform(rotationAngle: whenDraggingRotationAngel)
            
            /// 拡大縮小比を適用する
            let scaleTransform: CGAffineTransform = transforms.scaledBy(x: maxScaleOfDragging, y: maxScaleOfDragging)
            self.transform = scaleTransform
            
            break
            
        /// ドラッグ終了時の処理
        case .ended, .cancelled:
            
            /// ドラッグ終了時点での速度を算出する
            let whenEndedVelocity = sender.velocity(in: self)
            
            /// 移動割合のしきい値を超えていた場合には、画面外へ流れていくようにする（しきい値の範囲内の場合は元に戻る）
            let shouldMoveToLeft  = (currentMoveXPercentFromCenter < -swipeXPosLimitRatio && abs(currentMoveYPercentFromCenter) > swipeYPosLimitRatio)
            let shouldMoveToRight = (currentMoveXPercentFromCenter > swipeXPosLimitRatio && abs(currentMoveYPercentFromCenter) > swipeYPosLimitRatio)
            
            if shouldMoveToLeft {
                moveInvisiblePosition(velocity: whenEndedVelocity, isLeft: true)
            } else if shouldMoveToRight {
                moveInvisiblePosition(velocity: whenEndedVelocity, isLeft: false)
            } else {
                moveOriginalPosition()
            }
            
            /// ドラッグ開始時の座標位置の変数をリセットする
            originalPoint = CGPoint.zero
            xPositionFromCenter = 0.0
            yPositionFromCenter = 0.0
            currentMoveXPercentFromCenter = 0.0
            currentMoveYPercentFromCenter = 0.0
            self.alpha = 1.0
            
            break
            
        default:
            break
        }
    }
    
    // このViewに対する初期設定を行う
    private func setupPhotoCardSetView() {
        
        // カード状のViewに関する基本的な設定
        self.clipsToBounds  = true
        self.frame = CGRect(
            origin: CGPoint.zero,
            size: CGSize(
                width: 350,
                height: 500
            )
        )
        
        /// 画面の中心に配置
        setInitialPosition()
    }
    
    /// このViewのUIPanGestureRecognizerの付与を行う
    private func setupPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.startDragging))
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    
    private func setInitialPosition () {
        /// Viewを初期位置に配置
        self.center = self.initialCenter
        self.transform = self.initialTransform
    }
    
    /// カードを元の位置へ戻す
    private func moveOriginalPosition() {
        
        UIView.animate(withDuration: durationOfReturnOriginal, delay: 0.0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
            
            /// Viewを初期位置に配置
            self.setInitialPosition()
            
        }, completion: nil)
        
        /// DelegeteメソッドのreturnToOriginalPositionを実行する
        self.delegate?.cardViewDidReturnToOriginalPosition(self)
        
    }
    
    /// カードを左側の領域外へ動かす
    private func moveInvisiblePosition(velocity: CGPoint, isLeft: Bool = true) {
        
        /// 変化後の予定位置を算出する（Y軸方向の位置はvelocityに基づいた値を採用する）
        let absPosX = UIScreen.main.bounds.size.width * 1.6
        let endCenterPosX = isLeft ? -absPosX : absPosX
        let endCenterPosY = velocity.y
        let endCenterPosition = CGPoint(x: endCenterPosX, y: endCenterPosY)
        
        UIView.animate(withDuration: durationOfSwipeOut, delay: 0.0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.0, options: [.curveEaseInOut], animations: {
            
            /// ドラッグ処理終了時はViewのアルファ値を元に戻す
            self.alpha = self.stopDraggingAlpha
            
            /// 変化後の予定位置までViewを移動する
            self.center = endCenterPosition
            
        }, completion: { _ in
            
            /// DelegeteメソッドのswipedLeftPositionを実行する
            let _ = isLeft ? self.delegate?.cardViewDidSwipeLeftPosition(self) : self.delegate?.cardViewDidSwipeRightPosition(self)
            /// 画面から該当のViewを削除する
            self.removeFromSuperview()
        })
    }
}
