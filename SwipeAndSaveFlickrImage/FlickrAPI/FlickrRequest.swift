//
//  FlickrRequest.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/13.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import Foundation

enum FlickrMethod : String {
    case interesting = "flickr.interestingness.getList"
    case recent = "flickr.photos.getRecent"
    case search = "flickr.photos.search"
}

protocol FlickrRequest {
    associatedtype Response : Codable
    
    var baseURL : URL { get }
    var flickrMethod : FlickrMethod { get }
    var queryItems: [URLQueryItem] { get }
    var extras : [URLQueryItem]? { get }

}

extension FlickrRequest {
    var baseURL : URL {
        return URL(string: "https://www.flickr.com/services/rest")!
    }
    
    var queryItems :[URLQueryItem] {
        // 基本のクエリパラーメータ
        var baseQueryItem: [URLQueryItem] =
        [
            URLQueryItem(name: "method", value: self.flickrMethod.rawValue),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "api_key", value: "fda2005ab7115e9f1d44f3e810a81b42"),
            URLQueryItem(name: "nojsoncallback", value:"1"),
        ]
        
        // APIの種類に応じて追加のパラメータを追加
        if let extras = extras {
            for extra in extras {
                baseQueryItem.append(extra)
            }
        }
        
        return baseQueryItem
    }
    
    // TODO extrasをメソッドによってかき
    
    // クエリパラメータを追加したリクエスト用のURLの作成
    func buildUrl() -> URL {
        let url = baseURL
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = queryItems
        return components.url!
    }

    
}

