//
//  AutioService.swift
//  Niania
//
//  Created by Piotr Andrzejewski on 23/06/2020.
//  Copyright © 2020 Ja. All rights reserved.
//

import UIKit
import AVFoundation

class AudioService: NSObject, AVAudioRecorderDelegate {

    private var recorder : AVAudioRecorder? = nil
    private let settings = [
               AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
               AVSampleRateKey: 12000,
               AVNumberOfChannelsKey: 1,
               AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
           ]
    
    override init() {
        super.init();
       
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord)
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try session.setActive(true)
            
            try recorder = AVAudioRecorder(url: getDocumentsDirectory(), settings: settings)
            recorder!.delegate = self
            recorder!.isMeteringEnabled = true
            if !recorder!.prepareToRecord() {
                print("Error: AVAudioRecorder prepareToRecord failed")
            }
        } catch {
            print("Error: AVAudioRecorder creation failed")
        }
    }
    
    //MARK: protocol
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recorder.stop()
        recorder.deleteRecording()
        recorder.prepareToRecord()
    }
    
    //MARK: public
    func start() {
        recorder?.record()
        recorder?.updateMeters()
    }
    
    func update() {
        if let recorder = recorder {
            recorder.updateMeters()
        }
    }

    func getDecibels() -> Float {
        if let recorder = recorder {
            return recorder.averagePower(forChannel: 0) + 120
        }
        return 0
    }
}

extension AudioService {

    private func getDocumentsDirectory() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls.first!
        return documentDirectory.appendingPathComponent("recording.m4a")
    }
}
