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
    var keyword: String?
}
