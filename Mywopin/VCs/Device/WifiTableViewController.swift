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
    var tipsAlert:UIAlertController?
    var retryPasswordToCup = 2
    
    @IBOutlet weak var selectedSSID: UITextField!
    @IBOutlet weak var wifiPasswordTextField: UITextField!
    
    var sv : UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(internetChanged), name: Notification.Name.reachabilityChanged, object: inetReachability)
    }
    override func viewWillDisappear(_ animated: Bool) {
        
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
                    self.showError(error: error)
                }
                else {
                    if (self.getWifiSsid() == wopinSSID) {
//                        self.showSuccess(msg: "")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { //delay task
                            self.scanNearbyWifi(isPresent: true)
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
    
    func scanNearbyWifi(isPresent : Bool) {
        self.essids.removeAll()
        self.removeSpinner(spinner: self.sv!)
        let alert = UIAlertController(title: nil, message: "请稍候...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        
        //-------------------------------1------------------------------------
        
        let header    = [ "scan" : "1" ]
        Alamofire.request(wopinWifiURL,headers:header).responseString { response in
            print(response)
            if let jsonString = response.result.value {

                do {
                    let newJsonString = "[" + jsonString + "]"
                    let ra = try JSONDecoder().decode([WifiScanResult].self, from: newJsonString.data(using: .utf8)!)
                    for r in ra {
                        print(r.essid);
                        self.essids.append(r.essid)
                    }
                    self.essids.append("手动输入")
                } catch {
                    alert.dismiss(animated: false, completion: nil)
                    self.scanNearbyWifi(isPresent : true)
                    print("scanning wifi fail")
                    print(error)
                    return
                }
                print("Scan Nearby Wifi Success!")
                alert.dismiss(animated: false, completion: nil)

                let vc = R.storyboard.main.wifiScanListVC()
                vc?.wifiTableViewController = self
                vc?.essids = self.essids
                self.present(vc!, animated: true, completion: {
                    self.removeSpinner(spinner: self.sv!)
                })

            }
            else
            {
                alert.dismiss(animated: false, completion: nil)
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
    
    func updateDeviceSetting() {
        
        if let _device_id = self.device_id
        {
            if(!WifiController.shared.savedWifi.contains(_device_id))
            {
                WifiController.shared.savedWifi.append(_device_id)
                UserDefaults.standard.set(WifiController.shared.savedWifi, forKey: "WiFi_list")
            }
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
                self.tipsAlert?.dismiss(animated: false, completion: nil)
                _ = SweetAlert().showAlert("Sorry", subTitle: error?.errorDescription, style: AlertStyle.warning)
            }
        }
        else
        {
            self.tipsAlert?.dismiss(animated: false, completion: nil)
            self.showSuccess(msg: "连接异常，请重试", OkAction: nil)
        }
    }
    
    @objc func internetChanged(note:Notification) {
        print("internetChanged")
        let reachability =  note.object as! InternetReachability
        
        //reachability.isReachable is deprecated, right solution --> connection != .none
        if reachability.connection != .none {
            
            //reachability.isReachableViaWiFi is deprecated, right solution --> connection == .wifi
            if reachability.connection == .wifi {
                if (self.getWifiSsid() != wopinSSID)
                {
                    timer?.invalidate()
                    reachability.stopNotifier()
                    //Wopin AP will be disconnected after the wifi configurtion
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        print("Uploading to server")
                        self.updateDeviceSetting()
                    }
                }
            }
        } else {
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

        timer = setTimeout(delay: 30, block: {
            print("Current connected ssid : \(self.getWifiSsid() ?? ""      )")
            if (self.getWifiSsid() != self.wopinSSID)
            {
                self.updateDeviceSetting()
            }
            else
            {
                self.tipsAlert?.dismiss(animated: false, completion: nil)
                self.showSuccess(msg: "杯子连接网络超时，请确定wifi密码后重试", OkAction: nil)
            }
        })
        
        retryPasswordToCup = 2
        sendPasswordToCup()
    
    }
    
    func sendPasswordToCup()
    {
        print("sendPasswordToCup")
        let ssid = selectedSSID.text
        let password = wifiPasswordTextField.text
        self.sv = self.displaySpinner(onView: self.view)
        let headers = ["Content-Type" : "application/x-www-form-urlencoded",
                       "Accept-Language" : "en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7",
                       "Connection" : "keep-alive",
                       "ssid" : ssid,
                       "password" : password]
        
        let postString = "" //ToDo: Cannot send the post data??? So add the info in header first...
        
        var request = URLRequest(url: URL(string: wopinWifiURL)!)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers as? [String : String]
        request.httpBody = postString.data(using: .utf8)

        //let session = URLSession.shared
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 200
        let session = URLSession(configuration: configuration)
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("sendPasswordToCup Fail")
//                print(error ?? "")
//                if(self.retryPasswordToCup > 1){
//                    Log("retry sendPasswordToCup")
//                    self.retryPasswordToCup -= 1;
//                    self.sendPasswordToCup();
//                }
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? "")
                let httpResponseData = String(data: data!, encoding: .utf8)
                do {
                    let ra = try JSONDecoder().decode(WifiResponse.self, from: (httpResponseData?.data(using: .utf8)!)!)
                    self.removeSpinner(spinner: self.sv!)
                    self.device_id = ra.deviceId
                    
                    if (ra.status == "Connecting")
                    {
                        print(" sendPasswordToCup Connecting \(ra.deviceId)")
                        DispatchQueue.main.async() {
                            
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
                    self.removeSpinner(spinner: self.sv!)
                }
                
            }
        })
        dataTask.resume()
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
    
    private func showError(error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "Darn", style: .default, handler: nil)
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
