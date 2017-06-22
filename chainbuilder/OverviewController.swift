//
//  OverviewController.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-04-18.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import UIKit
import Neon
import GoogleMobileAds

class OverviewController: CalendarViewController {
    
    // view models
    let chainViewModel = ChainViewModel()
    
    var calendarViewBuilder = CalendarViewBuilder()
    
    // views
    let containerView : UIView = UIView()
    let chainName = UILabel()
    let tableContainer : UIView = UIView()
    let tableHeader = UILabel()
    
    let chainLabels = ChainLabels()
    
    var calendarRows = [CalendarRow]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(currentDateViewModel: CurrentDateViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.currentDateViewModel = currentDateViewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.clipsToBounds = true
        containerView.backgroundColor = UIColor.white
        view.addSubview(containerView)
        
        tableContainer.layer.borderColor = UIColor.black.cgColor
        tableContainer.layer.borderWidth = 1.0
        containerView.addSubview(tableContainer)
        
        // chain name label
        chainName.backgroundColor = UIColor.white
        chainName.text = "Overview"
        chainName.textAlignment = .center
        chainName.font = UIFont.boldSystemFont(ofSize: 32)
        chainName.textColor = UIColor.black
        containerView.addSubview(chainName)
        
        tableHeader.backgroundColor = UIColor.white
        tableHeader.text = currentDateViewModel?.selectedMonthName
        tableHeader.textAlignment = .center
        tableHeader.font = UIFont.boldSystemFont(ofSize: 20) // same font size as chainEditTextField
        tableHeader.textColor = UIColor.black
        containerView.addSubview(tableHeader)
        
        containerView.addSubview(chainLabels.container)

        
        //self.addTap() // TODO enable and show popup bubble with info how to mark days using the specific views
        
        self.refresh()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override func panLeft() -> CalendarViewController? {
        if let currentDateViewModel = self.currentDateViewModel {
            return OverviewController(currentDateViewModel: currentDateViewModel.adjustedViewModel(directon: 1))
        }
        return nil
    }
    
    override func panRight() -> CalendarViewController? {
        if let currentDateViewModel = self.currentDateViewModel {
            return OverviewController(currentDateViewModel: currentDateViewModel.adjustedViewModel(directon: -1))
        }
        return nil
    }
    
    /*func addTap() {
    }*/
    
    func refresh() {
        log.debug("refresh")
        
        // remove previous subviews
        for v in tableContainer.subviews {
            for vv in v.subviews {
                vv.removeFromSuperview()
            }
            v.removeFromSuperview()
        }
        
        // create and add new subviews
        if let currentDateViewModel = self.currentDateViewModel {
            var chainsToShow = [(dates: [Date], color: String)]()
            var chainLabels = [(color: String, name: String)]()
            
            if let chains = chainViewModel.chains() {
                for chain in chains {
                    chainsToShow.append((chainViewModel.dates(chainId: chain.id), chain.color))
                    chainLabels.append((chain.color, (chain.name)!)) // TODO fix !
                }
            }

            self.chainLabels.setLabels(chainLabels)
            
            self.calendarRows = calendarViewBuilder.createRows(currentDateViewModel.selectedDate, today: Date(), chainsToShow: chainsToShow)!
            tableHeader.text = currentDateViewModel.selectedMonthName
        }
        
        chainName.text = "Overview"
        
        for r in calendarRows {
            tableContainer.addSubview(r.container)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        containerView.fillSuperview(left: 0, right: 0, top: 25, bottom: 10)
        
        tableContainer.backgroundColor = UIColor.white
        tableContainer.anchorInCenter(width: 315, height: 315) // 320 = 7 rows * row height (45px)
        
        tableHeader.align(.aboveCentered, relativeTo: tableContainer, padding: 0, width: 315, height: 40)
        
        chainName.align(.aboveCentered, relativeTo: tableHeader, padding: 0, width: 315, height: 40)
        
        layoutCalender()
        
        chainLabels.container.align(.underCentered, relativeTo: tableContainer, padding: 10, width: 300, height: 200)
        
        chainLabels.layout()
    }
    
    fileprivate func layoutCalender() {
        log.debug("layoutCalender")
        
        // layout super view first, so the subviews know what space is available
        tableContainer.groupAgainstEdge(group: .vertical, views: calendarRows.map{$0.container}, againstEdge: .top, padding: 0, width: 315, height: 45)
        
        // layout the subviews
        for r in calendarRows {
            r.layout()
        }
    }
    
}

class ChainLabels {
    let container = UIView()
    var labelViews = [(colorView: UIView, nameView: UIView)]()
    
    init() {
        container.backgroundColor = UIColor.white
    }
    
    func setLabels(_ labels: [(color: String, name: String)]) {
        
        // remove old labels views
        for (a,b) in labelViews {
            a.removeFromSuperview()
            b.removeFromSuperview()
        }
        labelViews.removeAll()
        
        for label in labels {
            let a = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            a.backgroundColor = UIColor(hexString: label.color)
            a.alpha = 0.75
            container.addSubview(a)
            
            let b = UILabel()
            b.backgroundColor = UIColor.white
            b.text = label.name
            b.textAlignment = .left
            b.font = UIFont.systemFont(ofSize: 18)
            b.textColor = UIColor.black
            container.addSubview(b)
            
            labelViews.append((colorView: a, nameView: b))
        }
    }
    
    func layout() {
        let views = self.labelViews.map{ $0.colorView }

        self.container.groupInCorner(group: .vertical, views: views, inCorner: .topLeft, padding: 10, width: 20, height: 20)
        
        for (a,b) in self.labelViews {
            b.alignAndFillWidth(align: .toTheRightCentered, relativeTo: a, padding: 5, height: 20)
        }        
    }
}

