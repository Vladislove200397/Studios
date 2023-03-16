//
//  StudioReviewModel.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 27.11.22.
//

import Foundation
import ObjectMapper

final class ReviewModel: Mappable {
    var reviews = [StudioReviewModel]()
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        reviews <- map["result.reviews"]
    }
}

final class StudioReviewModel: Mappable {
    var authorName: String = ""
    var rating: Double = 0.0
    var time: Double = 0.0
    var text: String = ""
    
    required init?(map: ObjectMapper.Map) {
        mapping(map: map)
    }
    
    func mapping(map: ObjectMapper.Map) {
        authorName <- map["author_name"]
        rating     <- map["rating"]
        time       <- map["time"]
        text       <- map["text"]
    }
}


