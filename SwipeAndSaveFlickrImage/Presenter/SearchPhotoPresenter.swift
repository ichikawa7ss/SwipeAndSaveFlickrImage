//
//  SearchPhotoPresenter.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/14.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import Foundation

/// 画像情報検索プレゼンターの入力に関するプロトコル
protocol SearchPhotoPresenterInput {
    var photos: [Photo] { get }
    var numberOfPhotos: Int { get }
    func photo(forItem index: Int) -> Photo?
    func didSelectItem(at indexPath: IndexPath)
    func didTapSearchButton(text: String?) throws
}

/// プレゼンターからの処理を委譲するプロトコル
protocol SearchPhotoPresenterOutput: AnyObject {
    func updatePhotos(photos: [Photo])
    func transitionToCardView(photoNum: Int)
}

/// 画像情報検索プレゼンター
final class SearchPhotoPresenter : SearchPhotoPresenterInput {

    // viewは処理を委譲する
    private weak var view: SearchPhotoPresenterOutput!
    private var model: SearchPhotoModelInput

    init(view: SearchPhotoPresenterOutput, model: SearchPhotoModelInput) {
        self.view = view
        self.model = model
    }

    // 画像はプレゼンタークラス内からのみ変更可能
    private(set) var photos: [Photo] = []
    
    var numberOfPhotos: Int {
        return photos.count
    }
    
    func photo(forItem index: Int) -> Photo? {
        guard index < photos.count else { return nil }
        return self.photos[index]
    }
    
    func didSelectItem(at indexPath: IndexPath) {
        view.transitionToCardView(photoNum: indexPath.row)
    }
    
    func didTapSearchButton(text: String?) throws {
        guard let text = text else {
            throw RequestError.noKeyword("検索キーワードを入力してください")
        }
        // エラー処理
        if text.isEmpty {
            throw RequestError.noKeyword("検索キーワードを入力してください")
        }
        
        let request = SearchPhotoRequest(flickrMethod: .search, keyword: text)

        // モデルに画像取得処理を依頼
        model.fetchFlickrPhoto(request: request, completion: { result in
            switch result {
            case .success(let response):
                self.photos = self.truncateNotNeedPhoto(photos: response.photos)
                DispatchQueue.main.async {
                    self.view.updatePhotos(photos: self.photos)
                }
            case .failure( _): break
                // TODO: Error Handling
            }
        })
    }
    
    private func truncateNotNeedPhoto (photos: [Photo]) -> [Photo] {
        var newPhotos: [Photo] = []
        for photo in photos  {
            if let _ = photo.urlStr,
                let width = photo.width,
                let height = photo.height{
                if Int(Double(width) * 1.4) < height {
                    newPhotos.append(photo)
                }
            }
        }
        return newPhotos
    }
}

