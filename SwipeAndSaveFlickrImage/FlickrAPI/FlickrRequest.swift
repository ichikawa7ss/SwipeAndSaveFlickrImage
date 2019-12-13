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
}

extension FlickrRequest {
    var baseURL : URL {
        return URL(string: "https://www.flickr.com/services/rest")!
    }
}

