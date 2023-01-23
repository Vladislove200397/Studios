//
//  Service.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 13.11.22.
//

import Foundation
import UIKit
import GooglePlaces

class Service {
    static let shared = Service()
    
    var studios = [GMSPlace]()
    var photos = [UIImage]()
    var alert = Alerts()
}
