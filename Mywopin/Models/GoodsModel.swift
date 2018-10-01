//
//  GoodsModel.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/7/22.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation


struct WooGoodsItem: WolfMapper {
    func didInit() {
    }
    
    var id: Int
    var name:String
    var type: String
    var description: String
    var short_description:String
    var price:String
    var regular_price:String
    var date_on_sale_from:String?
    var date_on_sale_to:String?
    var sale_price:String
    var images:[MainImage]
    var attributes:[WooAttributes]

}

struct MainImage: Codable {
    
    var id: Int
    var src: String
    var name: String
    var position: Int
}
struct WooAttributes: Codable {
    
    var id: Int
    var name: String
    var position:Int
    var visible: Bool
    var options: [String]
}


struct ExchangeCategory:WolfMapper{
    func didInit() {
    }
    var id: Int
    var name:String
    var description: String
//    var mainImages: [String]?
    
}
