//
//  ViewController.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/13.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let flickrClient = FlickrAPIClient()
    let request = SearchPhotoRequest(flickrMethod: .interesting)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        flickrClient.send(request: request) { result in
            switch result {
            case let .success(response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
}

