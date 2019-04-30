//
//  UIImageView.swift
//  Example
//
//  Created by dan on 03/04/2019.
//  Copyright © 2019 FlowKit2. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

public class AsyncImageView: UIImageView {
    
    private var currentUrl: String? //Get a hold of the latest request url
    
    public func imageFromServerURL(url: String){
        currentUrl = url
        if(imageCache.object(forKey: url as NSString) != nil){
            self.image = imageCache.object(forKey: url as NSString)
        }else{
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            let task = session.dataTask(with: NSURL(string: url)! as URL, completionHandler: { (data, response, error) -> Void in
                if error == nil {
                    
                    DispatchQueue.main.async {
                        if let downloadedImage = UIImage(data: data!) {
                            if (url == self.currentUrl) {//Only cache and set the image view when the downloaded image is the one from last request
                                imageCache.setObject(downloadedImage, forKey: url as NSString)
                                self.image = downloadedImage
                            }
                            
                        }
                    }
                    
                }
                else {
                    debugPrint("Failed to load image: \(String(describing: error))")
                }
            })
            task.resume()
        }
        
    }
}
