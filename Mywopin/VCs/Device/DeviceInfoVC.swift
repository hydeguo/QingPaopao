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
    @IBOutlet var timeLf:UILabel!
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveDeviceDataSuccess), name: NSNotification.Name(rawValue: BLE_EVENT.BLE_receiveDeviceDataSuccess_1.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onConnectDeviceSuccess), name: NSNotification.Name(rawValue: BLE_EVENT.BLE_connectDeviceSuccess.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveWifiDeviceData), name: NSNotification.Name(rawValue: WIFI_EVENT.WIFI_POWER.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveWifiStatusData), name: NSNotification.Name(rawValue: WIFI_EVENT.WIFI_STATUS.rawValue), object: nil)
        
        
        self.nameLf.text =   deviceInfo?.name

        if deviceInfo?.type == "WIFI"
        {
            WifiController.shared.allOnlineWifiCup.forEach { (wifiCup) in
                if(deviceInfo?.uuid == wifiCup.uuid){
                    if(Date().timeIntervalSince1970 - wifiCup.lastOnline < 30)
                    {
                        statusLf.setTitle(Language.getString("已连接"), for: .normal)
                        powerLf.text = "\(wifiCup.power)%"
                    }
                    else
                    {
                        statusLf.setTitle(Language.getString("未连接"), for: .normal)
                        powerLf.text = "--"
                    }
                }
            }
        }
        else
        {
            checkStatus()
        }
        
        
        
        noticeForDrink.isOn = switchNotice
        shake.isOn = switchShake
        lighting.isOn = switchShine
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func back(sender: UIBarButtonItem) {
        if let vc = DeviceListViewController.shared {
            self.navigationController?.popToViewController(vc, animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    @objc func onReceiveWifiDeviceData(_ notice:Notification){
        
        let cupId:String=(notice as NSNotification).userInfo!["device"] as! String
        let cupPower:String=(notice as NSNotification).userInfo!["power"] as! String
        if(deviceInfo?.uuid == cupId){
            if statusLf.titleLabel?.text != "电解中" && statusLf.titleLabel?.text == "清洗中"
            {
                statusLf.setTitle(Language.getString("已连接"), for: .normal)
            }
            powerLf.text = "\(cupPower)%"
        }
    }
    @objc func onReceiveWifiStatusData(_ notice:Notification){
        let cupId:String=(notice as NSNotification).userInfo!["device"] as! String
        if(deviceInfo?.uuid == cupId){
            let H:Int=(notice as NSNotification).userInfo!["H"] as? Int ?? 0
            let M:String=(notice as NSNotification).userInfo!["M"] as? String ?? ""
            if(M == "1"){
                statusLf.setTitle(Language.getString("电解中"), for: .normal)
                self.timeLf?.text = "\(String(format: "%02d", Int(H / 60))):\(String(format: "%02d", Int(CGFloat(H).truncatingRemainder(dividingBy: 60))))"
            }else if(M == "2") {
                statusLf.setTitle(Language.getString("清洗中"), for: .normal)
                self.timeLf?.text = "\(String(format: "%02d", Int(H / 60))):\(String(format: "%02d", Int(CGFloat(H).truncatingRemainder(dividingBy: 60))))"
            }else {
                statusLf.setTitle(Language.getString("--"), for: .normal)
                self.timeLf?.text = "--"
            }
        }
        
    }
    
    @objc func dateUpdate(_ notice:Notification){
        
        let cup:CupItem=(notice as NSNotification).userInfo!["data"] as! CupItem
        self.nameLf.text =   cup.name
        
    }
    
    @objc func onReceiveDeviceDataSuccess(_ notice:Notification)
    {
        if let device:CBPeripheral=(notice as NSNotification).userInfo!["device"] as? CBPeripheral,let data:Data=(notice as NSNotification).userInfo!["data"] as? Data
        {
            receiveDeviceDataSuccess_1(data, device: device)
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
            }
            else
            {
            }
        
        #endif
    }
    
    func receiveDeviceDataSuccess_1(_ data: Data!, device: CBPeripheral!) {
        guard deviceInfo?.uuid == device.identifier.uuidString else {
            return
        }
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
//        print("Received some data: \(hexString)")
        
    }
    
    private func onCupDataCommand(_ dataStr:String)
    {
        let cmd = parseCupData(dataStr)
        if cmd.a == "1"
        {
            powerLf.text = "\(String(format: "%02d", Int(cmd.b, radix: 16)!))%"        }
    }
    
//    func receiveDeviceBattery(_ battery: Int, device: CBPeripheral)
//    {
//        if(device.identifier.uuidString == deviceInfo?.uuid ){
//            powerLf.text = "\(String(battery))%"
//        }
//
//        checkStatus()
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCupName" {
            let destinationVC = segue.destination as! ChangeDeviceNameVC
            destinationVC.setData(cupData: self.deviceInfo!)

        }
    }
    
    @IBAction func clickConnect()
    {
        if(deviceInfo?.type == DeviceTypeBLE)
        {
            let device = BLEController.shared.bleManager.getDeviceByUUID(deviceInfo?.uuid)
            if(device?.state == .disconnected){
                BLEController.shared.bleManager.connect(toDevice: device)
            }else if(device?.state == .connected){
                _ = SweetAlert().showAlert("提示", subTitle: "是否断开连接？" , style: AlertStyle.none, buttonTitle:"确定", buttonColor: main_color, otherButtonTitle:  "取消", otherButtonColor: main_color) { (isOtherButton) -> Void in
                    if isOtherButton == true {
                        // do not need to remove 
//                        BLEController.shared.savedBLE = BLEController.shared.savedBLE.filter { $0 != device!.identifier.uuidString }
//                        UserDefaults.standard.set(BLEController.shared.savedBLE, forKey: "BLE_list")
                        BLEController.shared.bleManager.stopAutoConnect()
                        BLEController.shared.bleManager.disconnectDevice(device)
                        self.checkStatus()
                    }
                }
            }
        }
    }
    
    
    @objc func noticeChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        switchNotice = value
        UserDefaults.standard.set(switchNotice, forKey: "\(idStr) notice")
        if(switchNotice){
            NoticeController().createLocalNotice()
        }else{
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
    @objc func shakeChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        switchShake = value
        UserDefaults.standard.set(switchShake, forKey: "\(idStr) shake")
    }
    @objc func lightingChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        switchShine = value
    }
    
}
#endif
