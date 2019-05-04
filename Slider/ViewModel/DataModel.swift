//
//  DataModel.swift
//  Slider
//
//  Created by Sarannya on 03/05/19.
//  Copyright © 2019 Sarannya. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol ModelDelegate {
    func reloadData()
}

class DataModel {
    
    static let modelInstance = DataModel()
    
    var modelDelegate: ModelDelegate?{
        didSet
        {
            print("delegate set")
        }
    }
    
    var uiImagesList : [UIImage]?{
        didSet
        {
            guard let delegate = modelDelegate else
            {
                fatalError("delegate not set")
            }
            delegate.reloadData()
        }
    }

    
     func getUIImages(from phAssets : [PHAsset]){
        let imageManager = PHImageManager.default()
        var uiImages : [UIImage] = []
        for ph in phAssets {
            
                    let requestOptions = PHImageRequestOptions()
                    requestOptions.deliveryMode = .highQualityFormat
                    imageManager.requestImage(for: ph, targetSize: CGSize(width: ph.pixelWidth, height: ph.pixelHeight), contentMode: .aspectFit, options: requestOptions) { (image, [AnyHashable : Any]?) in
                
                    uiImages.append(image!)
                    self.uiImagesList = uiImages
            }
        }
    }
    
    func deleteImage(at index: Int){
        uiImagesList?.remove(at: index)
        guard let delegate = modelDelegate else
        {
            fatalError("delegate not set")
        }
        delegate.reloadData()
    }
}
