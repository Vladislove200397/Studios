//
//  StudioReviewProvider.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 27.11.22.
//

import Foundation
import Moya
import Moya_ObjectMapper

final class StudioReviewProvider {
    private let provider = MoyaProvider<StudioAPI>(plugins: [NetworkLoggerPlugin()])
    
    func getReview(placeID: String, succed:  ((ReviewModel) -> Void)?, failure: (() -> Void)? = nil) {
        provider.request(.getReviews(placeID: placeID)) { result in
            switch result {
                case .success(let response):
                    guard let result = try? response.mapObject(ReviewModel.self) else { return }
                    succed?(result)
                case .failure(let error):
                    print(error.localizedDescription)
                    failure?()
            }
        }
    }
}
