

import Foundation
import UIKit


let server_url = "http://wifi.h2popo.com:8081"
//let server_host = "172.17.1.46"//"nvtest.onwardsmg.net"//“nvvc.onwardsmg.net”

let wooSiteURL = "https://wifi.h2popo.com"
let wooConsumerKey = "ck_ba448661d94412faeaf3b8ab899b9294a967865c"
let wooConsumerSecret = "cs_45a5c655c2b07589e93a0466674af4afd4ef4abe"

let wooConsumerWriteKey = "ck_7db681ac326401f87ec0a9ce564e45e2ef678f06"
let wooConsumerWriteSecret = "cs_322de70d9956c27899eee79e97dedb6a403e8781"

var fb_token = ""
var myClientVo:User?
var myThirdpartyVo:SSDKUser?
var orderStatusArr = ["等待付款", "待发货", "已发货"];
var cup_list = [CupItem]()
//var video_list = [JSON]()
var strDeviceToken : String = ""

var ratio:CGFloat = 1.33333
var light_blue = UIColor(red:238/255.0, green:250/255.0, blue:255/255.0, alpha: 1)
var title_color = UIColor(red:41/255.0, green:47/255.0, blue:51/255.0, alpha: 1)
var main_color = UIColor(red: 93/255.0, green: 218/255.0, blue: 255/255.0, alpha: 1.0)

var cleanTime:TimeInterval = 300
//var startCleanTime:TimeInterval = 0

//var electrolyTime:TimeInterval = 300

var switchNotice:Bool = true
var switchShake:Bool = true
var switchShine:Bool = true

var targetOfDrink :Int = 8
var todayDrinks :OneDayDrinks?


var exchangeGoods:[ExchangeGoodsItem]?
func getExchangeGoodsById(id:String)->ExchangeGoodsItem?
{
    if let goodsList = exchangeGoods
    {
        for item in goodsList {
            if item.productId == id{
                return item
            }
        }
    }
    return nil
}

var selectedAddress:AddressItem?
func getDefaultAddress()->AddressItem?
{
    if let myVo = myClientVo
    {
        for item in myVo.addressList ?? [] {
            if item.isDefault == true{
                return item
            }
        }
    }
    return nil
}

var idStr:String{
    get{
        return  myClientVo?._id ?? ""
    }
}

func getLocalData()
{
//    if let s_clean_time = UserDefaults.standard.value(forKey: "\(idStr) startCleanTime")
//    {
//        startCleanTime = s_clean_time as! TimeInterval
//    }
//    if let s_ElectrolyTime = UserDefaults.standard.value(forKey: "\(idStr) startElectrolyTime")
//    {
//        startElectrolyTime = s_ElectrolyTime as! TimeInterval
//    }
//    if let eleTime = UserDefaults.standard.value(forKey: "\(idStr) electrolyTime")
//    {
//        electrolyTime = eleTime as! TimeInterval
//    }
    if let ble_list = UserDefaults.standard.array(forKey: "\(idStr) BLE_list")
    {
        BLEController.shared.savedBLE = ble_list as! [String]
        BLEController.shared.startAutoConnect()
    }
    if let notice = UserDefaults.standard.value(forKey: "\(idStr) notice")
    {
        switchNotice = notice as! Bool
    }
    if let shake = UserDefaults.standard.value(forKey: "\(idStr) shake")
    {
        switchShake = shake as! Bool
    }
}
