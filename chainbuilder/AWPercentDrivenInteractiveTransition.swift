//
//  AWPercentDrivenInteractiveTransition.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-02-15.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import UIKit

/**
 A drop-in replacement for UIPercentDrivenInteractiveTransition
 for use in custom container view controllers
 
 @see UIPercentDrivenInteractiveTransition
 */

class AWPercentDrivenInteractiveTransition: NSObject, UIViewControllerInteractiveTransitioning {
    //@property (nonatomic, readonly) CGFloat duration;
    //private(set) var duration: CGFloat = 0
    //@property (readonly) CGFloat percentComplete;
    private(set) var percentComplete: CGFloat = 0

    //@property (nonatomic, readonly) UIViewAnimationCurve animationCurve; // Unused, returns UIViewAnimationCurveLinear
    private(set) var animationCurve: UIViewAnimationCurve = UIViewAnimationCurve.linear
    
    private(set) var completionCurve: UIViewAnimationCurve = UIViewAnimationCurve.linear

    // BOOL _isInteracting
    private(set) var isInteracting: Bool = false

    /**
     The animated transitioning that this percent driven interaction should control.
     This property must be set prior to the start of a transition.
     */
    //@property (nonatomic, weak) id<UIViewControllerAnimatedTransitioning>animator;
    private var animator: UIViewControllerAnimatedTransitioning

    // __weak id<UIViewControllerContextTransitioning> _transitionContext;
    private var transitionContext: UIViewControllerContextTransitioning?

    
    // CADisplayLink *_displayLink;
    private var displayLink: CADisplayLink?
    
    // @property (nonatomic) CGFloat completionSpeed; // Defaults to 1
    var completionSpeed: CGFloat = 2
    
    // - (instancetype)initWithAnimator:(id<UIViewControllerAnimatedTransitioning>)animator;
    init(animator: UIViewControllerAnimatedTransitioning) {
        self.animator = animator
        super.init()
    }

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        self.transitionContext!.containerView.layer.speed = 0
        self.animator.animateTransition(using: self.transitionContext!)
    }
    
    func updateInteractiveTransition(percentComplete:CGFloat) {
        setPercentComplete(percentComplete: CGFloat(fmaxf(fminf(Float(percentComplete), 1), 0))) // input validation
    }
    
    func cancelInteractiveTransition() {
        log.debug("cancelInteractiveTransition()")
        
        self.displayLink = CADisplayLink(target: self, selector: #selector(AWPercentDrivenInteractiveTransition.tickCancelAnimation))
        self.displayLink!.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        
        self.transitionContext!.cancelInteractiveTransition()
    }
    
    func finishInteractiveTransition() {
        self.transitionContext!.finishInteractiveTransition()
        self.completeTransition()
    }
    
    func duration() -> TimeInterval {
        return self.animator.transitionDuration(using: self.transitionContext)
    }
    
    // - (void)setPercentComplete:(CGFloat)percentComplete {
    func setPercentComplete(percentComplete:CGFloat) {
        self.percentComplete = percentComplete
        
        self.setTimeOffset(timeOffset: Double(percentComplete) * self.duration())
        
        self.transitionContext!.updateInteractiveTransition(percentComplete)
    }

    private func timeOffset() -> CFTimeInterval {
        return self.transitionContext!.containerView.layer.timeOffset
    }

    private func setTimeOffset(timeOffset:CFTimeInterval) {
        self.transitionContext!.containerView.layer.timeOffset = timeOffset
    }
    
    private func completeTransition() {
        log.debug("completeTransition()")
        self.displayLink = CADisplayLink(target: self, selector: #selector(AWPercentDrivenInteractiveTransition.tickAnimation))
        self.displayLink!.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    @objc private func tickAnimation() {
        var timeOffset = self.timeOffset()
        let tick = self.displayLink!.duration * Double(self.completionSpeed)
        timeOffset += self.transitionContext!.transitionWasCancelled ? -tick : tick
        
        if timeOffset < 0 || timeOffset > self.duration() {
            self.transitionFinished()
        }
        else {
            self.setTimeOffset(timeOffset: timeOffset)
        }
    }
    
    @objc private func tickCancelAnimation() {
        var timeOffset = self.timeOffset()
        let tick = self.displayLink!.duration * Double(self.completionSpeed)
        timeOffset -= tick
        log.debug("timeOffset=\(timeOffset)")
        
        
        if timeOffset < 0 {
            log.debug("calling transitionFinishedCanceling()")
            self.transitionFinishedCanceling()
        }
        else {
            log.debug("setting timeOffset to \(timeOffset)")
            self.setTimeOffset(timeOffset: timeOffset)
        }
    }
    
    private func transitionFinished() {
        log.debug("transitionFinished()")
        self.displayLink!.invalidate()
        let layer = self.transitionContext!.containerView.layer
        layer.speed = 1
        
        if !self.transitionContext!.transitionWasCancelled {
            log.debug(" and was not cancelled")
            let pausedTime = layer.timeOffset
            layer.timeOffset = 0.0
            layer.beginTime = 0.0 // Need to reset to 0 to avoid flickering
            let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            layer.beginTime = timeSincePause
        }
    }
    
    private func transitionFinishedCanceling() {
        log.debug("transitionFinishedCanceling()")
        self.displayLink!.invalidate()
        
        let layer = self.transitionContext!.containerView.layer
        layer.speed = 1
    }
}
