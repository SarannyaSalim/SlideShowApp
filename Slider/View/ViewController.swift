//
//  ViewController.swift
//  Slider
//
//  Created by Sarannya on 03/05/19.
//  Copyright © 2019 Sarannya. All rights reserved.
//

import UIKit
import SlideShowMaker
import AVFoundation
import Photos
import OpalImagePicker

class ViewController: UIViewController, UINavigationControllerDelegate, OpalImagePickerControllerDelegate,ModelDelegate {

    var avPlayerLayer : AVPlayerLayer!
    var currentSlideIndex:NSInteger = 0
    var slideMax:NSInteger = 0
    let model = DataModel()

    
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.modelDelegate = self
    }

    
//     @IBAction func showButtonPressed(_ sender: UIButton){
//
//        self.slideMax = self.images.count
//        DispatchQueue.global(qos: .userInteractive).async (
//            execute: {() -> Void in
//                while 1 == 1 {
//                    print ("MAX:"+String(self.slideMax))
//
//                    DispatchQueue.main.async(execute: {() -> Void in
//                        let toImage = self.images[self.currentSlideIndex]
//                        print ("index:"+String(self.currentSlideIndex))
//                        UIView.transition(
//                            with: self.slideImageView,
//                            duration: 0.9,
//                            options: .transitionCurlUp,
//                            animations: {self.slideImageView.image = toImage},
//                            completion: nil
//                        )
//                    })
//                    self.currentSlideIndex += 1
//                    if self.currentSlideIndex == self.slideMax {
//                        self.currentSlideIndex = 0
//                    }
//                    sleep(3)
//                }
//        })
//    }

    

    
    @IBAction func showButtonPressed(_ sender: UIButton) {
    
        var audio: AVURLAsset?
        var timeRange: CMTimeRange?
        if let audioURL = Bundle.main.url(forResource: "bgm", withExtension: "mp3") {
            audio = AVURLAsset(url: audioURL)
            let audioDuration = CMTime(seconds: 30, preferredTimescale: audio!.duration.timescale)
            timeRange = CMTimeRange(start: CMTime.zero, duration: audioDuration)
        }
        
        // OR: VideoMaker(images: images, movement: ImageMovement.fade)
        guard let imageList = model.uiImagesList else {
            fatalError()
        }
        
        let maker = VideoMaker(images: imageList, transition: ImageTransition.crossFadeLong)
        
        maker.contentMode = .scaleAspectFit
        maker.exportVideo(audio: audio, audioTimeRange: timeRange, completed: { success, videoURL in
            if let url = videoURL {
                print(url)  // /Library/Mov/merge.mov
                
//                let avAssets = AVAsset(url: url)
                let avPlayer = AVPlayer(url: url)
                self.avPlayerLayer = AVPlayerLayer(player: avPlayer)
                self.avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.avPlayerLayer.frame = self.slideImageView.bounds
                self.slideImageView.layer.addSublayer(self.avPlayerLayer)
                avPlayer.play()
                
            }
        }).progress = { progress in
            print(progress)
        }
    }
    
    @IBAction func galleryBtnPressed(_ sender: UIButton) {
        
        let imagePicker = OpalImagePickerController()
        imagePicker.maximumSelectionsAllowed = 5
        
        let configuration = OpalImagePickerConfiguration()
        configuration.maximumSelectionsAllowedMessage = NSLocalizedString("You can select a maximum of 5 images!", comment: "")
        imagePicker.configuration = configuration
        
        presentOpalImagePickerController(imagePicker, animated: true, select: { (assets) in
            
            self.getUIImages(from: assets, callback:{(images) in
                self.model.getUIImages(from: assets)
            })
            
            imagePicker.dismiss(animated: true, completion: {
                
            })
        }, cancel: {
            //Cancel
        })
        
    }
    
    func getUIImages(from phAssets : [PHAsset], callback: ([UIImage])->Void){
        
        let imageManager = PHImageManager.default()
        var uiImages : [UIImage] = []
        for ph in phAssets {
            imageManager.requestImage(for: ph, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFill, options: nil) { (image, [AnyHashable : Any]?) in
                uiImages.append(image!)
            }
        }
        callback(uiImages)
    }
    
}


extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    
    func reloadData() {
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let imageList = model.uiImagesList else {
            return 0
        }
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageList = model.uiImagesList else {
            print("no images available")
            fatalError()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! SlideCell
        cell.cellImage.image = imageList[indexPath.row]
        return cell
    }
}
//https://stackoverflow.com/questions/54642211/swift-4-xcode-10-play-video-on-app-launch-when-complete-reveal-view-control

