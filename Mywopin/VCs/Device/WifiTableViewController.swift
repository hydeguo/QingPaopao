//
//  WifiTableViewController.swift
//  Mywopin
//
//  Created by Emil on 1/8/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import UIKit
import NetworkExtension
import SystemConfiguration.CaptiveNetwork
import Moya
import Alamofire

#if targetEnvironment(simulator)
class WifiTableViewController: UITableViewController {}
#else
import QRCodeReader

class WifiTableViewController: UITableViewController, QRCodeReaderViewControllerDelegate,UITextFieldDelegate {
    
    let inetReachability = InternetReachability()!
    var essids = [String]()
    var device_id : String?
    var wopinSSID = ""
    var timer:Timer?
    var timerSendPw:Timer?
    var timerCheckWifi:Timer?
    var tipsAlert:UIAlertController?
    var tipsAlertForWaitSSID:UIAlertController?
    var retryPasswordToCup = 1000
    var retryConnectAPSeconds:Double = 50
    var retryConnectAPtime = Date().timeIntervalSince1970
    
    var selectedSSIDFlag:Bool = false
    @IBOutlet weak var wifiPasswordTextField: UITextField!
    @IBOutlet weak var selectedSSID: UITextField!
    
    var sv : UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: Notification.Name.reachabilityChanged, object: inetReachability)
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveWifiDeviceData), name: NSNotification.Name(rawValue: WIFI_EVENT.WIFI_POWER.rawValue), object: nil)
        timer?.invalidate()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.retryPasswordToCup = 0
        timer?.invalidate()
        timerCheckWifi?.invalidate()
        timerCheckWifi = nil
        inetReachability.stopNotifier()
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedSSID.delegate = self
        wifiPasswordTextField.delegate = self
        scanQRcode(UIButton())
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    private func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()
    
    //-------------------QRCodeReaderViewControllerDelegate------------------------------
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        self.dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func scanQRcode(_ sender: Any) {
        readerVC.delegate = self
        var wopinPW = ""
        
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            print(result ?? "")
            print(result?.value ?? "")
            var wifiInfo = result?.value.split(separator: ";")
            if (wifiInfo?.count == 3)
            {
                self.wopinSSID = String(wifiInfo![0])
                self.wopinSSID.removeFirst(7)
                wopinPW = String(wifiInfo![2])
                wopinPW.removeFirst(2)
            }
            print("connecting to \(self.wopinSSID) with password \(wopinPW)")
            self.sv = self.displaySpinner(onView: self.view)
            self.retryConnectAPtime = Date().timeIntervalSince1970
            self.connectToWpoinWifi(wopinSSID : self.wopinSSID, wopinPW: wopinPW)
        }
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    private func connectToWpoinWifi(wopinSSID : String, wopinPW : String) {
        if #available(iOS 11.0, *) {
            
            let hotspotConfig = NEHotspotConfiguration(ssid: wopinSSID, passphrase: wopinPW, isWEP: false)
            hotspotConfig.joinOnce = false
            NEHotspotConfigurationManager.shared.apply(hotspotConfig) {[unowned self] (error) in
                
                if let error = error {
                    if Date().timeIntervalSince1970 - self.retryConnectAPtime  < self.retryConnectAPSeconds {
                        self.connectToWpoinWifi(wopinSSID : self.wopinSSID, wopinPW: wopinPW)
                    }else{
                        self.showError(error: error, completion: { _ in
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                }
                else {
                    if (self.getWifiSsid() == wopinSSID) {
//                        self.showSuccess(msg: "")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { //delay task
                            self.reSelectWifiList()
                        }
                        
                    } else {
                        self.removeSpinner(spinner: self.sv!)
                    }
                }
                
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func disconnectWopoinWifiAction() {
        let headers = ["Content-Type" : "application/x-www-form-urlencoded",
                       "Accept-Language" : "en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7",
                       "Connection" : "keep-alive",
                       "end" : "1"]
        
        let postString = "" //ToDo: Cannot send the post data??? So add the info in header first...
        var request = URLRequest(url: URL(string: wopinWifiURL)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "")
            }
        })
        dataTask.resume()
    }
    
    private func getWifiSsid() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
    @IBAction func reSelectWifiList(){

        self.retryConnectAPtime = Date().timeIntervalSince1970
        self.essids.removeAll()
        self.scanNearbyWifi(isPresent: true)
        self.selectedSSIDFlag = false
        timerSendPw?.invalidate()
        timerSendPw = setInterval(interval: 4, block: {
            self.scanNearbyWifi(isPresent: true)
        })
    }
    
  
    func scanNearbyWifi(isPresent : Bool) {
        self.essids.removeAll()
        self.removeSpinner(spinner: self.sv!)
        
        if tipsAlertForWaitSSID == nil{
            let alert = UIAlertController(title: nil, message: "请稍候...", preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: true, completion: nil)
            tipsAlertForWaitSSID = alert
        }else if tipsAlertForWaitSSID?.view.superview == nil{
            present(tipsAlertForWaitSSID!, animated: true, completion: nil)
        }
        
        //-------------------------------1------------------------------------
        
        let header    = [ "scan" : "1" ]
        Alamofire.request(wopinWifiURL,headers:header).responseString { response in
            print(response)
            
            
            
            if let jsonString = response.result.value,self.selectedSSIDFlag == false {
                
                let subarr = jsonString.components(separatedBy: ",\n")
                self.essids.removeAll()
                for r in subarr {
                    do {
                        let itemStr = r.removeSpacesAndNewlines()
                        let ra = try JSONDecoder().decode(WifiScanResult.self, from: itemStr.data(using: .utf8)!)
                        if let essid = ra.essid
                        {
                            self.essids.append(essid)
                        }
                    } catch {
                        
                    }
                }
                
                if self.essids.count == 0 , Date().timeIntervalSince1970 - self.retryConnectAPtime  < self.retryConnectAPSeconds {
                    return
                }
                
                self.timerSendPw?.invalidate()
                
                self.essids.append("手动输入")
                print("Scan Nearby Wifi Success!")
                self.tipsAlertForWaitSSID?.dismiss(animated: false, completion: nil)

                let vc = R.storyboard.main.wifiScanListVC()
                vc?.wifiTableViewController = self
                vc?.essids = self.essids
                self.present(vc!, animated: true, completion: {
                    self.removeSpinner(spinner: self.sv!)
                })

            }
        }
        
        
        //-------------------------------2------------------------------------
        
//        let headers = ["Content-Type" : "application/x-www-form-urlencoded",
//                       "Accept-Language" : "en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7",
//                       "Connection" : "keep-alive",
//                       "scan" : "1"]
//
//        let postString = "" //ToDo: Cannot send the post data
//
//        var request = URLRequest(url: URL(string: wopinWifiURL)!)
//
//        request.httpMethod = "GET"
//        request.allHTTPHeaderFields = headers
//        request.httpBody = postString.data(using: .utf8)
//        print("Scanning wifi...")
//        let configuration = URLSessionConfiguration.default
//        configuration.timeoutIntervalForRequest = 15
//        let session = URLSession(configuration: configuration)
//        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
//            if (error != nil) {
//                print("scanning wifi fail")
//                alert.dismiss(animated: false, completion: nil)
//                self.scanNearbyWifi(isPresent : true)
//            } else {
//                do {
////                    let httpResponse = response as? HTTPURLResponse
//                    var jsonString = ""
//                    if let httpResponseData = String(data: data!, encoding: .utf8)
//                    {
//                        Log(httpResponseData)
//                        jsonString = String((httpResponseData.dropLast() ))
//                    }
//                    else if let httpResponseData2 = String(data: data!, encoding: .ascii)
//                    {
//                        Log(httpResponseData2)
//                        jsonString = String((httpResponseData2.dropLast() ))
//                    }
//                    jsonString = "[" + jsonString + "]"
//                    let ra = try JSONDecoder().decode([WifiScanResult].self, from: jsonString.data(using: .utf8)!)
//                    for r in ra {
//                        print(r.essid);
//                        self.essids.append(r.essid)
//                    }
//                    self.essids.append("手动输入")
//                } catch {
//                    print(error)
//                }
//                print("Scan Nearby Wifi Success!")
//                alert.dismiss(animated: false, completion: nil)
//
//                let vc = R.storyboard.main.wifiScanListVC()
//                vc?.wifiTableViewController = self
//                vc?.essids = self.essids
//                self.present(vc!, animated: true, completion: {
//                    self.removeSpinner(spinner: self.sv!)
//                })
//
//            }
//        })
//
//        dataTask.resume()
    }
    
    var retryUpdateDevice = 10
    func updateDeviceSetting() {
        
        if let _device_id = self.device_id
        {
            if(!WifiController.shared.savedWifi.contains(_device_id))
            {
                WifiController.shared.savedWifi.append(_device_id)
            }
            UserDefaults.standard.set(WifiController.shared.savedWifi, forKey: "WiFi_list")
            WifiController.shared.reconnect()
            _ = Wolf.request(type: MyAPI.addOrUpdateACup(type: DeviceTypeWifi, uuid: _device_id, name: _device_id, add: true), completion: { (user: User?, msg, code) in
                
                self.tipsAlert?.dismiss(animated: false, completion: nil)
                if(code == "0")
                {
                    myClientVo = user
                    let detail_info_vc = R.storyboard.main.deviceInfo()
                    detail_info_vc?.onSetData(info: CupItem(type: DeviceTypeWifi, name: _device_id, uuid: _device_id, color :0, firstRegisterTime: "", registerTime: "", userId: myClientVo?._id, produceScores: 0))
                    self.show(detail_info_vc!, sender: nil)
                }
                else
                {
                    _ = SweetAlert().showAlert("Sorry", subTitle: msg, style: AlertStyle.warning)
                }
            }) { (error) in
                if self.retryUpdateDevice > 0{
                    self.retryUpdateDevice -= 1
                    _=setTimeout(delay: 3, block: {
                        self.updateDeviceSetting()
                    })
                }else{
                    self.tipsAlert?.dismiss(animated: false, completion: nil)
                    _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
                }
            }
        }
        else
        {
            self.tipsAlert?.dismiss(animated: false, completion: nil)
            self.showSuccess(msg: "连接异常，请重试", OkAction: nil)
        }
    }
    
    @objc func onReceiveWifiDeviceData(_ notice:Notification){
        
        if let cupId:String=(notice as NSNotification).userInfo!["device"] as? String, cupId == self.device_id{
            newCupConected()
        }
    }
    
    @objc func internetChanged(note:Notification) {
        print("internetChanged")
        let reachability =  note.object as! InternetReachability
        
        //reachability.isReachable is deprecated, right solution --> connection != .none
        if reachability.connection != .none {
            
            //reachability.isReachableViaWiFi is deprecated, right solution --> connection == .wifi
            if reachability.connection == .wifi {
                if (self.getWifiSsid() != wopinSSID && self.device_id != nil)
                {
                    newCupConected()
                }
            }
        } else {
        }
    }
    
    private func newCupConected(){
        
        timer?.invalidate()
        timerCheckWifi?.invalidate()
        timerCheckWifi = nil
        inetReachability.stopNotifier()
        //Wopin AP will be disconnected after the wifi configurtion
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Uploading to server")
            self.updateDeviceSetting()
        }
    }
    
    @IBAction func linkWifiWopin(_ sender: Any) {
        if (selectedSSID.text?.count == 0 || wifiPasswordTextField.text?.count == 0)
        {
            let alert = UIAlertController(title: "Missing ssid or password", message: "It's recommended check the inputs", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        do {
            try inetReachability.startNotifier()
        } catch {
            print("Could not start notifier")
        }

        timer?.invalidate()
        timer = setTimeout(delay: 60, block: {
            print("Current connected ssid : \(self.getWifiSsid() ?? ""      )")
            self.retryPasswordToCup = 0
            if (self.getWifiSsid() != self.wopinSSID  && self.device_id != nil)
            {
                self.updateDeviceSetting()
            }
            else
            {
                self.tipsAlert?.dismiss(animated: false, completion: nil)
                self.showSuccess(msg: "杯子连接网络超时，请确定wifi密码后重试", OkAction: nil)
            }
        })
        
        retryPasswordToCup = 1000
        
        self.sendPasswordToCup()
        self.timerSendPw?.invalidate()
        timerSendPw = setInterval(interval: 5, block: {
            if (self.retryPasswordToCup != 0) {
                self.sendPasswordToCup()
            }else{
                self.timerSendPw?.invalidate()
            }
        })
    }
    
    func sendPasswordToCup()
    {
        print("sendPasswordToCup")
        let ssid = selectedSSID.text
        let password = wifiPasswordTextField.text
        self.sv?.removeFromSuperview()
        if self.tipsAlert?.view.superview == nil{
            self.sv = self.displaySpinner(onView: self.view)
        }
        
        let headers = ["Content-Type" : "application/x-www-form-urlencoded",
                       "Accept-Language" : "en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7",
                       "Connection" : "keep-alive",
                       "ssid" : ssid,
                       "password" : password]
        
        Alamofire.request(wopinWifiURL, method: .post, parameters: nil, encoding: URLEncoding.default, headers: headers as? HTTPHeaders).responseString { response in
        
            if let jsonString = response.result.value {
                do {
                    let ra = try JSONDecoder().decode(WifiResponse.self, from: (jsonString.data(using: .utf8)!))
                    self.removeSpinner(spinner: self.sv!)
                    self.device_id = ra.deviceId
                    self.timerSendPw?.invalidate()
                    
                    if(!WifiController.shared.savedWifi.contains(ra.deviceId))
                    {
                        WifiController.shared.savedWifi.append(ra.deviceId)
                    }
                    if (ra.status == "Connecting")
                    {
                        print(" sendPasswordToCup Connecting \(ra.deviceId)")
                        if self.timerCheckWifi == nil{
                            self.timerCheckWifi = setInterval(interval: 3, block: {
                                if (self.getWifiSsid() != self.wopinSSID  && self.device_id != nil)
                                {
                                    self.newCupConected()
                                }
                            })
                        }
                        DispatchQueue.main.async() {
                            
                            self.sv?.removeFromSuperview()
                            self.tipsAlert?.dismiss(animated: false, completion: nil)
                            self.tipsAlert = UIAlertController(title: nil, message: "设备连接网络中...", preferredStyle: .alert)
                            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                            loadingIndicator.hidesWhenStopped = true
                            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                            loadingIndicator.startAnimating();
                            self.tipsAlert?.view.addSubview(loadingIndicator)
                            self.present(self.tipsAlert!, animated: true, completion: nil)
                        }
                    }
                } catch {
                    print(error)
                    //                    self.removeSpinner(spinner: self.sv!)
                }
            }
        }
        
    }

    @IBAction func disconnectWopinWifi(_ sender: Any) {
        let headers = ["Content-Type" : "application/x-www-form-urlencoded",
                       "Accept-Language" : "en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7",
                       "Connection" : "keep-alive",
                       "end" : "1"]
        
        let postString = "" //ToDo: Cannot send the post data??? So add the info in header first...
        var request = URLRequest(url: URL(string: wopinWifiURL)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers 
        request.httpBody = postString.data(using: .utf8)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "")
            }
        })
        dataTask.resume()
    }
    
    private func showError(error: Error,completion:((UIAlertAction)->Void)?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "Darn", style: .default, handler: completion)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showSuccess(msg: String,OkAction:(()->Void)?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: msg , preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
                if(OkAction != nil){OkAction!()}
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
#endif
