//
//  HearViewController.swift
//  Niania
//
//  Created by Ja on 19/06/2020.
//  Copyright © 2020 Ja. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase

class HearViewController: UIViewController {
    
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var levelBackgroundView: UIView!
    @IBOutlet weak var levelViewHeightConstraint: NSLayoutConstraint!
    private var audioService: AudioService?
    private var database: DatabaseReference?
    private let maxLevel: Int = 120
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        requestMicPermission {[weak self] granted in
            if (granted) {
                
                self?.database = Database.database().reference()
                self?.audioService = AudioService()
                self?.audioService?.start()
                
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) {[weak self] timer in
                    self?.checkDecibels()
                }
            }
            else {
                self?.showPermissionDeniedAlert()
            }
        }
    }
}

extension HearViewController {
    private func checkDecibels() {
        guard let audioService = audioService else {
            return
        }
               
        audioService.update()
        let decibels = audioService.getDecibels()
        volumeLabel?.text = "\(Int(decibels))dB"
        let levelHeight = Float(levelBackgroundView.bounds.height) * decibels / 120
        
        UIView.animate(withDuration: 0.2) {[weak self] in
            self?.levelViewHeightConstraint.constant = CGFloat(levelHeight)
            self?.view.layoutIfNeeded()
        }
        
        guard let database = database else {
            return
        }
               
        database.child("volume").setValue(decibels)
    }
        
    private func requestMicPermission(onResult: ((Bool) -> Void)?) {
        let permission = AVAudioSession.sharedInstance().recordPermission
    
        switch permission {
        case .denied:
            onResult?(false)
        case .granted:
            onResult?(true)
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                onResult?(granted)
            }
        @unknown default:
            onResult?(false)
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(title: "No mic permission", message: "Please enable Mic permiision in app settings", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}


