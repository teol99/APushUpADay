//
//  ViewController.swift
//  APushUpADay
//
//  Created by Teo Lee on 4/2/20.
//  Copyright © 2020 Teo Lee. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
import Firebase

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var counter: UILabel!
    @IBOutlet weak var pushUpLabel: UILabel!
    @IBOutlet weak var totalCounter: UILabel!
    @IBOutlet weak var totalPushUpLabel: UILabel!
    @IBOutlet weak var startSetButton: UIButton!
    @IBOutlet weak var endSetButton: UIButton!
    
    var ref: DatabaseReference!
    var motionManager = CMMotionManager()
    var countdownSound: AVAudioPlayer?
        
    var currentPushUps = 0
    var currentUser = "testuser"
    
    override func viewDidAppear(_ animated: Bool) {
        motionManager.accelerometerUpdateInterval = 0.85
    }
    
    func startPushUpCounter () {
        startSetButton.isHidden = true
        totalPushUpLabel.isHidden = false
        totalCounter.isHidden = false
        counter.isHidden = false
        pushUpLabel.isHidden = false
        endSetButton.isHidden = false
        
        var prev = 0
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {(data, error) in
            if let myData = data
            {
                let cur = Int(100 - (myData.acceleration.z * -100))
//              print(cur - prev)
                if (cur - prev > 20) {
                    self.currentPushUps += 1
                }
                prev = cur
            }
            self.counter.text = String(self.currentPushUps)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        startPushUpCounter()
        player.stop()
    }
    
    @IBAction func startSetButtonPressed(sender: UIButton) {
        let path = Bundle.main.path(forResource: "countdown", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)

        do {
            countdownSound = try AVAudioPlayer(contentsOf: url)
            countdownSound?.delegate = self
            countdownSound?.play()
        } catch {
            print("could not load audio file")
        }
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let today = df.string(from:Date())
        
        print(self.ref.child("users").child(currentUser))
        
        self.ref.child("users").child(currentUser).child("daily").observeSingleEvent(of: .value, with: {(snapshot) in
            let values = snapshot.value as? NSDictionary
            if (values?[today] == nil) {
                self.totalCounter.text = "0"
            } else {
                self.totalCounter.text = "\(values![today]!)"
            }
        })
    }
    
    @IBAction func endSetButtonPressed(sender: UIButton) {
        motionManager.stopAccelerometerUpdates()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd|HH:mm:ss"
        let thisSet = df.string(from: Date())
        
        df.dateFormat = "yyyy-MM-dd"
        let today = df.string(from:Date())
        
        self.ref.child("users").child(currentUser).child("sets").updateChildValues([thisSet: self.currentPushUps])
        self.ref.child("users").child(currentUser).observeSingleEvent(of: .value, with: {(snapshot) in
            let values = snapshot.value as? NSDictionary
            if (values?["daily"] == nil) {
                self.ref.child("users").child(self.currentUser).child("daily").setValue([today: self.currentPushUps])
            } else {
                self.ref.child("users").child(self.currentUser).child("daily").observeSingleEvent(of: .value, with: {(snapshot) in
                    let values = snapshot.value as? NSDictionary
                    if (values?[today] == nil) {
                        self.ref.child("users").child(self.currentUser).child("daily").setValue([today: self.currentPushUps])
                    } else {
                        let todaysTotal = values![today] as! Int + self.currentPushUps
                        self.ref.child("users").child(self.currentUser).child("daily").setValue([today: todaysTotal])
                        print(String(todaysTotal))
                        self.totalCounter.text = String(todaysTotal)
                    }
                })
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        
        totalPushUpLabel.isHidden = true
        totalCounter.isHidden = true
        counter.isHidden = true
        pushUpLabel.isHidden = true
        endSetButton.isHidden = true
        
    }


}

