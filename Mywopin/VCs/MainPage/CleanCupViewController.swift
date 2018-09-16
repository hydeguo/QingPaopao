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
    
    static var doneCleanFlag : Bool = false
    
    @IBOutlet var timeLabel:UILabel?
    @IBOutlet var knowBtn:UIButton?
    
    var _timer:Timer?
    let sliderNum = Variable(Float(0))
    var 👜 = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.timeLabel?.text  = ""
    }
    override func viewDidDisappear(_ animated: Bool) {
        _timer?.invalidate()
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
        
        _timer = setInterval(interval: 1) {
            self.updateTimeLabel()
        }
        if(startCleanTime == 0 || Date().timeIntervalSince1970 - startCleanTime > cleanTime)
        {
            startClean()
        }
    }
    private func updateTimeLabel()
    {
        let time = cleanTime - (Date().timeIntervalSince1970 - startCleanTime)
        if time < 0
        {
             _timer?.invalidate()
            CleanCupViewController.doneCleanFlag =  true
            self.timeLabel?.text = "清洗结束"
        }
        else
        {
            self.timeLabel?.text = "\(String(format: "%02d", Int(time / 60))):\(String(format: "%02d", Int(CGFloat(time).truncatingRemainder(dividingBy: 60))))"
        }
        
    }
    
    func startClean()
    {
        startCleanTime = Date().timeIntervalSince1970
        UserDefaults.standard.set(startCleanTime, forKey: "startCleanTime")
        BLEController.shared.setTimeOutClean()
        WifiController.shared.sendCleanOnOffCommandToWopin(on: true)
    }
    @IBAction func stopClean()
    {
        startCleanTime = 0
        UserDefaults.standard.set(startCleanTime, forKey: "startCleanTime")
        BLEController.shared.sendCommandToConnectedDevice(WopinCommand.CLEAN_OFF)
        WifiController.shared.sendCleanOnOffCommandToWopin(on: false)
        know()
    }
    

    
}

