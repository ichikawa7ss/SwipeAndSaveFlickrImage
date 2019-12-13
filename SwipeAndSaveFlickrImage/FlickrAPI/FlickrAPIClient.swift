//
//  FlickrAPIClient.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/13.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import Foundation
import Alamofire

class FlickrAPIClient {
    
    func send<Request: FlickrRequest>(
        request: Request,
        completion: @escaping (Result<Request.Response, Error>) -> ()) {
        
        let url = request.buildUrl()
        
        // alamofireによる通信処理
        Alamofire.request(url).validate(statusCode: 200..<400).responseJSON { response in
            // Resultの結果で場合分け
            switch response.result {
            case .success(let value):
                print(value)
            case .failure(let error):
                // 通信に関する失敗
                // alamofireから吐かれたエラー
                print(error)
            }
        }
    }
}
