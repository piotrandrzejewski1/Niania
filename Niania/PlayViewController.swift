//
//  PlayViewController.swift
//  Niania
//
//  Created by Piotr Andrzejewski on 25/06/2020.
//  Copyright © 2020 Ja. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase

class PlayViewController: UIViewController {
    
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var levelBackgroundView: UIView!
    @IBOutlet weak var levelViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertLevelViewBottom: NSLayoutConstraint!
    @IBOutlet weak var slider: UISlider!
    private var database: DatabaseReference?
    private let maxLevel: Int = 120
    private var alertLevel: Int = 100
    private var levelViewColor: UIColor?
    var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        levelViewColor = levelView.backgroundColor
        
        database = Database.database().reference()
        database?.observe(.childChanged) { [weak self] snapshot in
            guard let self = self else {
                return
            }
            
            self.sliderValueChanged(self.slider)

            let decibels = snapshot.value as? Float ?? 0
            self.showDecibels(decibels)
            
            if (Int(decibels) > self.alertLevel) {
                AudioServicesPlayAlertSound(SystemSoundID(1005))
            }
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        alertLevel = Int(sender.value)
        let levelHeight = Float(levelBackgroundView.bounds.height) * sender.value / 120
        alertLevelViewBottom.constant = CGFloat(levelHeight)
    }
}

extension PlayViewController {
    private func showDecibels(_ decibels: Float) {
        volumeLabel?.text = "\(Int(decibels))dB"
        let levelHeight = Float(levelBackgroundView.bounds.height) * decibels / 120
        
        UIView.animate(withDuration: 0.2) {[weak self] in
            guard let self = self else {
                return
            }
            
            if(Int(decibels) > self.alertLevel) {
                self.levelView.backgroundColor = UIColor.red.withAlphaComponent(CGFloat(0.5))
            }
            else {
                self.levelView.backgroundColor = self.levelViewColor
            }
            
            self.levelViewHeightConstraint.constant = CGFloat(levelHeight)
            self.view.layoutIfNeeded()
        }
    }
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "soundName", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = player else { return }
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}


