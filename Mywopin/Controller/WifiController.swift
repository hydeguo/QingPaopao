//
//  WifiController.swift
//  Mywopin
//
//  Created by Emil on 1/8/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation
import CocoaMQTT
import CoreLocation

//ESP8266 Device Related
let wopinWifiURL = "http://172.16.0.1/wopin_wifi"
let wopin_device_endfix = "-D";   // Publish message to the cup

//MQTT Related
let wopinMqttServer = "wifi.h2popo.com"
let wopinMqttServerPort = 8083
let wopinMqttUsername = "wopin"
let wopinMqttPassword = "wopinH2popo"


enum WIFI_EVENT:String {
    
    case WIFI_POWER = "WIFI_POWER"
    case WIFI_STATUS = "WIFI_STATUS"
    
}

enum WIFI_CUP_MODE:Int {
    case IDLE = 0
    case HYDRO = 1
    case CLEAN = 2
}

struct WifiScanResult: Codable {
    let essid: String
    let bssid: String
    let rssid: String?
    let channel: String?
    
    private enum CodingKeys: String, CodingKey {
        case essid = "essid"
        case bssid = "bssid"
        case rssid = "rssid"
        case channel = "channel"
    }
}

struct WifiResponse: Codable {
    let deviceId: String
    let status: String
    private enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case status = "status"
    }
}

struct LocationData: Codable {
    let deviceId: String
    let time: String
    let lat: Double
    let long: Double
    let link: String
    private enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case time = "time"
        case lat = "lat"
        case long = "long"
        case link = "link"
    }
}

public class OnlineWifiCup: NSObject {
    var uuid:String
    var power:String
    var lastOnline:TimeInterval
    var startCleanFlag:Bool = false
    var doneCleanFlag:Bool = false
    
    init(uuid:String , power:String ,lastOnline:TimeInterval) {
        self.uuid = uuid
        self.power = power
        self.lastOnline = lastOnline
    }
}

public class WifiController : NSObject, CocoaMQTTDelegate
{
    static let shared:WifiController = WifiController()
    
    var savedWifi : [String] = []
    var allOnlineWifiCup : [OnlineWifiCup] = []
    var mqtt : CocoaMQTT?
//    var lastReceiveTime:TimeInterval = 0
//    var mode : WIFI_CUP_MODE = WIFI_CUP_MODE.IDLE
    var selectedId:String?
    
    private override init() {
        super.init()
        DispatchQueue.main.async {
            let clientID = UIDevice.current.identifierForVendor!.uuidString
            self.mqtt = CocoaMQTT(clientID: clientID, host: wopinMqttServer, port: UInt16(wopinMqttServerPort))
            self.mqtt!.username = wopinMqttUsername
            self.mqtt!.password = wopinMqttPassword
            self.mqtt!.keepAlive = 60
            self.mqtt!.delegate = self
            self.mqtt?.connect()
        }
    }
    
    func getWifiCup(uuid:String)->OnlineWifiCup?
    {
        for cup in allOnlineWifiCup {
            if cup.uuid == uuid{
                return cup
            }
        }
        return nil
    }
    
    func getCurrentWifiCup()->OnlineWifiCup?
    {
        for cup in allOnlineWifiCup {
            if cup.uuid == selectedId{
                return cup
            }
        }
        return nil
    }
    
    func startAutoConnect()
    {
        #if targetEnvironment(simulator)
        #else
        for uuid in savedWifi {
            print("uuid is configured " + uuid)
            subscribeWopinWifiDevice(uuid: uuid)
        }
        #endif
    }
    
    func reconnect() {
        mqtt?.disconnect()
        mqtt?.connect()
    }
    
    //ToDo: Add time interval in the firmware
    func setTimeOutEle(time:TimeInterval)
    {
        let secondStr = String(format:"%05X", Int(time))
        sendHydroOnOffCommandToWopin(on: true, timeString: secondStr)
    }
    
    func stopTimeOutEle()
    {
        sendHydroOnOffCommandToWopin(on: false, timeString: "")
    }
    
