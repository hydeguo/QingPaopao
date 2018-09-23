//
//  FirstViewController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/2.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class DrinkViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var bgView:UIView?
    @IBOutlet var slider:UISlider!
    
    @IBOutlet var actionBtn:UIButton?
    @IBOutlet var timeLabel:UILabel?
    @IBOutlet var sliderLabel5:UILabel?
    @IBOutlet var sliderLabel10:UILabel?
    @IBOutlet var sliderLabel15:UILabel?
    @IBOutlet var sliderLabel20:UILabel?
    
    @IBOutlet var drinkCupLabel:UILabel!
    @IBOutlet var drinkCupTotalLabel:UILabel!
    
    var nowDidplayId:String?
    var nowDidplayLastCmdTime:TimeInterval = 0
    var locationManager:CLLocationManager!
    var startElectrolyFlag = false
    
    
    let sliderNum = Variable(Float(0))
    var 👜 = DisposeBag()
    
    var timeOutTimer:Timer?
    var _timer:Timer?
    var _showTime:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        slider?.setThumbImage(UIImage(named:"slider"),for:.normal)

        sliderNum.asObservable().subscribe(onNext: {
            let m = Int($0)
            self.slider.value = $0
            self.timeLabel?.text =  "\(String(format: "%02d", m)) : \( String(format: "%02d", Int(($0 - Float(m)) * 60)))"
            self.sliderLabel5?.scale = $0 <= 7.5 ? 1.5 : 1;
            self.sliderLabel10?.scale = $0 > 7.5 && $0 <= 12.5 ? 1.5 : 1;
            self.sliderLabel15?.scale = $0 > 12.5 && $0 <= 17.5 ? 1.5 : 1;
            self.sliderLabel20?.scale = $0 > 17.5 ? 1.5 : 1;
        }).disposed(by: 👜)
      
        sliderNum.value = 5

//        createGradientLayer(view: self.bgView!)
        
        drinkCupLabel.layer.cornerRadius = drinkCupLabel.height/2;
        drinkCupLabel.layer.masksToBounds = true;
        drinkCupLabel.layer.borderColor = UIColor.white.cgColor
        drinkCupLabel.layer.borderWidth = 1;//边框宽度
        drinkCupTotalLabel.layer.cornerRadius = drinkCupTotalLabel.height/2;
        drinkCupTotalLabel.layer.masksToBounds = true;
        drinkCupTotalLabel.layer.borderColor = UIColor.white.cgColor
        drinkCupTotalLabel.layer.borderWidth = 1;//边框宽度
        
        
        #if targetEnvironment(simulator)
