//
//  Post.swift
//  Thred
//
//  Created by Casey Corvino on 12/3/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import Foundation

@objcMembers
class Post: NSObject {
    var ownerId:String?
    var objectId:String?
    var caption:String?
    var hasImage: Bool = false
    var created: Date = Date()
    var commentsStr: String?
    var comments:[String] = []
    var likesStr: String?
    var likes: [String] = [];
}
