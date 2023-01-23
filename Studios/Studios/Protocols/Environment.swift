//
//  Environment.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 12.12.22.
//

import Foundation
import UIKit

struct Environment {
    static var scenDelegate: SceneDelegate? {
        let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        
        return scene
    }
}

