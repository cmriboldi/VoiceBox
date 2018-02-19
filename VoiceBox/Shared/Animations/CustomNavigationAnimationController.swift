//
//  CustomNavigationAnimationController.swift
//  VoiceBox
//
//  Created by Christian Riboldi on 2/12/18.
//  Copyright © 2018 Christian Riboldi. All rights reserved.
//

import UIKit

protocol GrowTransitionable {
//    var triggerButtonIndex: Int { get }
//    var contentTextView: UITextView { get }
    var mainView: UIView { get }
}

class CustomNavigationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval = 0.5
    
    var operation: UINavigationControllerOperation = .push
    var thumbnailFrame = CGRect.zero
    weak var context: UIViewControllerContextTransitioning?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let presenting = operation == .push

        // Determine which is the master view and which is the detail view that we're navigating to and from. The container view will house the views for transition animation.
        let containerView = transitionContext.containerView
        guard let toView = (transitionContext.viewController(forKey: .to) as? GrowTransitionable)?.mainView else { return }
        guard let fromView = (transitionContext.viewController(forKey: .from) as? GrowTransitionable)?.mainView else { return }
//        guard let fromSnapshot = fromView.snapshotView(afterScreenUpdates: false) else {
//            transitionContext.completeTransition(false)
//            return
//        }
        let currentWordView = presenting ? fromView : toView
        let nextWordView = presenting ? toView : fromView
        
//        containerView.addSubview(fromSnapshot)

        // Determine the starting frame of the detail view for the animation. When we're presenting, the detail view will grow out of the thumbnail frame. When we're dismissing, the detail view will shrink back into that same thumbnail frame.
        var initialFrame = presenting ? thumbnailFrame : nextWordView.frame
        let finalFrame = presenting ? nextWordView.frame : thumbnailFrame

        // Resize the detail view to fit within the thumbnail's frame at the beginning of the push animation and at the end of the pop animation while maintaining it's inherent aspect ratio.
        let initialFrameAspectRatio = initialFrame.width / initialFrame.height
        let nextWordAspectRatio = nextWordView.frame.width / nextWordView.frame.height
        if initialFrameAspectRatio > nextWordAspectRatio {initialFrame.size = CGSize(width: initialFrame.height * nextWordAspectRatio, height: initialFrame.height)}
        else {initialFrame.size = CGSize(width: initialFrame.width, height: initialFrame.width / nextWordAspectRatio)}

        let finalFrameAspectRatio = finalFrame.width / finalFrame.height
        var resizedFinalFrame = finalFrame
        if finalFrameAspectRatio > nextWordAspectRatio {
            resizedFinalFrame.size = CGSize(width: finalFrame.height * nextWordAspectRatio, height: finalFrame.height)
        }
        else {
            resizedFinalFrame.size = CGSize(width: finalFrame.width, height: finalFrame.width / nextWordAspectRatio)
        }

        // Determine how much the detail view needs to grow or shrink.
        let scaleFactor = resizedFinalFrame.width / initialFrame.width
        let growScaleFactor = presenting ? scaleFactor: 1 / scaleFactor
        let shrinkScaleFactor = 1 / growScaleFactor

        if presenting {
            // Shrink the detail view for the initial frame. The detail view will be scaled to CGAffineTransformIdentity below.
            nextWordView.transform = CGAffineTransform(scaleX: shrinkScaleFactor, y: shrinkScaleFactor)
            nextWordView.center = CGPoint(x: thumbnailFrame.midX, y: thumbnailFrame.midY)
            nextWordView.clipsToBounds = true
        }

        // Set the initial state of the alpha for the master and detail views so that we can fade them in and out during the animation.
        nextWordView.alpha = presenting ? 0 : 1
        currentWordView.alpha = presenting ? 1 : 0

        // Add the view that we're transitioning to to the container view that houses the animation.
        containerView.addSubview(toView)
        containerView.bringSubview(toFront: nextWordView)

        // Animate the transition.
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 1.0, options: [.curveEaseIn, .curveEaseOut], animations: {
            // Fade the master and detail views in and out.
            nextWordView.alpha = presenting ? 1 : 0
            currentWordView.alpha = presenting ? 0 : 1

            if presenting {
                // Scale the master view in parallel with the detail view (which will grow to its inherent size). The translation gives the appearance that the anchor point for the zoom is the center of the thumbnail frame.
                let scale = CGAffineTransform(scaleX: growScaleFactor, y: growScaleFactor)
                let translate = currentWordView.transform.translatedBy(x: currentWordView.frame.midX - self.thumbnailFrame.midX, y: currentWordView.frame.midY - self.thumbnailFrame.midY)
                currentWordView.transform = translate.concatenating(scale)
                nextWordView.transform = CGAffineTransform.identity
            }
            else {
                // Return the master view to its inherent size and position and shrink the detail view.
                currentWordView.transform = CGAffineTransform.identity
                nextWordView.transform = CGAffineTransform(scaleX: shrinkScaleFactor, y: shrinkScaleFactor)
            }

            // Move the detail view to the final frame position.
            nextWordView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }) { finished in
            transitionContext.completeTransition(true)
        }
    }
    
