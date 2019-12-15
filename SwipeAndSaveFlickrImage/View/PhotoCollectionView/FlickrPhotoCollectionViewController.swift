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
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        // セルのサイジング
        setupCell()
    }
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)as! FlickrPhotoCollectionViewCell

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
    func updatePhotos(_ photos: [Photo]) {
        collectionView.reloadData()
    }
    
    func transitionToCardView(photoNum: Int) {
        // TODO: inject()の形でpresenterも注入する
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let swipePhotoViewController = storyboard.instantiateViewController(withIdentifier: "swipePhotoViewController") as! SwipePhotoViewController
        swipePhotoViewController.photos = presenter.photos
        swipePhotoViewController.firstIndex = photoNum
        
        swipePhotoViewController.modalPresentationStyle = .fullScreen
        self.present(swipePhotoViewController, animated: true, completion: nil)
    }
}
