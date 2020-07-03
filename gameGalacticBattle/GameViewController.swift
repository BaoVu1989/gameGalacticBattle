//
//  GameViewController.swift
//  New_Shoot
//
//  Created by Bao Vu on 2/3/20.
//  Copyright © 2020 Bao Vu. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {

    var backgroundmusic = AVAudioPlayer()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "backgroundmusic", ofType: ".mp3")
        let audioNSURL = NSURL(fileURLWithPath: filePath!)
        do {
            backgroundmusic = try AVAudioPlayer(contentsOf: audioNSURL as URL)
        }
        catch { return print ("Canno Find The Audio")}
        
        backgroundmusic.numberOfLoops = -1
        backgroundmusic.volume = 1
        backgroundmusic.play()
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = GameScene(size: CGSize(width: 1080, height: 1920))
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
