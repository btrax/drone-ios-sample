//
//  ViewController.swift
//  drone-tutorial
//
//  Created by shiga yuichi on 12/14/15.
//  Copyright © 2015 btrax. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var takeOffButton: UIButton!
    @IBOutlet weak var landButton: UIButton!
    @IBOutlet weak var flipBtn: UIButton!
    
    let motionManager = CMMotionManager()
    var isConnected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setControllButtonsHidden(true)
        
        registerReceivers()
        startDiscovery()
        
        // 加速度の取得
        motionManager.accelerometerUpdateInterval = 0.1
        let accelerometerHandler:CMAccelerometerHandler = {
            (data: CMAccelerometerData?, error: NSError?) -> Void in
            
            if self.isConnected && abs(data!.acceleration.z) > 3.5 {
                DTDrone.sharedInstance().flip()
            }
        }
        
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: accelerometerHandler)
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterReceivers()
        stopDiscovery()
        
        if motionManager.accelerometerActive {
            motionManager.stopAccelerometerUpdates()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startDiscovery() {
        ARDiscovery.sharedInstance().start()
    }
    
    @IBAction func didTakeOffTap(sender: AnyObject) {
        DTDrone.sharedInstance().takeoff()
    }
    
    @IBAction func didLandTap(sender: AnyObject) {
        DTDrone.sharedInstance().land()
    }
    
    @IBAction func didFlipBtn(sender: AnyObject) {
        DTDrone.sharedInstance().flip()
    }
    
    func registerReceivers() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("discoveryDidUpdateServices:"),
            name: kARDiscoveryNotificationServicesDevicesListUpdated,
            object: nil
        )
    }
    
    func discoveryDidUpdateServices(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let deviceList = userInfo[kARDiscoveryServicesList]
            
            // 未接続状態なら、1つ目のデバイスに接続する
            if isConnected == false {
                let serviceList = deviceList as! [ARService]
                isConnected = DTDrone.sharedInstance().connectWithService(serviceList[0])
                
                // UIの更新
                setControllButtonsHidden(!isConnected)
                deviceNameLabel.text = serviceList[0].name
            }
        }
    }
    
    func setControllButtonsHidden(isHidden:Bool){
        takeOffButton.hidden = isHidden
        landButton.hidden = isHidden
        flipBtn.hidden = isHidden
    }
    
    func unregisterReceivers() {
       NSNotificationCenter.defaultCenter().removeObserver(self, name: kARDiscoveryNotificationServicesDevicesListUpdated, object: nil)
    }
    
    func stopDiscovery() {
       ARDiscovery.sharedInstance().stop()
    }
}