    func sendHydroOnOffCommandToWopin(on : Bool, timeString: String) {
        if let uuid  = selectedId {
            if (on) {
                mqtt?.publish(uuid + wopin_device_endfix, withString: "021" + timeString)
            } else {
                mqtt?.publish(uuid + wopin_device_endfix, withString: "02000000")
            }
        }
    }
    
    func sendToggleLED(on: Bool) {
        if let  uuid = selectedId {
            if (on) {
                mqtt?.publish(uuid + wopin_device_endfix, withString: "041")
            } else {
                mqtt?.publish(uuid + wopin_device_endfix, withString: "040")
            }
        }
    }
    
    func sendRGBCommandToWopin(r: Int, g: Int, b: Int) {
        let code = wopinWifiLEDCommand(r: r, g: g, b: b)
        if let  uuid = selectedId {
            mqtt?.publish(uuid + wopin_device_endfix, withString: code)
        }
    }
    
    func sendCleanOnOffCommandToWopin(on: Bool) {
        if let  uuid = selectedId {
            if (on) {
                mqtt?.publish(uuid + wopin_device_endfix, withString: "031")
            } else {
                mqtt?.publish(uuid + wopin_device_endfix, withString: "030")
            }
        }
    }
    
    func wopinWifiLEDCommand(r: Int, g: Int, b: Int) -> String {
        let red_val = String(format:"%02X", r)
        let green_val  = String(format:"%02X", g)
        let blue_val = String(format:"%02X", b)
        return "01" + red_val + green_val + blue_val
    }
    
    
    func subscribeWopinWifiDevice(uuid : String) {
        mqtt?.unsubscribe(uuid)
        mqtt?.subscribe(uuid)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAck")
        
        _ = Wolf.requestList(type: MyAPI.cupList, completion: { (cups: [CupItem]?, msg, code) in
            if(code == "0")
            {
                if let cupsItems = cups
                {
                    self.savedWifi = []
                    for cup in cupsItems
                    {
                        if cup.type == DeviceTypeWifi
                        {
                            self.savedWifi.append(cup.uuid)
                        }
                    }
                }
                self.startAutoConnect()
            }
        }, failure: nil)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        print("didStateChangeTo")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        
        if (savedWifi.contains(message.topic)) {
            
            if let msg = message.string
            {
                print("updating device info " + message.topic + " " + msg)
                let resAll = msg.split(separator: ";")
                for resOne in resAll
                {
                    let res = resOne.split(separator: ":")
                    if (res.count > 2)
                    {
                        if (res[0] == "P") {   //Power information
                            Log("\(message.topic) Power: \(res[1])")
                            let power = String(res[1])
                            if(!allOnlineWifiCup.contains(where: { (wifiCup) -> Bool in
                                return wifiCup.uuid == message.topic
                            }))
                            {
                                allOnlineWifiCup.append(OnlineWifiCup(uuid: message.topic, power: power, lastOnline: Date().timeIntervalSince1970))
                            }
                            else
                            {
                                allOnlineWifiCup.forEach { ( wifiCup) in
                                    if(wifiCup.uuid == message.topic){
                                        let cupdata = wifiCup
                                        if  Date().timeIntervalSince1970 - cupdata.lastOnline > 30
                                        {
                                            cupdata.startCleanFlag = false
                                            cupdata.doneCleanFlag = false
                                        }
                                        cupdata.lastOnline = Date().timeIntervalSince1970
                                    }
                                }
                            }
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: WIFI_EVENT.WIFI_POWER.rawValue), object: self, userInfo: ["power":power ,"device":message.topic])
                        }
                    }
                    if (res.count > 4) {
                        
                        if (res[2] == "H") {
                            Log("\(message.topic) Hydro Timer: \(res[3])")
                        }
                        if (res[4] == "M") {
                            Log("\(message.topic) Hydro Mode: \(res[5])")
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: WIFI_EVENT.WIFI_STATUS.rawValue), object: self, userInfo: ["device":message.topic,"H":Int(res[3]) ?? 0 ,"M":String(res[5])])
                    }
                }
            }
        }
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic " + topic)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic" + topic)
    }
    
    public func mqttDidPing(_ mqtt: CocoaMQTT) {
    }
    
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
    }
    
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("mqttDidDisconnect")
        WifiController.shared.reconnect()
    }
}
