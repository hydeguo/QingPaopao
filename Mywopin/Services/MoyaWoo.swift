//
//  MoyaWoo.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/22.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation


import Moya


//enum BLE_EVENT:String {
//
//    case BLE_scanDeviceRefrash = "BLE_scanDeviceRefrash"
//
//    case BLE_didDisconnectDevice = "BLE_didDisconnectDevice"
//
//    case BLE_receiveDeviceBattery = "BLE_receiveDeviceBattery"
//
//    case BLE_receiveDeviceDataSuccess_1 = "BLE_receiveDeviceDataSuccess_1"
//
//    case BLE_connectDeviceSuccess = "BLE_connectDeviceSuccess"
//}
enum WooAPI {

    case getExchangeGoods()
    case getExchangeCategory
    case getExchangeOldProducts
    case getScoresGoods()
    case getScoresCategory
    
    case updateProduceStock(id:Int,target:Int)  // 无效
}


extension WooAPI: TargetType,AccessTokenAuthorizable {
    var authorizationType: AuthorizationType {
        switch self {
        
        default:
            return .basic
        }
    }
    
    
    var task: Task {
        switch self {
      
        case .getExchangeGoods:
            return .requestParameters(parameters:["consumer_key" : wooConsumerKey, "consumer_secret" : wooConsumerSecret,"category":16], encoding: URLEncoding.default)
        case .getExchangeOldProducts:
            return .requestParameters(parameters:["consumer_key" : wooConsumerKey, "consumer_secret" : wooConsumerSecret,"category":19], encoding: URLEncoding.default)
        case .updateProduceStock(_,let target):
            return .requestParameters(parameters:["consumer_key" : wooConsumerWriteKey, "consumer_secret" : wooConsumerWriteSecret,"username" : wooConsumerWriteKey, "password" : wooConsumerWriteSecret,"stock_quantity":target], encoding: URLEncoding.default)
        case .getScoresGoods:
            return .requestParameters(parameters:["consumer_key" : wooConsumerKey, "consumer_secret" : wooConsumerSecret,"category":20], encoding: URLEncoding.default)
        default:
            return .requestParameters(parameters:["consumer_key" : wooConsumerKey, "consumer_secret" : wooConsumerSecret], encoding: URLEncoding.default)
        }
    }
    
    
    var headers: [String : String]? {
        switch self {
        case .updateProduceStock:
            return ["Authorization":"Basic"]
        default:
            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding { return URLEncoding.default }
    
    public var baseURL: URL { return URL(string:  wooSiteURL)! }
    
    public var path: String {
        switch self {
        case .getExchangeGoods, .getExchangeOldProducts,.getScoresGoods:
            return "/wp-json/wc/v2/products"
        case .getExchangeCategory:
            return "/wp-json/wc/v2/products/categories/16"
        case .getScoresCategory:
            return "/wp-json/wc/v2/products/categories/20"
        case .updateProduceStock(let id,_):
            return "/wp-json/wc/v2/products/\(id)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .updateProduceStock:
            return .post
        default:
            return .get
        }
    }
    var parameters: [String: Any]? {
        switch self {
        case .updateProduceStock( _,let target):
            return ["consumer_key" : wooConsumerWriteKey, "consumer_secret" : wooConsumerWriteSecret,"stock_quantity":target]
        default:
            return [:]
        }
        
    }
    
    public var validate: Bool {
        return false
    }
    
    public var sampleData: Data {
        return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
    }
}
