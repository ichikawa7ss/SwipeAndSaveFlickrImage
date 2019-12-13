//
//  PhotoResponse.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/13.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import Foundation

struct PhotoResponse: Codable{
    var photos : [Photo] = []
    let totalCountStr : String
    var totalCount : Int {
        return Int(totalCountStr) ?? 0
    }
    
    enum CodingKeys : String, CodingKey {
        case totalCountStr = "total"
        case photos = "photo"
    }
    
    
    struct Photo : Codable{
        let id:String
        let height: Int?
        let width: Int?
        
        // JSONのレスポンスを受ける際に一度Stringで受ける
        let urlStr: String?
        var url: URL? {
            guard let url = urlStr else { return nil }
            return URL(string: url)
        }
        
        // JSONのレスポンスを受ける際に一度Stringで受ける
        let dateTakenStr:String?
        var dateTaken:Date? {
            guard let dateStr = dateTakenStr else { return nil }
            return PhotoResponse.Photo.dateFormatter.date(from: dateStr)
        }
        
        enum CodingKeys : String, CodingKey {
            case id
            case urlStr = "url_h"
            case height = "height_h"
            case width = "width_h"
            case dateTakenStr = "datetaken"
        }
        
        /// 日付フォーマッタ
        static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
            return formatter
        }()
    }
}

