//
//  BlogVos.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/9/9.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation


struct BlogPostItem: WolfMapper {
    
    var id:Int
    var author: BlogAuthor?
    var title: String?
    var content:String?
    var date:String?
    var featured_image:String?
    var URL:String?
    var read: Int
    var likes: Int
    var stars: Int
    var comments: Int
    var myLike: Bool
    var myStar: Bool
    
    func didInit() {
    }
}

struct BlogPostDetail: WolfMapper {
    
    var id:Int
    var date:String
    var title: String
    var content:String?
    var URL:String?
    
    func didInit() {
    }
}


struct BlogFollows: WolfMapper {
    
    var userId:String
    var follow:[String]
    
    func didInit() {
    }
}

struct BlogAuthor:Codable {
    var id:String
    var name: String?
    var avatar_URL: String?
}

struct BlogComment: WolfMapper {
    
    var id:Int
    var post:Int
    var parent:Int
    var date:String?
    var content:String?
    var author_name:String?
    var avatar_URL: String?
    var type:String?
    var myLike: Bool
    
    func didInit() {
    }
}

struct FansData: WolfMapper {
    
    var _id:String
    var userName:String
    var icon: String?
    
    func didInit() {
    }
}
