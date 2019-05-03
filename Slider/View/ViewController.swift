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

class ViewController: UIViewController {

    var avPlayerLayer : AVPlayerLayer!
    
    @IBOutlet weak var slideImageView: UIImageView!
    
    var images = [UIImage(named: "1"),UIImage(named: "2"),UIImage(named: "3"),UIImage(named: "4"),UIImage(named: "5")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    
    @IBAction func showButtonPressed(_ sender: UIButton) {
        
        var audio: AVURLAsset?
        var timeRange: CMTimeRange?
        if let audioURL = Bundle.main.url(forResource: "bgm", withExtension: "mp3") {
            audio = AVURLAsset(url: audioURL)
            let audioDuration = CMTime(seconds: 30, preferredTimescale: audio!.duration.timescale)
            timeRange = CMTimeRange(start: CMTime.zero, duration: audioDuration)
        }
        
        // OR: VideoMaker(images: images, movement: ImageMovement.fade)
        let maker = VideoMaker(images: images, transition: ImageTransition.crossFadeLong)
        
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
    
}

//https://stackoverflow.com/questions/54642211/swift-4-xcode-10-play-video-on-app-launch-when-complete-reveal-view-control
