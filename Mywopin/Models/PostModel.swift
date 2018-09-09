//
//  PostModel.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/9/2.
//  Copyright © 2018 Wopin. All rights reserved.
//

import Foundation


struct PostList:Codable {
    var found:Int
    var posts:[PostItem]
}

struct PostItem: Codable {

    var ID:Int
    var title: String?
    var date:String?
    var featured_image:String?
    var author:Author?
    var URL:Author?
}


struct Author:Codable {
    var ID:Int
    var login: String?
    var name: String?
    var nice_name: String?
    var avatar_URL: String?
    var profile_URL: String?
}


struct CommentList:Codable {
    var found:Int
    var site_ID:Int?
    var comments:[CommentItem]
}

struct CommentItem: Codable {
    
    var ID:Int
    var date:String?
    var content:String?
    var author:Author?
    var parent:CommentParent?
}

struct CommentParent:Codable {
    var ID:Int
    var type: String?
    var link: String?
}
