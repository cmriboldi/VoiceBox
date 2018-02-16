//
//  UINavigationController+completion.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 2/16/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

extension UINavigationController {
    public func pushViewController( _ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        
        pushViewController(viewController, animated: animated)
        
        guard animated, let coordinator = transitionCoordinator else {
            completion()
            return
        }
        
        coordinator.animate(alongsideTransition: nil) { _ in completion() }
    }
}
