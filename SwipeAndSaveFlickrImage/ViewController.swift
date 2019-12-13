//
//  ViewController.swift
//  SwipeAndSaveFlickrImage
//
//  Created by 市川星磨 on 2019/12/13.
//  Copyright © 2019 市川 星磨. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var testImageView: UIImageView!
    
    let flickrClient = FlickrAPIClient()
    let request = SearchPhotoRequest(flickrMethod: .interesting)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        flickrClient.send(request: request) { result in
            switch result {
            case let .success(response):
                for photo in response.photos {
                    if let url = photo.url {
                        self.flickrClient.getFlickrImage(url: url, imageView: self.testImageView)
                        return
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

