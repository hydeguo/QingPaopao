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

//MQTT Related
let wopinMqttServer = "wifi.h2popo.com"
let wopinMqttServerPort = 8083
let wopinMqttUsername = "wopin"
let wopinMqttPassword = "wopinH2popo"

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

public class WifiController : NSObject, CocoaMQTTDelegate
{
    static let shared:WifiController = WifiController()
    
    var savedWifi : [String] = []
    var mqtt : CocoaMQTT?
    
    private override init() {
        super.init()
        DispatchQueue.main.async {
            let clientID = "iOS"   // ToDo: Use unique iPhone device id here ?
            self.mqtt = CocoaMQTT(clientID: clientID, host: wopinMqttServer, port: UInt16(wopinMqttServerPort))
            self.mqtt!.username = wopinMqttUsername
            self.mqtt!.password = wopinMqttPassword
            self.mqtt!.keepAlive = 60
            self.mqtt!.delegate = self
            self.mqtt?.connect()
        }
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
        for uuid in savedWifi {
            if (on) {
                mqtt?.publish(uuid, withString: "021" + timeString)
            } else {
                mqtt?.publish(uuid, withString: "02000000")
            }
        }
    }
    
    func sendRGBCommandToWopin(r: Int, g: Int, b: Int) {
        let code = wopinWifiLEDCommand(r: r, g: g, b: b)
        for uuid in savedWifi {
            mqtt?.publish(uuid, withString: code)
        }
    }
    
    func wopinWifiLEDCommand(r: Int, g: Int, b: Int) -> String {
        let red_val = String(format:"%02X", r)
        let green_val  = String(format:"%02X", g)
        let blue_val = String(format:"%02X", b)
        return "01" + red_val + green_val + blue_val
    }
    
    func subscribeWopinWifiDevice(uuid : String) {
        mqtt?.subscribe(uuid)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("didConnectAck")
        startAutoConnect()
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        print("didStateChangeTo")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("didReceiveMessage " + message.topic + " " + message.string!)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic " + topic)
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic")
    }
    
    public func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("mqttDidPing")
    }
    
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("mqttDidReceivePong")
    }
    
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("mqttDidDisconnect")
    }
}
