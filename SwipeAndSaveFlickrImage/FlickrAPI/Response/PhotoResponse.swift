//
//  PhotoResponse.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/13.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import Foundation

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
        return Photo.dateFormatter.date(from: dateStr)
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


struct SearchPhotoResponse: Codable{
    var photos : [Photo] = []
    let totalCountStr : String
    var totalCount : Int {
        return Int(totalCountStr) ?? 0
    }
    
    // JSONレスポンスの一階層目
    enum RootKeys : String, CodingKey {
        case root = "photos"
    }
    
    // JSONレスポンスの二階層目
    enum CodingKeys : String, CodingKey {
        case totalCountStr = "total"
        case photos = "photo"
    }

    // ネストしたJSONレスポンスから各データへマッピングを行う
    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        let values = try root.nestedContainer(keyedBy: CodingKeys.self, forKey: .root)
        totalCountStr = try values.decode(String.self, forKey: .totalCountStr)
        photos = try values.decode([Photo].self, forKey: .photos)
    }
}

