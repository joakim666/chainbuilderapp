//
//  SlideInWithSpringAnimator.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-02-13.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import UIKit

class SlideInWithSpringAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    static let childViewPadding:CGFloat = 16.0
    static let damping:CGFloat = 0.75
    static let initialSpringVelocity:CGFloat = 0.5
    
    var direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            log.warning("Missing toViewController")
            return
        }
        
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            log.warning("Missing fromViewController")
            return
        }
        
        let dx: CGFloat
        let dy: CGFloat
        
        if direction == Direction.left || direction == Direction.right {
            let d = transitionContext.containerView.bounds.size.width + SlideInWithSpringAnimator.childViewPadding
            dx = direction == Direction.left ? -d : d
            dy = 0
        }
        else { // it's up or down
            let d = transitionContext.containerView.bounds.size.height + SlideInWithSpringAnimator.childViewPadding
            dx = 0
            dy = direction == Direction.up ? -d : d
        }
        
        transitionContext.containerView.addSubview(toViewController.view)
        transitionContext.containerView.setNeedsLayout() // due to adding a new subview
        transitionContext.containerView.layoutIfNeeded() // due to adding a new subview
        
        fromViewController.view.frame.origin.x = 0
        fromViewController.view.frame.origin.y = 0
        
        toViewController.view.frame.origin.x = dx
        toViewController.view.frame.origin.y = dy
        toViewController.view.alpha = 0
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: SlideInWithSpringAnimator.damping, initialSpringVelocity: SlideInWithSpringAnimator.initialSpringVelocity, options: UIViewAnimationOptions(), animations: {
            fromViewController.view.frame.origin.x = -dx // the views should slide in the same direction hence the -
            fromViewController.view.frame.origin.y = -dy // the views should slide in the same direction hence the -
            fromViewController.view.alpha = 0
            toViewController.view.frame.origin.x = 0
            toViewController.view.frame.origin.y = 0
            toViewController.view.alpha = 1
        }, completion: {didComplete in
            fromViewController.view.alpha = 1
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
}
