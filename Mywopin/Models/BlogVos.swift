//
//  BlogVos.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/9/9.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation


struct BaseBlogPost: WolfMapper {
    
    var id: Double
    var likes: [String]?
    var comments: Double?
    var collect: [String]?
    
    func didInit() {
    }
}



struct BaseBlogComment: WolfMapper {
    
    var id: Double
    var likes: [String]?
    
    func didInit() {
    }
}

