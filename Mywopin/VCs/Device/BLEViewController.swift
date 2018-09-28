//
//  BLEViewController
//  Mywopin
//
//  Created by Hydeguo on 2018/6/3.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import UIKit
import Moya

#if targetEnvironment(simulator)
class BLEViewController: UIViewController {}
#else
class BLEViewController: UIViewController {
    
    @IBOutlet var statueLabel:UILabel!
    @IBOutlet var innercircle:UIImageView!
    @IBOutlet var innercircle_m:UIImageView!
    @IBOutlet var innercircle_b:UIImageView!
    @IBOutlet var bleBtn0:UIButton!
    @IBOutlet var bleBtn1:UIButton!
    @IBOutlet var bleBtn2:UIButton!
    @IBOutlet var bleBtn3:UIButton!
    @IBOutlet var bleBtn4:UIButton!
    @IBOutlet var bleBtn5:UIButton!
    @IBOutlet var bleBtn6:UIButton!
    @IBOutlet var bleBtn7:UIButton!
    @IBOutlet var bleBtn8:UIButton!
    @IBOutlet var bleBtn9:UIButton!
    @IBOutlet var bleBtn10:UIButton!
    @IBOutlet var bleBtn11:UIButton!
    @IBOutlet var bleBtn12:UIButton!
    @IBOutlet var bleBtn13:UIButton!
    @IBOutlet var bgView:UIView!
    
    var bleBtnList:Array<UIButton> = []
    var usedbleBtnList:Array<UIButton> = []
    
    var discoveredDeviceMap = [String : String]()  // UUID : Device Name
    var discoveredDeviceBtnMap = [String : UIButton]()
    var discoveredDeviceList = [""]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        statueLabel.text = ""
        bleBtnList =  [bleBtn0,bleBtn1,bleBtn2,bleBtn3,bleBtn4,bleBtn5,bleBtn6,bleBtn7,bleBtn8,bleBtn9,bleBtn10,bleBtn11,bleBtn12,bleBtn13]
        
        for btn in bleBtnList
        {
            btn.isHidden = true
        }
        
//        createGradientLayer(view: self.view)
//        createGradientLayer(view: self.innercircle, startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 1, y: 1))
        
        
        
