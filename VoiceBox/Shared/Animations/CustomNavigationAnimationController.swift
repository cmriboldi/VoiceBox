//
//  CustomNavigationAnimationController.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 2/12/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

protocol CircleTransitionable {
    var triggerButton: UIButton { get }
    var contentTextView: UITextView { get }
    var mainView: UIView { get }
}

class CustomNavigationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    weak var context: UIViewControllerContextTransitioning?
    var reverse: Bool = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? CircleTransitionable,
            let toVC = transitionContext.viewController(forKey: .to) as? CircleTransitionable,
            let snapshot = fromVC.mainView.snapshotView(afterScreenUpdates: false) else {
                transitionContext.completeTransition(false)
                return
        }
        
        context = transitionContext

        let containerView = transitionContext.containerView
        containerView.addSubview(snapshot)
        fromVC.mainView.removeFromSuperview()
        
        animateOldTextOffscreen(fromView: snapshot)
        
//        containerView.addSubview(toVC.mainView)
        animate(toView: toVC.mainView, fromTriggerButton: fromVC.triggerButton)
        animateToTextView(toTextView: toVC.contentTextView, fromTriggerButton: fromVC.triggerButton)
    }
    
    func animateOldTextOffscreen(fromView: UIView) {
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: [.curveEaseIn],
                       animations: {
                        fromView.center = CGPoint(x: fromView.center.x - 2000,
                                                  y: fromView.center.y + 2000)
                        fromView.transform = CGAffineTransform(scaleX: 5.0, y: 5.0)
        }, completion: nil)
    }
    
    func animate(toView: UIView, fromTriggerButton triggerButton: UIButton) {
        let rect = CGRect(x: triggerButton.frame.origin.x,
                          y: triggerButton.frame.origin.y,
                          width: triggerButton.frame.width,
                          height: triggerButton.frame.width)

        let circleMaskPathInitial = UIBezierPath(ovalIn: rect)
        let fullHeight = toView.bounds.height
        let extremePoint = CGPoint(x: triggerButton.center.x,
                                   y: triggerButton.center.y - fullHeight)

        let radius = sqrt((extremePoint.x*extremePoint.x) +
            (extremePoint.y*extremePoint.y))

        let circleMaskPathFinal = UIBezierPath(ovalIn: triggerButton.frame.insetBy(dx: -radius, dy: -radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.cgPath
        toView.layer.mask = maskLayer
        
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
        maskLayerAnimation.duration = 0.15
        maskLayerAnimation.delegate = self
        maskLayer.add(maskLayerAnimation, forKey: "path")
    }
    
    func animateToTextView(toTextView: UIView, fromTriggerButton: UIButton) {
        let originalCenter = toTextView.center
        toTextView.alpha = 0.0
        toTextView.center = fromTriggerButton.center
        toTextView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.25, delay: 0.1, options: [.curveEaseOut], animations: {
            toTextView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            toTextView.center = originalCenter
            toTextView.alpha = 1.0
        }, completion: nil)
    }
}

extension CustomNavigationAnimationController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        context?.completeTransition(true)
    }
}
