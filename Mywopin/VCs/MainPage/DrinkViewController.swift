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
    
    var locationManager:CLLocationManager!
    var startElectrolyFlag = false
    
    var _timer:Timer?
    
    let sliderNum = Variable(Float(0))
    var 👜 = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        slider?.setThumbImage(UIImage(named:"slider"),for:.normal)

        sliderNum.asObservable().subscribe(onNext: {
            let m = Int($0)
            self.slider.value = $0
            self.timeLabel?.text =  "\(String(format: "%02d", m)) : \( String(format: "%02d", Int(($0 - Float(m)) * 60)))"
            self.sliderLabel5?.scale = $0 <= 5 ? 1.5 : 1;
            self.sliderLabel10?.scale = $0 > 5 && $0 <= 10 ? 1.5 : 1;
            self.sliderLabel15?.scale = $0 > 10 && $0 <= 15 ? 1.5 : 1;
            self.sliderLabel20?.scale = $0 > 15 && $0 <= 20 ? 1.5 : 1;
        }).disposed(by: 👜)
      
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
        
        if startElectrolyTime == 0 || Date().timeIntervalSince1970 - startElectrolyTime > electrolyTime
        {
            self.slider.isEnabled = true
            sliderNum.value = 5
        }
        else
        {
            startElectrolyUI()
            sliderNum.value = Float(electrolyTime / 60)
            _timer = setInterval(interval: 1, block: {
                self.updateTimeLabel();
            })
        }
        getTodayDrinks()
    }
    
    private func startElectrolyUI()
    {
        actionBtn?.backgroundColor = UIColor.lightGray
        actionBtn?.setTitle(Language.getString("停止电解"), for: .normal)
        self.slider.isEnabled = false
        startElectrolyFlag = true
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
        _timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onReceiveDeviceDataSuccess(_ notice:Notification)
    {
        if let _:CBPeripheral=(notice as NSNotification).userInfo!["device"] as? CBPeripheral,let data:Data=(notice as NSNotification).userInfo!["data"] as? Data
        {
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
                }else{
                    _timer?.invalidate()
                }
            }
            else if (cmd.b == "02")
            {
                if(startElectrolyFlag){
                    stopElectroly()
                }
            }
        }
        else if cmd.a == "5"
        {
            if(startElectrolyFlag)
            {
                self.timeLabel?.text = "\(String(format: "%02d", Int(cmd.b, radix: 16)!)):\(String(format: "%02d", Int(cmd.c, radix: 16)!))"
            }
        }
    }
    
    @IBAction func onClickElectroly()
    {
        if startElectrolyTime == 0
        {
            startElectroly()
            actionBtn?.backgroundColor = UIColor.lightGray
            actionBtn?.setTitle(Language.getString("停止电解"), for: .normal)
            self.slider.isEnabled = false
            _timer?.invalidate()
            _timer = setInterval(interval: 1, block: {
                self.updateTimeLabel();
            })
        }
        else
        {
            stopElectroly()
            sliderNum.value = sliderNum.value
            actionBtn?.backgroundColor = UIColor.colorFromRGB(0x49BBFF)
            actionBtn?.setTitle(Language.getString("开始电解"), for: .normal)
            self.slider.isEnabled = true
            _timer?.invalidate()
        }
    }
    
    @IBAction func onClickReturn()
    {
        let vc =  R.storyboard.main.deviceList()
//        self.show(vc!, sender: nil)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func startElectroly()
    {
        startElectrolyTime = Date().timeIntervalSince1970
        electrolyTime = TimeInterval(sliderNum.value * 60)
        UserDefaults.standard.set(startElectrolyTime, forKey: "startElectrolyTime")
        UserDefaults.standard.set(electrolyTime, forKey: "electrolyTime")
        BLEController.shared.setTimeOutEle(time: electrolyTime)
        WifiController.shared.setTimeOutEle(time: electrolyTime)
        let lastElectrolyTime = UserDefaults.standard.value(forKey: "lastElectrolyTime") as? Int ?? 0
        if Int(Date().timeIntervalSince1970) - Int(lastElectrolyTime) > 300
        {
            determineMyLocation()
            _ = Wolf.request(type: MyAPI.drink(target: targetOfDrink), completion: { (info: OneDrinks?, msg, code) in
                if(code == "0")
                {
                    let t_d =  myClientVo?.drinks ?? 0
                    myClientVo?.drinks = t_d + (info != nil ? info!.count! : 0);
                    self.getTodayDrinks()
                    refreshUserData(completion: {_ in })
                }
            }, failure: nil)
        }
        UserDefaults.standard.set(Int(startElectrolyTime), forKey: "lastElectrolyTime")
    }
    
    func stopElectroly()
    {
        
        startElectrolyFlag = false
        startElectrolyTime = 0
        electrolyTime = 0
        UserDefaults.standard.set(electrolyTime, forKey: "electrolyTime")
        UserDefaults.standard.set(startElectrolyTime, forKey: "startElectrolyTime")
        BLEController.shared.stopTimeOutEle()
        WifiController.shared.stopTimeOutEle()
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
        let time = electrolyTime - (Date().timeIntervalSince1970 - startElectrolyTime)
        
        if(time<=0){
            stopElectroly()
        }else{
            self.timeLabel?.text = "\(String(format: "%02d", Int(time / 60))):\(String(format: "%02d", Int(CGFloat(time).truncatingRemainder(dividingBy: 60))))"
        }
    }

    
}

