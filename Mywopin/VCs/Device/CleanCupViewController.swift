//
//  CleanCupViewController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/1.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class CleanCupViewController: UIViewController {
    
    
    @IBOutlet var timeLabel:UILabel?
    @IBOutlet var knowBtn:UIButton?
    
    var nowDidplayId:String?
    var nowDidplayLastCmdTime:TimeInterval = 0
    
    var startCleanFlag = false
    
    var _showTime:Int = 0
    var timeOutTimer:Timer?
    var _timer:Timer?
    let sliderNum = Variable(Float(0))
    var 👜 = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.timeLabel?.text  = ""
    }
    override func viewDidDisappear(_ animated: Bool) {
        timeOutTimer?.invalidate()
        NotificationCenter.default.removeObserver(self);
    }
    
    @IBAction func know()
    {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveDeviceDataSuccess), name: NSNotification.Name(rawValue: BLE_EVENT.BLE_receiveDeviceDataSuccess_1.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveWifiStatusData), name: NSNotification.Name(rawValue: WIFI_EVENT.WIFI_STATUS.rawValue), object: nil)
        
        timeOutTimer = setInterval(interval: 1) {
            if Date().timeIntervalSince1970 - self.nowDidplayLastCmdTime > 20 {
                self.timeLabel?.text = "数据同步中"
                self.nowDidplayId = nil
            }
        }
        startClean()
        
    }
    
    func startClean()
    {

        BLEController.shared.setTimeOutClean()
        WifiController.shared.sendCleanOnOffCommandToWopin(on: true)
    }
    @IBAction func stopClean()
    {
        BLEController.shared.sendCommandToConnectedDevice(WopinCommand.CLEAN_OFF)
        WifiController.shared.sendCleanOnOffCommandToWopin(on: false)
        know()
    }
    
    
    @objc func onReceiveDeviceDataSuccess(_ notice:Notification)
    {
        if let bleCip:CBPeripheral=(notice as NSNotification).userInfo!["device"] as? CBPeripheral,let data:Data=(notice as NSNotification).userInfo!["data"] as? Data
        {
            if self.nowDidplayId != nil && self.nowDidplayId != bleCip.identifier.uuidString && Date().timeIntervalSince1970 - self.nowDidplayLastCmdTime < 20
            {
                return
            }
            
            self.nowDidplayId = bleCip.identifier.uuidString
            self.nowDidplayLastCmdTime = Date().timeIntervalSince1970
            
            let bytes = [UInt8] (data as Data)
            var hexString = ""
            for byte in bytes {
                hexString = hexString.appendingFormat("%02X", UInt(byte))
            }
            
            if(hexString.count > 16 ){
                
                let indexMsg = hexString.index(hexString.startIndex, offsetBy: 16)
                onCupDataCommand(String(hexString[hexString.startIndex..<indexMsg]))
                onCupDataCommand(String(hexString[indexMsg..<hexString.endIndex]))
            }
            else if(hexString.count == 16 )
            {
                onCupDataCommand(hexString)
            }
        }
    }
    private func onCupDataCommand(_ dataStr:String)
    {
        let cmd = parseCupData(dataStr)
        if cmd.a == "3"
        {
            if(cmd.b == "03")
            {
               startCleanFlag = true
            }
            else if (cmd.b == "04")
            {
                BLEController.shared.cleanFlag =  true
                self.timeLabel?.text = "清洗结束"
                self.nowDidplayId = nil
                startCleanFlag = false
                _timer?.invalidate()
            }
        }
        else if cmd.a == "5"
        {
            if(startCleanFlag)
            {
                self._showTime = Int(cmd.b, radix: 16)! * 60 + Int(cmd.c, radix: 16)!;
                self.timeLabel?.text = "\(String(format: "%02d", Int(cmd.b, radix: 16)!)):\(String(format: "%02d", Int(cmd.c, radix: 16)!))"
                
                _timer?.invalidate()
                let weakSelf = self
                _timer = setInterval(interval: 1, block: {
                    weakSelf.updateTimeLabel()
                })
            }
        }
    }
    
    @objc func onReceiveWifiStatusData(_ notice:Notification)
    {
        let cupId:String=(notice as NSNotification).userInfo!["device"] as! String
        if self.nowDidplayId != nil && self.nowDidplayId != cupId && Date().timeIntervalSince1970 - self.nowDidplayLastCmdTime < 20
        {
            return
        }
        
        self.nowDidplayId = cupId
        self.nowDidplayLastCmdTime = Date().timeIntervalSince1970
        
        let H:Int=(notice as NSNotification).userInfo!["H"] as? Int ?? 0
        let M:String=(notice as NSNotification).userInfo!["M"] as? String ?? ""
        if(M == "1"){
            
        }else if(M == "2") {
            startCleanFlag = true
            
            self._showTime = H;
            self.timeLabel?.text = "\(String(format: "%02d", Int(H / 60))):\(String(format: "%02d", Int(CGFloat(H).truncatingRemainder(dividingBy: 60))))"
            
            _timer?.invalidate()
            let weakSelf = self
            _timer = setInterval(interval: 1, block: {
                weakSelf.updateTimeLabel()
            })
        }else {
            self.nowDidplayId = nil
            _timer?.invalidate()
            if startCleanFlag{
                self.timeLabel?.text = "清洗结束"
                startCleanFlag = false
            }
        }
    }
    
    private func updateTimeLabel()
    {
        _showTime -= 1;

        if(_showTime<=0){
            _timer?.invalidate()
            
        }else{
            self.timeLabel?.text = "\(String(format: "%02d", Int(_showTime / 60))):\(String(format: "%02d", Int(CGFloat(_showTime).truncatingRemainder(dividingBy: 60))))"
        }
    }


    
}

