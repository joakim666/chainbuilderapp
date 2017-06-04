//
//  ActiveSlotIndicator.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-04-29.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import UIKit

class ActiveSlotIndicator: UIViewController {
    // model
    private(set) var slotsViewModel: SlotsViewModel?
    
    // views
    let containerView: UIView = UIView()
    var circles = [UIView]()

    let circleSize = CGFloat(7.5)

    required init?(coder aDecoder: NSCoder) {
        log.error("This initializer should not be used")
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        log.error("This initializer should not be used")
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(_ slotsViewModel: SlotsViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.slotsViewModel = slotsViewModel
    }

    func refresh() {
        if let slotsViewModel = self.slotsViewModel {

            for c in circles {
                c.removeFromSuperview()
            }
            circles.removeAll()
            
            for i in 0..<slotsViewModel.count() {
                if i == slotsViewModel.activeSlot {
                    let c = createCircle(size: self.circleSize, color: UIColor.black)
                    self.containerView.addSubview(c)
                    circles.append(c)
                }
                else {
                    let c = createCircle(size: self.circleSize, color: UIColor.lightGray)
                    self.containerView.addSubview(c)
                    circles.append(c)
                }
            }
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.layer.zPosition = 99 // this view should be on top of other views

        containerView.clipsToBounds = true
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.0)
        view.addSubview(containerView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.view.anchorInCorner(.topRight, xPad: 5, yPad: 25, width: 20, height: 60)
        containerView.fillSuperview()
        
        containerView.groupInCenter(group: .vertical, views: circles, padding: 5, width: circleSize, height: circleSize)
    }
    
    func createCircle(size: CGFloat, color: UIColor) -> UIView {
        let c = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        c.layer.cornerRadius = circleSize / 2
        c.layer.backgroundColor = color.cgColor
        return c
    }
}
