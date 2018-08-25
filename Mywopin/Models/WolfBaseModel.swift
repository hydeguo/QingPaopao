//
//  WolfBaseModel.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/18.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation

struct WolfBaseModel<T: WolfMapper>: WolfMapper {
    
    func didInit() {
    }
    
    var status: String?
    var msg: String?
    var result: T?
}

struct WolfBaseModels<T: WolfMapper>: WolfMapper {
    
    func didInit() {
    }
    
    var status: String?
    var msg: String?
    var result: [T]?
}