        innercircle.layer.borderWidth = 4
        innercircle.layer.borderColor = UIColor.white.cgColor
        innercircle_m.layer.borderWidth = 2
        innercircle_m.layer.borderColor = UIColor.white.cgColor
        innercircle_b.layer.borderWidth = 2
        innercircle_b.layer.borderColor = UIColor.white.cgColor
        
    }

    @objc func scanDevice() {
//        if (BLEController.shared.connectedDevice == nil)
//        {
            print("scanning device....")
            BLEController.shared.bleManager.scanDeviceTime(5)
//        }
    }
    

    
    override func viewDidLayoutSubviews() {
        
        let progressView = BLEProgressView()
        progressView.frame = self.bgView.bounds
        self.bgView.addSubview(progressView)
        self.bgView.insertSubview(progressView, at: 1)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        BLEController.shared.bleManager.manualStopScanDevice()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(onScanReturn), name: NSNotification.Name(rawValue: BLE_EVENT.BLE_scanDeviceRefrash.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveDeviceDataSuccess), name: NSNotification.Name(rawValue: BLE_EVENT.BLE_receiveDeviceDataSuccess_1.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDisconnectDevice), name: NSNotification.Name(rawValue: BLE_EVENT.BLE_didDisconnectDevice.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectDeviceSuccess), name: NSNotification.Name(rawValue: BLE_EVENT.BLE_connectDeviceSuccess.rawValue), object: nil)
        
        perform(#selector(scanDevice), with: nil, afterDelay: 5)
        
        
    }
    

    @IBAction func onReturn()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    //pragma mark - BLeManager Delegate
    func centerManagerStateChange(_ state: CBManagerState) {
        print("centerManagerStateChange \(state.rawValue)")
    }
    
    @objc func onScanReturn(_ notice:Notification)
    {
        if let cupsList:NSMutableArray=(notice as NSNotification).userInfo!["data"] as? NSMutableArray
        {
            scanDeviceRefrash(cupsList);
        }
    }
    @objc func onReceiveDeviceDataSuccess(_ notice:Notification)
    {
        if let device:CBPeripheral=(notice as NSNotification).userInfo!["device"] as? CBPeripheral,let data:Data=(notice as NSNotification).userInfo!["data"] as? Data
        {
            receiveDeviceDataSuccess_1(data, device: device)
        }
    }
    @objc func onDisconnectDevice(_ notice:Notification)
    {
        if let device:CBPeripheral=(notice as NSNotification).userInfo!["data"] as? CBPeripheral
        {
            didDisconnectDevice(device);
        }
    }
    @objc func onConnectDeviceSuccess(_ notice:Notification)
    {
        if let device:CBPeripheral=(notice as NSNotification).userInfo!["data"] as? CBPeripheral
        {
            connectDeviceSuccess(device);
        }
    }
    
    func scanDeviceRefrash(_ array: NSMutableArray!) {
        
        var tempList = [String]()
        for uuid in discoveredDeviceList
        {
            var hasID:Bool = false
            for info in (array as NSMutableArray as! [DeviceInfo]) {
                if(info.uuidString == uuid){
                    hasID = true
                    tempList.append(uuid)
                    break
                }
            }
            if hasID == false
            {
                if let curBtn = discoveredDeviceBtnMap[uuid]
                {
                    curBtn.isHidden = true
                    if let index = usedbleBtnList.index(of: curBtn)
                    {
                        usedbleBtnList.remove(at: index)
                    }
                    bleBtnList.append(curBtn)
                }
            }
        }
        discoveredDeviceList = tempList
        
        for info in (array as NSMutableArray as! [DeviceInfo]) {
            if (!discoveredDeviceList.contains(info.uuidString))
            {
                discoveredDeviceList.append(info.uuidString)
                discoveredDeviceMap[info.uuidString] = info.localName
                print(info.uuidString)
//                deviceTableView.reloadData()
                let number = arc4random_uniform(UInt32(bleBtnList.count))
                let btn = bleBtnList.remove(at: Int(number))
                usedbleBtnList.append(btn)
                btn.isHidden = false
                btn.setTitle(info.localName, for: .normal)
                discoveredDeviceBtnMap[info.uuidString] = btn
            }
        }
    }
    
    @IBAction func onBleBtnClicked(_ btn:UIButton)
    {
        for (uuid,bleBtn) in discoveredDeviceBtnMap {
            if btn == bleBtn
            {
                print("Selected \(self.discoveredDeviceMap[uuid]!)")
                let peripheral : CBPeripheral? = BLEController.shared.bleManager.getDeviceByUUID(uuid)
                BLEController.shared.bleManager.connect(toDevice: peripheral)
                
            }
        }
    }
    
    func connectDeviceSuccess(_ device: CBPeripheral!) {
        print("Device connected ! \(device.name ?? "")")
        statueLabel.text = "Connected"
        if(!BLEController.shared.savedBLE.contains(device.identifier.uuidString))
        {
            BLEController.shared.savedBLE.append(device.identifier.uuidString)
            UserDefaults.standard.set(BLEController.shared.savedBLE, forKey: "\(idStr) BLE_list")
        }
        
        _ = Wolf.request(type: MyAPI.addOrUpdateACup(type: DeviceTypeBLE, uuid: device.identifier.uuidString, name: device.name!, add: true), completion: { (user: User?, msg, code) in
            if(code == "0")
            {
                myClientVo = user
                let detail_info_vc = R.storyboard.main.deviceInfo()
                detail_info_vc?.onSetData(info: CupItem(type: DeviceTypeBLE, name: device?.name, uuid: device.identifier.uuidString,  color :0,firstRegisterTime: "", registerTime: "", userId: myClientVo?._id, produceScores: 0))
                self.show(detail_info_vc!, sender: nil)
            }
            else
            {
                _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
            }
        }) { (error) in
            _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        }
    }
    
    func didDisconnectDevice(_ device: CBPeripheral) {
      
        print("Device disconnected normally! \(device.name ?? "")")
        statueLabel.text = "Disconnected"
        BLEController.shared.connectedDevice = nil
    }
    
    //Some data will be received here....Let process that later...
    func receiveDeviceDataSuccess_1(_ data: Data!, device: CBPeripheral!) {
        
    }
}

#endif
