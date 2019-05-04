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

    
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataModel.modelInstance.modelDelegate = self
    }

    @IBAction func showButtonPressed(_ sender: UIButton) {
    
        var audio: AVURLAsset?
        var timeRange: CMTimeRange?
        if let audioURL = Bundle.main.url(forResource: "bgm", withExtension: "mp3")
        {
                audio = AVURLAsset(url: audioURL)
                let audioDuration = CMTime(seconds: 30, preferredTimescale: audio!.duration.timescale)
                timeRange = CMTimeRange(start: CMTime.zero, duration: audioDuration)
        }
        
        guard let imageList = DataModel.modelInstance.uiImagesList else {
            fatalError("no images added")
        }
        
        self.makeVideoWith(with: audio, audioTimeRange: timeRange, images: imageList)
    }
    
    @IBAction func galleryBtnPressed(_ sender: UIButton) {
        
        let imagePicker = OpalImagePickerController()
        let configuration = OpalImagePickerConfiguration()

        imagePicker.maximumSelectionsAllowed = 10
        configuration.maximumSelectionsAllowedMessage = NSLocalizedString("You can select a maximum of 10 images!", comment: "")
        imagePicker.configuration = configuration
                presentOpalImagePickerController(imagePicker, animated: true, select: { (assets) in
                        DataModel.modelInstance.getUIImages(from: assets)
                        imagePicker.dismiss(animated: true, completion: {})
            
                }, cancel: {
                    //Cancel
                })
    }
    
    
    //MARK :- misc methods
    
    func makeVideoWith(with audio: AVURLAsset?, audioTimeRange: CMTimeRange?, images: [UIImage]){
        let maker = VideoMaker(images: images, transition: ImageTransition.crossFadeLong)
        // OR: VideoMaker(images: images, movement: ImageMovement.fade)
        maker.contentMode = .scaleAspectFit
        maker.exportVideo(audio: audio, audioTimeRange: audioTimeRange, completed: { success, videoURL in
            if let url = videoURL {
                print(url)  // /Library/Mov/merge.mov
                
                let avPlayer = AVPlayer(url: url)
                self.avPlayerLayer = AVPlayerLayer(player: avPlayer)
                self.avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.avPlayerLayer.frame = self.slideImageView.bounds
                self.slideImageView.layer.addSublayer(self.avPlayerLayer)
                avPlayer.play()
                
                self.saveVideoToAlbums(from: url)
            }
        }).progress = { progress in
            print(progress)
        }
    }
    
    func saveVideoToAlbums(from url: URL)
    {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { saved, error in
            if saved {
                
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
                do{
                    try FileManager.default.removeItem(at: url)
                }catch{
                    print("deletion falied \(error)")
                }
            }
        }
    }
    

    //MARK :- ModelDelegate methods
    
    func reloadData() {
        self.collectionView.reloadData()
    }
}


extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let imageList = DataModel.modelInstance.uiImagesList else
        {
            return 0
        }
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageList = DataModel.modelInstance.uiImagesList else
        {
            print("no images available")
            fatalError()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! SlideCell
        cell.cellImage.image = imageList[indexPath.row]
        cell.index = indexPath.row
        return cell
    }
}

