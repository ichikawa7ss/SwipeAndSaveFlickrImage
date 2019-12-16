//
//  FlickrPhotoCollectionViewController.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/13.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import UIKit

final class FlickrPhotoCollectionViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var presenter: SearchPhotoPresenterInput!
    func inject(presenter: SearchPhotoPresenterInput) {
        self.presenter = presenter
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初回はアラート表示
        if UserDefaults.standard.object(forKey: "firstUseCollectionVC") == nil {
            UserDefaults.standard.set(1, forKey: "firstUseCollectionVC")
            showOkAlert(title: "キーワードでおしゃれな画像を検索しましょう！")
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        
        // セルのサイジング
        setupCell()
    }
    
    /// セルの紐付けとサイジング設定の実施
    func setupCell () {
        //セルの登録
        let nib = UINib(nibName: "FlickrPhotoCollectionViewCell", bundle: Bundle.main)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImageCell")
        
        let flowLayout = UICollectionViewFlowLayout()
        let margin: CGFloat = 0
        let length: CGFloat = self.view.frame.width / 3
        flowLayout.itemSize = CGSize(width: length, height: length)
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        collectionView.collectionViewLayout = flowLayout
    }
}

// MARK:  - UICollectionViewDelegate
extension FlickrPhotoCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // プレゼンターに処理を委譲
        presenter.didSelectItem(at: indexPath)
    }
}

// MARK: - UICollectionViewDataSource
extension FlickrPhotoCollectionViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfPhotos
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // IBのセルと紐付け
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)as! FlickrPhotoCollectionViewCell

        // photo構造体のurlから画像を取得
        if let url = presenter.photo(forItem: indexPath.row)?.url {
            let placeholderImage = UIImage(systemName: "photo")
            cell.flickrPhotoImage.af_setImage(withURL: url, placeholderImage: placeholderImage)
        } else {
            cell.flickrPhotoImage.image = UIImage(systemName: "photo")
        }
        
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension FlickrPhotoCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 検索ボタン押下時にキーボードを閉じる
        searchBar.resignFirstResponder()
        do {
            // 検索処理をpuresenterへ委譲
            try presenter.didTapSearchButton(text: searchBar.text)
        } catch RequestError.noKeyword(let message) {
            // 入力値がなければエラーアラートを表示
            showOkAlert(title: message)
        } catch {
            print("その他のエラー")
        }
    }
}

// MARK:  - UICollectionViewDelegate
extension FlickrPhotoCollectionViewController: SearchPhotoPresenterOutput {
    /// 画像一覧を更新
    func updatePhotos(photos: [Photo]) {
        // 検索結果が0ならアラートを出し、画面更新はしない
        if (photos.count == 0) {
            showOkAlert(title: "検索にヒットする画像はありませんでした")
            return
        }
        
        // 0以上なら画面を更新
        collectionView.reloadData()
    }
    
    /// スワイプ画面に遷移
    func transitionToCardView(photoNum: Int) {
        // 次の画面を定義
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let swipePhotoViewController = storyboard.instantiateViewController(withIdentifier: "swipePhotoViewController") as! SwipePhotoViewController
        
        // 写真配列と選択された画像の番号を次の画面へ渡す
        swipePhotoViewController.photos = presenter.photos
        swipePhotoViewController.currentNum = photoNum
        
        swipePhotoViewController.title = "Swipe mode"
        navigationController?.pushViewController(swipePhotoViewController, animated: true)
    }
}
