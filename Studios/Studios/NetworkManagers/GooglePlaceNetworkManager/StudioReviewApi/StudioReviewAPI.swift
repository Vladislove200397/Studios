//
//  StudioAPI.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 27.11.22.
//

import Foundation
import Moya

enum StudioAPI {
    case getReviews(placeID: String)
}

extension StudioAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://maps.googleapis.com/maps/api/")!
    }
    
    var path: String {
        switch self {
            case .getReviews:
                return "place/details/json"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case.getReviews:
                return .get
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var parameters: [String: Any]? {
        var params = [String: Any]()
        switch self {
            case .getReviews(let placeID):
                params["place_id"] = placeID
                params["fields"] = "reviews"
                params["key"] = Constants.GMSPLACESAPIKEY
                params["language"] = "ru_RU"
        }
        return params
    }
    
    var encoding: ParameterEncoding {
        switch self {
            case .getReviews:
                return URLEncoding.queryString
        }
    }
    var task: Moya.Task {
        guard let parameters else { return .requestPlain}
        return .requestParameters(parameters: parameters, encoding: encoding)
    }
    
    var headers: [String : String]? {
        nil
    }
    
    
}
