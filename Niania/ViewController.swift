//
//  ViewController.swift
//  Niania
//
//  Created by Ja on 19/06/2020.
//  Copyright © 2020 Ja. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    private var audioService: AudioService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        requestMicPermission {[weak self] granted in
            if (granted) {
                self?.audioService = AudioService()
            }
            else {
                self?.showPermissionDeniedAlert()
            }
        }
    }
    
    @IBAction func buttonClick() {
        guard let audioService = audioService else {
            return
        }
        
        audioService.update()
        volumeLabel?.text = "\(audioService.getDecibels())dB"
    }
}

extension ViewController {
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


