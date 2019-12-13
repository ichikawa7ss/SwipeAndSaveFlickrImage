//
//  FlickrPhotoCollectionViewController.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/13.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import UIKit

class FlickrPhotoCollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self

        //セルの登録
        let nib = UINib(nibName: "FlickrPhotoCollectionViewCell", bundle: Bundle.main)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImageCell")

    }




    // MARK: UICollectionViewDelegate
}

extension FlickrPhotoCollectionViewController: UICollectionViewDelegate {
    
}

extension FlickrPhotoCollectionViewController: UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)as! FlickrPhotoCollectionViewCell
        return cell
    }
}