//    weak var context: UIViewControllerContextTransitioning?
//    var reverse = false
//
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 0.5
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        guard let fromVC = transitionContext.viewController(forKey: .from) as? GrowTransitionable,
//              let toVC = transitionContext.viewController(forKey: .to) as? GrowTransitionable,
//              let toSnapshot = toVC.mainView.snapshotView(afterScreenUpdates: true),
//              let fromSnapshot = fromVC.mainView.snapshotView(afterScreenUpdates: false) else {
//                  transitionContext.completeTransition(false)
//                  return
//              }
//        context = transitionContext
//        let containerView = transitionContext.containerView
//
//        containerView.addSubview(fromSnapshot)
//        fromVC.mainView.removeFromSuperview()
//
//////        animate(toView: toSnapshot, fromTriggerButton: (fromVC as! HomeViewController).wordButtons[fromVC.triggerButtonIndex])
////        animateOldTextOffscreen(fromView: toSnapshot)
////
////        containerView.addSubview(toVC.mainView)
////        toSnapshot.removeFromSuperview()
//
////        animateToTextView(toTextView: toVC.contentTextView, fromTriggerButton: fromVC.triggerButton)
//    }
//
////    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
////        guard let fromVC = transitionContext.viewController(forKey: .from) as? CircleTransitionable,
////            let toVC = transitionContext.viewController(forKey: .to) as? CircleTransitionable,
////            let snapshot = fromVC.mainView.snapshotView(afterScreenUpdates: false) else {
////                transitionContext.completeTransition(false)
////                return
////        }
////        context = transitionContext
////
////        let containerView = transitionContext.containerView
////
//////        let backgroundView = UIView()
//////        backgroundView.frame = toVC.mainView.frame
//////        backgroundView.backgroundColor = fromVC.mainView.backgroundColor
//////        containerView.addSubview(backgroundView)
////
////        containerView.addSubview(snapshot)
////        fromVC.mainView.removeFromSuperview()
////
////        animateOldTextOffscreen(fromView: snapshot)
////
////        containerView.addSubview(toVC.mainView)
////        animate(toView: toVC.mainView, fromTriggerButton: fromVC.triggerButton)
////
////        animateToTextView(toTextView: toVC.contentTextView, fromTriggerButton: fromVC.triggerButton)
////    }
//
//    func animateOldTextOffscreen(fromView: UIView) {
//        UIView.animate(withDuration: 2,
//                       delay: 0.0,
//                       options: [.curveEaseIn],
//                       animations: {
//                        fromView.center = CGPoint(x: fromView.center.x - 2000,
//                                                  y: fromView.center.y + 2000)
//                        fromView.transform = CGAffineTransform(scaleX: 10.0, y: 10.0)
//        }, completion: nil)
//    }
//
//    func animate(toView: UIView, fromTriggerButton triggerButton: UIButton) {
//        let rect = CGRect(x: triggerButton.frame.origin.x,
//                          y: triggerButton.frame.origin.y,
//                          width: triggerButton.frame.width,
//                          height: triggerButton.frame.width)
//
//        let circleMaskPathInitial = UIBezierPath(ovalIn: rect)
//
//        let fullWidth = toView.bounds.width
//        let fullHeight = toView.bounds.height
//        let extremePoint = CGPoint(x: triggerButton.center.x - fullWidth,
//                                   y: triggerButton.center.y - fullHeight)
//
//        let radius = sqrt((extremePoint.x*extremePoint.x) +
//            (extremePoint.y*extremePoint.y))
//
//        let circleMaskPathFinal = UIBezierPath(ovalIn: triggerButton.frame.insetBy(dx: -radius, dy: -radius))
//
//        let maskLayer = CAShapeLayer()
//        maskLayer.path = circleMaskPathFinal.cgPath
//        toView.layer.mask = maskLayer
//
//        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
//        maskLayerAnimation.fromValue = circleMaskPathInitial.cgPath
//        maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
//        maskLayerAnimation.duration = 0.15
//        maskLayerAnimation.delegate = self as CAAnimationDelegate
//        maskLayer.add(maskLayerAnimation, forKey: "path")
//    }
//
//    func animateToTextView(toTextView: UIView, fromTriggerButton: UIButton) {
//        let originalCenter = toTextView.center
//        toTextView.alpha = 0.0
//        toTextView.center = fromTriggerButton.center
//        toTextView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
//
//        UIView.animate(withDuration: 0.25, delay: 0.1, options: [.curveEaseOut], animations: {
//            toTextView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//            toTextView.center = originalCenter
//            toTextView.alpha = 1.0
//        }, completion: nil)
//    }
}

//extension CustomNavigationAnimationController: CAAnimationDelegate {
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        context?.completeTransition(true)
//    }
//}

