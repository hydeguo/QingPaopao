//
//  DeviceInfoVC
//  Mywopin
//
//  Created by GuoXiaobin on 3/7/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import DLLocalNotifications
import UserNotifications
#if targetEnvironment(simulator)
class DeviceInfoVC: UITableViewController{
    func onSetData(info:CupItem){}
}
#else
class DeviceInfoVC: UITableViewController {

    @IBOutlet var powerLf:UILabel!
    @IBOutlet var nameLf:UILabel!
    @IBOutlet var colorLf:UILabel!
    @IBOutlet var statusLf:UIButton!
    
    @IBOutlet var noticeForDrink:UISwitch!
    @IBOutlet var shake:UISwitch!
    @IBOutlet var lighting:UISwitch!
    var deviceInfo:CupItem?
    
    override func viewDidLoad() {
        
        noticeForDrink.addTarget(self, action: #selector(noticeChanged), for: UIControlEvents.valueChanged)
        shake.addTarget(self, action: #selector(shakeChanged), for: UIControlEvents.valueChanged)
        lighting.addTarget(self, action: #selector(lightingChanged), for: UIControlEvents.valueChanged)
        
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(image: R.image.back(), style: UIBarButtonItemStyle.plain, target: self, action:  #selector(DeviceInfoVC.back(sender:)))
        
        self.navigationItem.leftBarButtonItem = newBackButton
       
        let _view = UIView()
        _view.backgroundColor = .clear
        self.tableView.tableFooterView = _view
        
        if(switchNotice){
            NoticeController().createLocalNotice()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(dateUpdate), name: NSNotification.Name(rawValue: "DeviceInfoChange"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveDeviceBattery), name: NSNotification.Name(rawValue: BLE_EVENT.BLE_receiveDeviceBattery.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectDeviceSuccess), name: NSNotification.Name(rawValue: BLE_EVENT.BLE_connectDeviceSuccess.rawValue), object: nil)
        self.nameLf.text =   deviceInfo?.name
        checkStatus()
        
        
        noticeForDrink.isOn = switchNotice
        shake.isOn = switchShake
        lighting.isOn = switchShine
        
    }
    
    @objc func back(sender: UIBarButtonItem) {
        if let vc = DeviceListViewController.shared {
            self.navigationController?.popToViewController(vc, animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func dateUpdate(_ notice:Notification){
        
        let cup:CupItem=(notice as NSNotification).userInfo!["data"] as! CupItem
        self.nameLf.text =   cup.name
        
    }
    @objc func onReceiveDeviceBattery(_ notice:Notification){
        
        if  let cup:CBPeripheral=(notice as NSNotification).userInfo!["device"] as? CBPeripheral
        {
            let cupBattery:Int=(notice as NSNotification).userInfo!["battery"] as! Int
            receiveDeviceBattery(cupBattery, device: cup)
        }
    }
    @objc func onConnectDeviceSuccess(_ notice:Notification){
        
        checkStatus()
    }
    
    func checkStatus()
    {
        let device = BLEController.shared.bleManager.getDeviceByUUID(deviceInfo?.uuid)
        if device?.state == .connected
        {
            statusLf.setTitle(Language.getString("已连接"), for: .normal)
            BLEController.shared.bleManager.readDeviceBattery(device)
        }
        else
        {
            statusLf.setTitle(Language.getString("未连接"), for: .normal)
        }
    }
    
    func onSetData(info:CupItem)
    {
        #if targetEnvironment(simulator)
        #else
            deviceInfo = info
            if info.type == DeviceTypeBLE
            {
                let device = BLEController.shared.bleManager.getDeviceByUUID(info.uuid)
                BLEController.shared.bleManager.readDeviceBattery(device)
                
            }
            else
            {
                    
            }
        
        #endif
    }

    
    func receiveDeviceBattery(_ battery: Int, device: CBPeripheral)
    {
        if(device.identifier.uuidString == deviceInfo?.uuid ){
            powerLf.text = "\(String(battery))%"
        }
        
        checkStatus()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCupName" {
            let destinationVC = segue.destination as! ChangeDeviceNameVC
            destinationVC.setData(cupData: self.deviceInfo!)

        }
    }
    
    @IBAction func clickConnect()
    {
        let device = BLEController.shared.bleManager.getDeviceByUUID(deviceInfo?.uuid)
        if(device?.state == .disconnected){
            BLEController.shared.bleManager.connect(toDevice: device)
        }
    }
    
    
    @objc func noticeChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        switchNotice = value
        UserDefaults.standard.set(switchNotice, forKey: "notice")
        if(switchNotice){
            NoticeController().createLocalNotice()
        }else{
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    @objc func shakeChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        switchShake = value
        UserDefaults.standard.set(switchShake, forKey: "shake")
    }
    @objc func lightingChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        switchShine = value
    }
    
}
#endif
