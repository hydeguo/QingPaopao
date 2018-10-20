//
//  BLEController.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/23.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation

enum BLE_EVENT:String {
    
    case BLE_scanDeviceRefrash = "BLE_scanDeviceRefrash"
    
    case BLE_didDisconnectDevice = "BLE_didDisconnectDevice"
    
    case BLE_receiveDeviceBattery = "BLE_receiveDeviceBattery"
    
    case BLE_receiveDeviceDataSuccess_1 = "BLE_receiveDeviceDataSuccess_1"
    
    case BLE_connectDeviceSuccess = "BLE_connectDeviceSuccess"
}

public class BLEController:NSObject,BLEManagerDelegate
{
    static let shared:BLEController = BLEController()
    
    var cleanFlag:Bool  = false
    var _timer:Timer?
    var _timer_ele:Timer?
    var savedBLE:[String] = []
    
    #if targetEnvironment(simulator)
    #else
    var bleManager : BLEManager
    var connectedDevice : CBPeripheral?
    var seachList:[DeviceInfo]?
    
    private override init() {
        bleManager = BLEManager.default()
        super.init()
        bleManager.delegate = self
    }
    
    
    #endif
    
    func startAutoConnect()
    {
        #if targetEnvironment(simulator)
        #else
        var p_array:[CBPeripheral] = []
        for uuid in savedBLE {
            
            if let peripheral : CBPeripheral = BLEController.shared.bleManager.getDeviceByUUID(uuid)
            {
                p_array.append(peripheral)
            }
        }
        bleManager.startAutoConnect(p_array)
        #endif
    }
    
    
    func sendCommandToConnectedDevice(_ command: String)
    {
        #if targetEnvironment(simulator)
        #else
        if (connectedDevice != nil) {
            bleManager.sendData(toDevice1: command, device: connectedDevice)
        }
        #endif
    }
    
    
    func isCleaning() -> Bool{
        return _timer?.isValid == true
    }
    
    func setTimeOutClean()
    {
        sendCommandToConnectedDevice(WopinCommand.CLEAN_ON)
        _timer?.invalidate()
        _timer = setTimeout(delay: TimeInterval(cleanTime), block: {
            self.sendCommandToConnectedDevice(WopinCommand.CLEAN_OFF)
        })
    }
    func stopTimeOutClean()
    {
        _timer?.invalidate()
        sendCommandToConnectedDevice(WopinCommand.CLEAN_OFF)
    }
    
    func setTimeOutEle(time:TimeInterval)
    {
        let ele_command = hydroGenTimerCommand(min: Int(time / 60), sec: Int(CGFloat(time).truncatingRemainder(dividingBy: 60)))
        sendCommandToConnectedDevice(ele_command)
    }
    func stopTimeOutEle()
    {
        sendCommandToConnectedDevice(WopinCommand.HYDRO_GEN_OFF)
    }
    
    #if targetEnvironment(simulator)
    #else
    public func connectDeviceSuccess(_ device: CBPeripheral!, error: Error!) {
        
        if let device = device
        {
            cleanFlag =  false
            self._timer?.invalidate()
            self.connectedDevice = device
            print("Device connected ! \(device.name ?? "")")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLE_EVENT.BLE_connectDeviceSuccess.rawValue), object: self, userInfo: ["data":device])
        }
    }
    
    public func scanDeviceRefrash(_ array: NSMutableArray!) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLE_EVENT.BLE_scanDeviceRefrash.rawValue), object: self, userInfo: ["data":array])
    }
    
    public func didDisconnectDevice(_ device: CBPeripheral!, error: Error!) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLE_EVENT.BLE_didDisconnectDevice.rawValue), object: self, userInfo: ["data":device])
        cleanFlag = false
    }
    
    public func receiveDeviceBattery(_ battery: Int, device: CBPeripheral!) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLE_EVENT.BLE_receiveDeviceBattery.rawValue), object: self, userInfo: ["battery":battery,"device":device])
    }
    
    public func receiveDeviceDataSuccess_1(_ data: Data!, device: CBPeripheral!) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: BLE_EVENT.BLE_receiveDeviceDataSuccess_1.rawValue), object: self, userInfo: ["data":data,"device":device])
    }
    #endif
}


func parseCupData(_ dataStr:String)->(a:Character,b:String,c:String)
{
    let index1 = dataStr.index(dataStr.startIndex, offsetBy: 7);

    let indexE1 = dataStr.index(dataStr.startIndex, offsetBy: 8);
    let indexE2 = dataStr.index(dataStr.startIndex, offsetBy: 10);
    let indexE4 = dataStr.index(dataStr.startIndex, offsetBy: 12);
    return ( dataStr[index1],String(dataStr[indexE1..<indexE2]),String(dataStr[indexE2..<indexE4]) )
}
