//
//  CalendarContainerViewController.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-02-10.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import UIKit
import RealmSwift

struct Thresholds {
    struct SwipeVelocity {
        static let horizontal = CGFloat(1000.0)
        static let vertical = CGFloat(1000.0)
    }
    
    struct PanPercentage {
        static let horizontal = CGFloat(0.15)
        static let vertical = CGFloat(0.06)
    }
}


enum Direction : Int {
    case up
    case right
    case down
    case left
}

class CalendarContainerViewController: UIViewController {
    
    var panOrigin: CGPoint?

    var slotsViewModel: SlotsViewModel?
    
    var activeSlotIndicator: ActiveSlotIndicator?
    
    // the currently showing calendar view controller
    var currentCalendarViewController: CalendarViewController?
    
    var defaultInteractionController: AWPercentDrivenInteractiveTransition?
    
    var transitionContext: PrivateTransitionContext?
    
    // This is where subclasses should create their custom view hierarchy if they aren't using a nib. Should never be called directly.
    override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = UIColor.white
        rootView.clipsToBounds = true
        self.view = rootView
        
        self.activeSlotIndicator = ActiveSlotIndicator(self.slotsViewModel!)
        self.view.addSubview(self.activeSlotIndicator!.view)
        
        refresh()
    }
    
    // Called after the view has been loaded. For view controllers created in code, this is after -loadView. For view controllers unarchived from a nib, this is after the view is set.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.currentCalendarViewController == nil {
            if let slotsViewModel = self.slotsViewModel {
                if let vc = slotsViewModel.newViewControllerForSlotAt(index: slotsViewModel.activeSlot, currentDateViewModel: CurrentDateViewModel()) {
                    changeViewController(toViewController: vc)
                    refresh()
                }
                else {
                    log.warning("Failed to get view controller instance for slow \(slotsViewModel.activeSlot) even though the slot passed isValidSlot()")
                }
            }
            else {
                log.warning("No slotsViewModel set")
            }
        }
        
        addPan()
    }

    override func viewWillLayoutSubviews() {
        self.view.fillSuperview()
        if let current = currentCalendarViewController {
            current.view.fillSuperview()
        }
    }
    
    func refresh() {
        self.activeSlotIndicator?.refresh()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    func addPan() {
        log.debug("Adding UIPanGestureRecognizer")
        let pr = UIPanGestureRecognizer(target: self, action: #selector(CalendarContainerViewController.handlePan(_:)))
        self.view.addGestureRecognizer(pr)
    }
    
    func panRight() -> Bool {
        var res = false
        if let currentCalendarViewController = self.currentCalendarViewController {
            if let newViewController = currentCalendarViewController.panRight() {
                changeViewController(toViewController: newViewController, direction: Direction.left)
                res = true
            }
        }
        
        return res
    }
    
    func panLeft() -> Bool {
        var res = false
        if let currentCalendarViewController = self.currentCalendarViewController {
            if let newViewController = currentCalendarViewController.panLeft() {
                changeViewController(toViewController: newViewController, direction: Direction.right)
                res = true
            }
        }
        
        return res
    }

    func panDown() -> Bool {
        guard slotsViewModel!.isValidSlot(index: slotsViewModel!.activeSlot-1) else {
            log.debug("Trying to pan to slot with index \(self.slotsViewModel!.activeSlot-1) which is not valid")
            return false
        }

        let currentDateViewModel = self.currentCalendarViewController?.currentDateViewModel ?? CurrentDateViewModel()
        
        guard let vc = slotsViewModel!.newViewControllerForSlotAt(index: slotsViewModel!.activeSlot-1, currentDateViewModel: currentDateViewModel) else {
            log.warning("Failed to get view controller instance for slow \(self.slotsViewModel!.activeSlot-1) even though the slot passed isValidSlot()")
            return false
        }
        
        slotsViewModel!.activeSlot -= 1
        changeViewController(toViewController: vc, direction: Direction.up)
        
        return true
    }
    
    func panUp() -> Bool {
        guard slotsViewModel!.isValidSlot(index: slotsViewModel!.activeSlot+1) else {
            log.debug("Trying to pan to slot with index \(self.slotsViewModel!.activeSlot+1) which is not valid")
            return false
        }

        let currentDateViewModel = self.currentCalendarViewController?.currentDateViewModel ?? CurrentDateViewModel()

        guard let vc = slotsViewModel!.newViewControllerForSlotAt(index: self.slotsViewModel!.activeSlot+1, currentDateViewModel: currentDateViewModel) else {
            log.warning("Failed to get view controller instance for slow \(self.slotsViewModel!.activeSlot+1) even though the slot passed isValidSlot()")
            return false
        }

        self.slotsViewModel!.activeSlot += 1
        changeViewController(toViewController: vc, direction: Direction.down)
        
        return true
    }

    func handlePan(_ sender: UIPanGestureRecognizer) {
        struct Context { // TODO remove inner struct later
            static var currentDirection: Direction = Direction.left
            static var animationActive: Bool = false
        }
        
        // get the translation in the view
        let t = sender.translation(in: sender.view)

        // detect swipe gesture
        if sender.state == UIGestureRecognizerState.began {
            let velocity = sender.velocity(in: sender.view)
            self.panOrigin = sender.location(in: nil) // nil => indicates the window
            
            if fabs(velocity.x) > fabs(velocity.y) {
                // horizontal movement was largest
                if velocity.x > 0 {
                    // panning right
                    log.debug("Panning right")
                    Context.currentDirection = Direction.right
                    
                    if panRight() {
                        Context.animationActive = true
                    }
                    else {
                        Context.animationActive = false
                        // TODO show bounce animation
                    }
                }
                else if velocity.x < 0 {
                    // panning left
                    log.debug("Panning left")
                    Context.currentDirection = Direction.left
                    
                    if panLeft() {
                        Context.animationActive = true
                    }
                    else {
                        Context.animationActive = false
                        // TODO show bounce animation
                    }
                }
            }
            else {
                // vertical movement was largest
                if velocity.y > 0 {
                    // panning down => go to chain above
                    log.debug("Panning down")
                    Context.currentDirection = Direction.down

                    if panDown() {
                        Context.animationActive = true
                    }
                    else {
                        Context.animationActive = false
                        // TODO bounce animation
                    }
                }
                else if velocity.y < 0 {
                    // panning up => go to chain below
                    log.debug("Panning up")
                    Context.currentDirection = Direction.up
                    
                    if panUp() {
                        Context.animationActive = true
                    }
                    else {
                        Context.animationActive = false
                        // TODO bounce animation
                    }
                }
            }
        }
        else if sender.state == UIGestureRecognizerState.changed {
            guard Context.animationActive else {
                return
            }
            
            let loc = sender.location(in: nil) // nil => indicates the window

            if let panOrigin = self.panOrigin {
                if Context.currentDirection == Direction.up && loc.y > panOrigin.y {
                    // the user has reversed direction and moved past start of pan
                    log.debug("Reversed from up to down")
                    cancelInteractiveTransition() {
                        _ = self.panDown()
                    }
                    
                    // change direction immediately, and not in the closure above, to avoid multiple calls
                    Context.currentDirection = Direction.down
                }
                else if Context.currentDirection == Direction.down && loc.y < panOrigin.y {
                    // the user has reversed direction and moved past start of pan
                    log.debug("Reversed from down to up")
                    cancelInteractiveTransition() {
                        _ = self.panUp()
                    }
                    
                    // change direction immediately, and not in the closure above, to avoid multiple calls
                    Context.currentDirection = Direction.up
                }
                else if Context.currentDirection == Direction.left && loc.x > panOrigin.x {
                    // the user has reversed direction and moved past start of pan
                    log.debug("Reversed from left to right")
                    cancelInteractiveTransition() {
                        _ = self.panRight()
                    }
                    
                    // change direction immediately, and not in the closure above, to avoid multiple calls
                    Context.currentDirection = Direction.right
                }
                else if Context.currentDirection == Direction.right && loc.x < panOrigin.x {
                    // the user has reversed direction and moved past start of pan
                    log.debug("Reversed from right to left")
                    cancelInteractiveTransition() {
                        _ = self.panLeft()
                    }
                    
                    // change direction immediately, and not in the closure above, to avoid multiple calls
                    Context.currentDirection = Direction.left
                }
                else {
                    // update the percentage completed of the animation
                    let percent = (Context.currentDirection == Direction.up || Context.currentDirection == Direction.down) ?
                        fabs(t.y / sender.view!.bounds.size.height) :
                        fabs(t.x / sender.view!.bounds.size.width)
                    
                    let modifier: CGFloat = Context.currentDirection == Direction.up || Context.currentDirection == Direction.down ? 1.0 : 0.5
                    self.defaultInteractionController!.updateInteractiveTransition(percentComplete: percent * modifier)
                }

            }
        }
        else if sender.state == UIGestureRecognizerState.ended {
            guard Context.animationActive else {
                return
            }

            let velocity = sender.velocity(in: sender.view)
            
            if Context.currentDirection == Direction.up || Context.currentDirection == Direction.down {
                if self.defaultInteractionController!.percentComplete > Thresholds.PanPercentage.vertical ||
                    fabs(velocity.y) > Thresholds.SwipeVelocity.vertical {
                    self.defaultInteractionController!.finishInteractiveTransition()
                }
                else {
                    self.defaultInteractionController!.cancelInteractiveTransition()
                }
                
            }
            else {
                if Context.currentDirection == Direction.left || Context.currentDirection == Direction.right {
                    if self.defaultInteractionController!.percentComplete > Thresholds.PanPercentage.horizontal ||
                        fabs(velocity.x) > Thresholds.SwipeVelocity.horizontal {
                        self.defaultInteractionController!.finishInteractiveTransition()
                    }
                    else {
                        self.defaultInteractionController!.cancelInteractiveTransition()
                    }
                    
                }
            }
            
            Context.animationActive = false // TODO right place to reset value?
        }
    }
    
    func cancelInteractiveTransition(completion: (() -> Void)?) {
        if let completion = completion {
            let cb = transitionContext?.completionBlock
            
            transitionContext?.completionBlock = { (didComplete: Bool) -> Void in
                log.debug(("New completion block, calling old"))
                if let oldCallback = cb {
                    oldCallback(didComplete)
                }
                
                log.debug("Doing new stuff")
                completion()
            }
            self.defaultInteractionController!.cancelInteractiveTransition()
        }
    }
    
    // Initiate a change to a new calendar view controller
    //
    // If no previous view controler exists, just shows the view controller. Otherwise it's animated with an interactive pan-controlled animation
    func changeViewController(toViewController: CalendarViewController, direction: Direction? = nil) {
        let fromViewController = self.childViewControllers.count > 0 ? self.childViewControllers[0] : nil
        
        guard self.isViewLoaded else {
            log.debug("view is not loaded")
            return
        }
        
        if let toView = toViewController.view {
            fromViewController?.willMove(toParentViewController: nil)
            self.addChildViewController(toViewController)
            
            // If this is the initial presentation, add the new child with no animation.
            if fromViewController == nil {
                self.view.addSubview(toView)
                toView.fillSuperview()
                toViewController.didMove(toParentViewController: self)
                self.currentCalendarViewController = toViewController
                return
            }
            
            guard let direction = direction else {
                // no direction given, make transition without animation
                self.view.addSubview(toView)
                toView.fillSuperview()
                toViewController.didMove(toParentViewController: self)
                fromViewController?.view.removeFromSuperview()
                fromViewController?.removeFromParentViewController()
                toViewController.didMove(toParentViewController: self)
                self.currentCalendarViewController = toViewController
                return
            }
            
            log.debug("Animate transition")
            
            // Animate the transition by calling the animator with our private transition context
            let animator: UIViewControllerAnimatedTransitioning = SlideInWithSpringAnimator(direction: direction)
            
            self.transitionContext = PrivateTransitionContext(fromViewController: fromViewController!, toViewController: toViewController, direction: direction)
            
            guard let transitionContext = self.transitionContext else {
                log.warning("Failed to create transition context")
                return
            }
            
            self.defaultInteractionController = AWPercentDrivenInteractiveTransition(animator: animator)
            transitionContext.isInteractive = true
            
            transitionContext.completionBlock = { (didComplete: Bool) -> Void in
                if didComplete {
                    // finished normally
                    fromViewController?.view.removeFromSuperview()
                    fromViewController?.removeFromParentViewController()
                    toViewController.didMove(toParentViewController: self)
                    // update the currently showing calendar view controller when the animation has finished
                    self.currentCalendarViewController = toViewController
                    self.refresh()
                }
                else {
                    // was cancelled
                    toViewController.view.removeFromSuperview()
                    toViewController.removeFromParentViewController() // needed?
                    self.refresh()
                }

                animator.animationEnded?(didComplete)
            }
            
            if transitionContext.isInteractive {
                self.defaultInteractionController!.startInteractiveTransition(transitionContext)
            }
            else {
                animator.animateTransition(using: transitionContext)
            }
        }
    }
}

// Own custom implementation of a UIViewControllerContextTransitioning for use in a view container controller setup.
// Based on code from https://github.com/objcio/issue-12-custom-container-transitions/blob/stage-2/Container%20Transitions/ContainerViewController.m
// and the tutorial here https://www.objc.io/issues/12-animations/custom-container-view-controller-transitions/
class PrivateTransitionContext: NSObject, UIViewControllerContextTransitioning {
    
    private var privateViewControllers = [UITransitionContextViewControllerKey: UIViewController]()
    
    private var privateDisappearingFromRect: CGRect
    private var privateAppearingFromRect: CGRect
    private var privateDisappearingToRect: CGRect
    private var privateAppearingToRect: CGRect
    
    var containerView: UIView
    var isAnimated = true
    var isInteractive = false
    var transitionWasCancelled = false
    let presentationStyle = UIModalPresentationStyle.custom
    let targetTransform = CGAffineTransform.identity
    
    // first parameter didComplete
    var completionBlock: ((_: Bool) -> Void)?
    
    init?(fromViewController: UIViewController, toViewController: UIViewController, direction: Direction) {
        log.debug("Init")
        guard fromViewController.isViewLoaded else {
            log.error("The fromViewController view must reside in the container view upon initializing the transition context")
            return nil
        }
        
        guard fromViewController.view.superview != nil else {
            log.error("The fromViewController view must reside in the container view upon initializing the transition context")
            return nil
        }
        
        
        self.containerView = fromViewController.view.superview! // protected by guard statement above
        self.privateViewControllers[UITransitionContextViewControllerKey.from] = fromViewController
        self.privateViewControllers[UITransitionContextViewControllerKey.to] = toViewController
        
        let dx: CGFloat
        let dy: CGFloat
        
        if direction == Direction.left || direction == Direction.right {
            dx = direction == Direction.left ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width
            dy = 0
        }
        else { // it's up or down
            dx = 0
            dy = direction == Direction.up ? -self.containerView.bounds.size.height : self.containerView.bounds.size.height
        }
        
        self.privateDisappearingFromRect = self.containerView.bounds
        self.privateAppearingToRect = self.containerView.bounds
        self.privateDisappearingToRect = self.containerView.bounds.offsetBy(dx: dx, dy: dy)
        self.privateAppearingFromRect = self.containerView.bounds.offsetBy(dx: -dx, dy: -dy)
    }
    
    func completeTransition(_ didComplete: Bool) {
        if let completionBlock = completionBlock {
            completionBlock(didComplete)
        }
    }
    
    func updateInteractiveTransition(_ percentComplete: CGFloat) {}
    func finishInteractiveTransition() {
        self.transitionWasCancelled = false
    }
    
    func cancelInteractiveTransition() {
        self.transitionWasCancelled = true
    }
    
    func pauseInteractiveTransition() {}

    func initialFrame(for vc: UIViewController) -> CGRect {
        if let fromVC = self.viewController(forKey: UITransitionContextViewControllerKey.from) {
            if fromVC.isEqual(vc) {
                return self.privateDisappearingFromRect
            }
            else {
                return self.privateAppearingFromRect
            }
        }
        else {
            return self.privateAppearingFromRect
        }
    }
    
    func finalFrame(for vc: UIViewController) -> CGRect {
        if let fromVC = self.viewController(forKey: UITransitionContextViewControllerKey.from) {
            if fromVC.isEqual(vc) {
                return self.privateDisappearingToRect
            }
            else {
                return self.privateAppearingToRect
            }
        }
        else {
            return self.privateAppearingToRect
        }
    }
    
    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return self.privateViewControllers[key]
    }
    
    @available(iOS 8.0, *)
    public func view(forKey key: UITransitionContextViewKey) -> UIView? {
        switch key {
        case UITransitionContextViewKey.from:
            if let vc = viewController(forKey: UITransitionContextViewControllerKey.from) {
                return vc.view
            }
        case UITransitionContextViewKey.to:
            if let vc = viewController(forKey: UITransitionContextViewControllerKey.to) {
                return vc.view
            }
        default:
            return nil
        }
        return nil
    }
}
