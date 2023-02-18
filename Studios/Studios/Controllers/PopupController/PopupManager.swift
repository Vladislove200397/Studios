//
//  PopupManager.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 15.02.23.
//

import UIKit

class PopupManager {
    func showPopup(controller: UIViewController, configure: PopUpConfiguration, complition: VoidBlock? = nil, discard: VoidBlock? = nil) {
        let pop = PopUpController(
            confirmHandler: complition,
            dismissHandler: discard,
            config: configure)
        
        controller.present(pop, animated: true)
    }
}
