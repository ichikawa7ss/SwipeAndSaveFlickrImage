//
//  SearchPhotoModel.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/14.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import Foundation

/// 画像情報検索モデルへの入力に関するプロトコル
protocol SearchPhotoModelInput {
    func fetchFlickrPhoto<Request: FlickrRequest>
        (request: Request,completion: @escaping (Result<Request.Response,Error>) -> ())
}

/// 画像情報検索用モデル
final class SearchPhotoModel : SearchPhotoModelInput {
    
    /// Flickrの画像情報の取得を行う
    /// - Parameter request: APIリクエスト
    /// - Parameter completion: 完了ハンドラ
    func fetchFlickrPhoto<Request>(request: Request, completion: @escaping (Result<Request.Response,Error>) -> ()) where Request : FlickrRequest {
        
        // APIクライアント
        let flickrClient = FlickrAPIClient()
        
        // リクエスト送信処理
        flickrClient.send(request: request) { result in
            switch result {
            case let .success(response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
