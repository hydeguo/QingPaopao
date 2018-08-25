//
//  JSON_modules.swift
//  OMG_Pro
//
//  Created by Hydeguo on 06/03/2018.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation



struct LoginResponse : Codable {
    var _id:String
    var username:String
    var nickname:String
    var email:String
    var language:String?
    var role:[String]
    var thumbnail:Thumbnail
    var token:String
}

struct Thumbnail : Codable {
    var `default`:String?
}
