//
//  Vos.swift
//  OMG_Pro
//
//  Created by Hydeguo on 05/03/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation


public class ClientVo {
    
    public var id:String
    public var name:String
    public var email:String
    public var picUrl:String
    public var largePicUrl:String
//    public var myReserveList:[ReserveRs] = [ReserveRs]()
    
    init(id:String,name:String,email:String)
    {
        self.id = id
        self.name = name
        self.email = email
        self.picUrl = "http://graph.facebook.com/\(id)/picture?type=square"
        self.largePicUrl = "http://graph.facebook.com/\(id)/picture?type=large"
    }
}

struct BaseReponse: WolfMapper {
    func didInit() {
    }
}

struct ThirdpartLogin: WolfMapper {
    var _id: String
    var uId: String
    var thirdKey: String
    var thirdType: String
    var __v:Double?
    func didInit() {
    }
}

struct User: WolfMapper {
  
    var _id: String
    var userName: String?
    var userPwd: String?
    var icon: String?
    var phone: Double?
    var scores: Double?
    var lastAttendance: String?
    var drinks: Double?
    var fansList: [String]?
    var followList: [String]?
    var profiles:Profiles?
    var exchangeOrderList: [String]?
    var creditsOrderList: [String]?
    var crowdfundingOrderList: [String]?
    var cartList:[CartItem]?
    var addressList: [AddressItem]?
    
    func didInit() {
        debugPrint("didInt")
    }
}

struct Profiles: Codable {

    
    var height: Double?
    var weight: Double?
    var age: Double?
    var blood_sugar_full: Double?
    var blood_sugar_hugry: Double?
    var blood_lipid_all: Double?
    var blood_lipid: Double?
    var blood_lipid_TG: Double?
    var blood_pressure: Double?
    var blood_pressure_press: Double?
    
}
struct DrinkItem: Codable {
    var time: String
}
struct OneDayDrinks: WolfMapper {
    var userId: String?
    var date: String?
    var target: Double?
    var drinks: [DrinkItem]?
    func didInit() {
    }
}
struct OneDrinks: WolfMapper {
    var count: Double?
    func didInit() {
    }
}
struct CrowdfundingPeople: WolfMapper {
    var _id: String?
    var totalPeople: Double?
    
    func didInit() {
        debugPrint("didInt")
    }
}
struct CrowdfundingMoney: WolfMapper {
    var _id: String?
    var totalPrice: Double?
    
    func didInit() {
        debugPrint("didInt")
    }
}
let DeviceTypeBLE = "BLE"
let DeviceTypeWifi = "WIFI"
struct CupItem: WolfMapper {
    func didInit() {
    
    }
    var type: String?
    var name: String?
    var uuid: String
    var firstRegisterTime: String?
    var registerTime: String?
    var userId: String?
    var produceScores: Double?
}
struct AddressItem: Codable {
    
    var addressId: String
    var userName: String
    var address1: String?
    var address2: String?
    var postCode: Double?
    var tel: Int?
    var isDefault: Bool?
    
}

//struct OrderItem: Codable {
//
//    var orderId: String?
//    var orderTotal: Int?
//    var addressId: String?
//    var goodId: Int?
//    var goodNum: Int?
//    var orderStatus: String?
//    var createDate: String?
//
//}

struct ExchangeOrderItem: WolfMapper {
    func didInit() {
    }
    
    var orderId: String
    var userId:String
    var image:String?
    var title:String?
    var address: AddressItem?
    var goodsId: Int
    var num: Int
    var offerPrice: Int?
    var singlePrice: Int
    var expressReturnId: String?
    var expressReturnName: String?
    var expressSendId: String?
    var orderStatus: String?
    var createDate: String?
    
}
struct ExchangeGoodsItem: WolfMapper {
    func didInit() {
    }
    
    var productId: String
    var productName:String
    var exchangetype: String?
    var exchangePrice: Int
    var productImage: String?
    
}
struct CartItem: Codable {
    var productId: String?
    var productNum: Double?
}

struct OrderItem: Codable {
    
    var userId: String?
    var productId: String?
    var productName: String?
    var salePrice: Double?
    var productNum: Double?
    
}


struct ScoresOrderItem: WolfMapper {
    func didInit() {
    }
    
    var orderId: String
    var userId:String
    var image:String?
    var title:String?
    var address: AddressItem?
    var goodsId: Int
    var num: Int
    var singlePrice: Int
    var expressSendId: String?
    var orderStatus: String?
    var createDate: String?
    
}

struct CrowdfundingOrderItem: WolfMapper {
    func didInit() {
    }
    
    var orderId: String
    var userId:String
    var image:String?
    var title:String?
    var address: AddressItem?
    var goodsId: Int
    var num: Int
    var singlePrice: Int
    var expressSendId: String?
    var orderStatus: String?
    var createDate: String?
    
}

