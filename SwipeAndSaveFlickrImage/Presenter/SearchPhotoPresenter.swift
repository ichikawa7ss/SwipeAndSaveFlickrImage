//
//  SearchPhotoPresenter.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/14.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import Foundation
import UIKit

/// 画像情報検索プレゼンターの入力に関するプロトコル
protocol SearchPhotoPresenterInput {
    var numberOfPhotos: Int { get }
    func photoImage(forItem index: Int) -> UIImageView?
    func didSelectItem(at indexPath: IndexPath)
    func didTapSearchButton(text: String?)
}

/// プレゼンターからの処理を委譲するプロトコル
protocol SearchPhotoPresenterOutput: AnyObject {
    func updatePhotos(_ photos: [Photo])
    func transitionToCardView(photoNum: Int)
}

/// 画像情報検索プレゼンター
final class SearchPhotoPresenter : SearchPhotoPresenterInput {
    // 画像はプレゼンタークラス内からのみ変更可能
    private(set) var photos: [Photo] = []

    // viewは処理を委譲する
    private weak var view: SearchPhotoPresenterOutput!
    private var model: SearchPhotoModelInput

    init(view: SearchPhotoPresenterOutput, model: SearchPhotoModelInput) {
        self.view = view
        self.model = model
    }

    var numberOfPhotos: Int {
        return photos.count
    }
    
    func photoImage(forItem index: Int) -> UIImageView? {
        guard index < photos.count else { return nil }
        guard let url = photos[index].url else { return nil }

        let imageView = UIImageView()
        let placeholderImage = UIImage(systemName: "photo")
        imageView.af_setImage(withURL: url , placeholderImage: placeholderImage)

        return imageView
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        view.transitionToCardView(photoNum: indexPath.row)
    }
    
    func didTapSearchButton(text: String?) {
        let request = SearchPhotoRequest(flickrMethod: .interesting)
        
        // モデルに画像取得処理を依頼
        model.fetchFlickrPhoto(request: request, completion: { result in
            switch result {
            case .success(let response):
                self.photos = response.photos                
                DispatchQueue.main.async {
                    self.view.updatePhotos(self.photos)
                }
            case .failure( _): break
                // TODO: Error Handling
            }
        })
    }
}

