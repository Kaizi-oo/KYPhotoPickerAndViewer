//
//  KYTransformAnimation.swift
//  KYImageViewer
//
//  Created by kyang on 2017/9/19.
//  Copyright © 2017年 kyang. All rights reserved.
//

import UIKit

class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration = 0.25 //动画的时间
    var originFrame = CGRect.zero //点击Cell的frame
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(duration)
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containView = transitionContext.containerView
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        let finalFrame = toView.frame
        
        let xScale = originFrame.size.width/toView.frame.size.width
        let yScale = originFrame.size.height/toView.frame.size.height
        toView.transform = CGAffineTransform(scaleX: xScale, y: yScale)
        toView.center = CGPoint(x: originFrame.midX, y: originFrame.midY)
        
        containView.addSubview(toView)
        UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
            toView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            toView.transform = .identity
        }) { (finished) -> Void in
            transitionContext.completeTransition(true)
        }
    }
}

class DismisssAnimator:NSObject,UIViewControllerAnimatedTransitioning{
    let duration = 0.25
    var originFrame = CGRect.zero
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(duration)
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containView = transitionContext.containerView
        //        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)! //Collection View
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)! //全屏的imageview
        let xScale = originFrame.size.width/UIScreen.main.bounds.size.width
        let yScale = originFrame.size.height/UIScreen.main.bounds.size.height
        //        containView.addSubview(toView)
        containView.bringSubview(toFront: fromView)
        UIView.animate(withDuration: TimeInterval(duration), animations: { () -> Void in
            fromView.center = CGPoint(x: self.originFrame.midX, y: self.originFrame.midY)
            fromView.transform = CGAffineTransform(scaleX: xScale, y: yScale)
        }) { (finished) -> Void in
            transitionContext.completeTransition(true)
        }
    }
}