//            onClickReturn()
        #else
        if( cup_list.count == 0 ){
            _ = Wolf.requestList(type: MyAPI.cupList, completion: { (cups: [CupItem]?, msg, code) in
                if(code == "0")
                {
                    if let cupsItems = cups
                    {
                        cup_list = cupsItems
                        if( cup_list.count == 0 ){
                            self.onClickReturn()
                            return
                        }
                    }
                }
            }, failure: nil)
//            onClickReturn()
            return
        }
        #endif
        
        
    }

    private func getTodayDrinks()
    {
        _ = Wolf.request(type: MyAPI.getTodayDrinkList, completion: { (info: OneDayDrinks?, msg, code) in
            if(code == "0" && info != nil)
            {
                todayDrinks = info
            }
            self.updateDrinkText()
        }, failure: nil)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = (sender.value)
        sliderNum.value = currentValue
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = ""
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.parent?.navigationController?.setNavigationBarHidden(true, animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveDeviceDataSuccess), name: NSNotification.Name(rawValue: BLE_EVENT.BLE_receiveDeviceDataSuccess_1.rawValue), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveWifiStatusData), name: NSNotification.Name(rawValue: WIFI_EVENT.WIFI_STATUS.rawValue), object: nil)
        

        getTodayDrinks()
        
        timeOutTimer = setInterval(interval: 1, block: {
            if Date().timeIntervalSince1970 - self.nowDidplayLastCmdTime > 20 {
                if self.startElectrolyFlag{
                    self.stopElectrolyUI()
                }
                self.nowDidplayId = nil
            }
        })
    }

    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == "clean" || identifier == "light"{
            #if targetEnvironment(simulator)
            #else
            if(Date().timeIntervalSince1970 - WifiController.shared.lastReceiveTime > 30 && BLEController.shared.connectedDevice?.state != .connected)
            {
                _ = SweetAlert().showAlert("提示", subTitle: "请链接设备", style: AlertStyle.none)
                return false
            }
            if identifier == "clean"
            {
                if  startElectrolyFlag == true
                {
                    _ = SweetAlert().showAlert("提示", subTitle: "正在电解中", style: AlertStyle.none)
                    return false
                }
                else if CleanCupViewController.doneCleanFlag ==  true && BLEController.shared.connectedDevice?.state == .connected
                {
                    _ = SweetAlert().showAlert("提示", subTitle: "清洗已经完成", style: AlertStyle.none)
                    return false
                }
                else if WifiController.shared.mode == WIFI_CUP_MODE.CLEAN
                {
                    if(WifiController.shared.mode == WIFI_CUP_MODE.CLEAN) {
                        _ = SweetAlert().showAlert("提示", subTitle: "清洗已经完成，請倒掉水和重開水杯", style: AlertStyle.none)
                        return false
                    }
                }
            }
            #endif
        }
        return true
    }
    
    private func startElectrolyUI()
    {
        actionBtn?.backgroundColor = UIColor.lightGray
        actionBtn?.setTitle(Language.getString("停止电解"), for: .normal)
        self.slider.isEnabled = false
        startElectrolyFlag = true
        _timer?.invalidate()
        _timer = setInterval(interval: 1, block: {
            self.updateTimeLabel()
        })
    }
    private func stopElectrolyUI()
    {
        _timer?.invalidate()
        sliderNum.value = sliderNum.value
        actionBtn?.backgroundColor = UIColor.colorFromRGB(0x49BBFF)
        actionBtn?.setTitle(Language.getString("开始电解"), for: .normal)
        self.slider.isEnabled = true
        startElectrolyFlag = false
    }
    
    func updateDrinkText()
    {
        if let _todayDrinks = todayDrinks
        {
            self.drinkCupLabel.text = String(_todayDrinks.drinks!.count) + Language.getString("杯")
        }
        self.drinkCupTotalLabel.text = String(Int(myClientVo?.drinks ?? 0)) + Language.getString("杯")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        timeOutTimer?.invalidate()
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
            if(cmd.b == "01")
            {
                if(!startElectrolyFlag){
                    startElectrolyUI()
                }
            }
            else if (cmd.b == "02")
            {
                if(startElectrolyFlag){
                    stopElectroly()
                }
                self.nowDidplayId = nil
            }
        }
        else if cmd.a == "5"
        {
            if(startElectrolyFlag)
            {
                self._showTime = Int(cmd.b, radix: 16)! * 60 + Int(cmd.c, radix: 16)!;
                self.timeLabel?.text = "\(String(format: "%02d", Int(cmd.b, radix: 16)!)):\(String(format: "%02d", Int(cmd.c, radix: 16)!))"
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
            if(!startElectrolyFlag){
                startElectrolyUI()
            }
            self._showTime = H;
            self.timeLabel?.text = "\(String(format: "%02d", Int(H / 60))):\(String(format: "%02d", Int(CGFloat(H).truncatingRemainder(dividingBy: 60))))"
        }else if(M == "2") {
        }else if(M == "0") {
            if(startElectrolyFlag){
                stopElectroly()
            }
            self.nowDidplayId = nil
        }
    }
    
    @IBAction func onClickElectroly()
    {
        #if targetEnvironment(simulator)
        #else
        if(Date().timeIntervalSince1970 - WifiController.shared.lastReceiveTime > 30 && BLEController.shared.connectedDevice?.state != .connected)
        {
            _ = SweetAlert().showAlert("提示", subTitle: "请链接设备", style: AlertStyle.none)
            return
        }
        #endif
        
        
        if startElectrolyFlag == false
        {
            startElectroly()
        }
        else
        {
            stopElectroly()
        }
    }
    
    @IBAction func onClickReturn()
    {
//        let vc =  R.storyboard.main.deviceList()
////        self.show(vc!, sender: nil)
//        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func startElectroly()
    {
        startElectrolyUI()
        let electrolyTime = TimeInterval(sliderNum.value * 60)
        BLEController.shared.setTimeOutEle(time: electrolyTime)
        WifiController.shared.setTimeOutEle(time: electrolyTime)
    }
    
    func stopElectroly()
    {
        
        stopElectrolyUI()
        BLEController.shared.stopTimeOutEle()
        WifiController.shared.stopTimeOutEle()
        
        var BLE_cupId = ""
        #if targetEnvironment(simulator)
        #else
            BLE_cupId = BLEController.shared.connectedDevice?.identifier.uuidString ?? ""
        #endif
        let lastElectrolyTime = UserDefaults.standard.value(forKey: "\(idStr) lastElectrolyTime") as? Int ?? 0
        if Int(Date().timeIntervalSince1970) - Int(lastElectrolyTime) > 300 && BLE_cupId.count > 0
        {
            // wifi cup will send drink command bt itself
            determineMyLocation()
            _ = Wolf.request(type: MyAPI.drink(target: targetOfDrink, cupId: BLE_cupId ), completion: { (info: OneDrinks?, msg, code) in
                if(code == "0")
                {
                    let t_d =  myClientVo?.drinks ?? 0
                    myClientVo?.drinks = t_d + (info != nil ? info!.count! : 0);
                    self.getTodayDrinks()
                    refreshUserData(completion: {_ in })
                }
            }, failure: nil)
        }
        UserDefaults.standard.set(Int(Date().timeIntervalSince1970), forKey: "\(idStr) lastElectrolyTime")
    }
    
    func determineMyLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes
        manager.stopUpdatingLocation()
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        let lat = userLocation.coordinate.latitude
        let long = userLocation.coordinate.longitude
        let geoLink = "https://www.latlong.net/c/?lat=\(lat)&long=\(long)"
        _ = Wolf.request(type: MyAPI.addGeolocationParameters(device_id: "test", time: currentTimeZoneDate(), lat: lat, long: long, link: geoLink), completion: { (order: BaseReponse?, msg, code) in
        }) { (error) in
            // _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    private func updateTimeLabel()
    {
        _showTime -= 1;
        
        if(_showTime<=0){
            _timer?.invalidate()
            stopElectrolyUI()
        }else{
            self.timeLabel?.text = "\(String(format: "%02d", Int(_showTime / 60))):\(String(format: "%02d", Int(CGFloat(_showTime).truncatingRemainder(dividingBy: 60))))"
        }
    }

    
}

