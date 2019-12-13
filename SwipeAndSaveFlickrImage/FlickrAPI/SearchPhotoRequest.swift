//
//  SearchPhotoRequest.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/13.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import Foundation

struct SearchPhotoRequest : FlickrRequest {
    typealias Response = SearchPhotoResponse
    
    var flickrMethod: FlickrMethod
    var extras: [URLQueryItem]? = [
        URLQueryItem(name: "extras", value: "url_h,width_h,height_h,date_taken")
    ]
    var queryItems: [URLQueryItem]
}
