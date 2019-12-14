//
//  FlickrPhotoCollectionViewController.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/13.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import UIKit

class FlickrPhotoCollectionViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let flickrClient = FlickrAPIClient()
    let request = SearchPhotoRequest(flickrMethod: .interesting)
    var response : SearchPhotoResponse?
        
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
        let margin: CGFloat = 0.5
        let length: CGFloat = self.view.frame.width / 3 - 1.5
        flowLayout.itemSize = CGSize(width: length, height: length)
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: margin, right: margin)
        collectionView.collectionViewLayout = flowLayout
    }
}

// MARK:  - UICollectionViewDelegate
extension FlickrPhotoCollectionViewController: UICollectionViewDelegate {
    
}

// MARK: - UICollectionViewDataSource
extension FlickrPhotoCollectionViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return response?.photos.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)as! FlickrPhotoCollectionViewCell

        if let url = self.response?.photos[indexPath.row].url {
            print("index:\(indexPath.row)")
            flickrClient.getFlickrImage(url: url, imageView: cell.flickrPhotoImage)
        } else {
            cell.flickrPhotoImage.image = UIImage(systemName: "photo")
        }
        
        return cell
    }
}
// MARK: - UISearchBarDelegate
extension FlickrPhotoCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        print("clicked")
        
        flickrClient.send(request: request) { result in
            switch result {
            case let .success(response):
                self.response = response
                self.collectionView.reloadData()
                print(self.response)
            case .failure(let error):
                print(error)
            }
        }
    }
}
