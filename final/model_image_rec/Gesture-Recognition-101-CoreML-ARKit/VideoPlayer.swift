//
//  VideoPlayer.swift
//  Gesture-Recognition-101-CoreML-ARKit
//
//  Created by Bao Tran on 3/20/19.
//  Copyright © 2019 Emerging Interactions. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class VideoPlayer: AVPlayerViewController {

    var vid:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let videoURL = Bundle.main.url(forResource: vid!, withExtension: "mp4")
        print(videoURL!)
        let player = AVPlayer(url: videoURL!)
        self.player = player
        self.player?.play()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
