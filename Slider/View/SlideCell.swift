//
//  SlideCell.swift
//  Slider
//
//  Created by Sarannya on 03/05/19.
//  Copyright © 2019 Sarannya. All rights reserved.
//

import UIKit

//protocol SlideCellDelegate {
//    func 
//}

class SlideCell: UICollectionViewCell {
    
//    let imageTap = UITapGestureRecognizer(target: self, action: #selector(imagePressed(_:)))
    
    @IBOutlet weak var cellImage: UIImageView!
    
    var visibilityStatus  = true
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
//        cellImage.addGestureRecognizer(imageTap)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    @IBAction func imagePressed(_ sender: Any) {
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        visibilityStatus = false
        self.removeFromSuperview()
    }
    
}

//extension UIImageView {
//    func roundCorners(cornerRadius: Double) {
//        super.layer.cornerRadius = CGFloat(cornerRadius)
//        self.layer.cornerRadius = CGFloat(cornerRadius)
//        self.clipsToBounds = true
//    }
    
//}
