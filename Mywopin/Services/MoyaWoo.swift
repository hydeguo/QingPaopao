//
//  MoyaWoo.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/22.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation


import Moya



enum WooAPI {

    case getExchangeGoods()
    case getExchangeCategory    // for main image
    case getExchangeOldProducts
    case getScoresGoods()
    case getNumerousGoods()
    case getScoresCategory  // for main image
    case getNumerousCategory    // for main image
    
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
        case .getNumerousGoods:
            return .requestParameters(parameters:["consumer_key" : wooConsumerKey, "consumer_secret" : wooConsumerSecret,"category":28], encoding: URLEncoding.default)
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
        case .getExchangeGoods, .getExchangeOldProducts,.getScoresGoods,.getNumerousGoods:
            return "/wp-json/wc/v2/products"
        case .getExchangeCategory:
            return "/wp-json/wc/v2/products/categories/16"
        case .getScoresCategory:
            return "/wp-json/wc/v2/products/categories/20"
        case .getNumerousCategory:
            return "/wp-json/wc/v2/products/categories/28"
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
