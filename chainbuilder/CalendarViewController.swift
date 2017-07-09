//
//  CalendarViewController.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-02-10.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import UIKit
import AudioToolbox
import Neon
import GoogleMobileAds

class CalendarViewController: UIViewController {
    var currentDateViewModel: CurrentDateViewModel?
    
    func panLeft() -> CalendarViewController? { return nil }
    func panRight() -> CalendarViewController? { return nil }
}

class ChainViewController: CalendarViewController {
    
    // view models
    let chainViewModel = ChainViewModel()
    let shareViewModel = ShareViewModel()
    let chainConfigurationViewModel = ChainConfigurationViewModel()
    
    var chain: Chain?
    
    var calendarViewBuilder = CalendarViewBuilder()
    
    // views
    let containerView : UIView = UIView()
    let chainName = UILabel()
    let tableContainer : UIView = UIView()
    let tableHeader = UILabel()
    let shareButton = UIButton(type: .system)
    let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    let configureButton = UIButton(type: .system)
    
    var calendarRows = [CalendarRow]()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(chain: Chain, currentDateViewModel: CurrentDateViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.chain = chain
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
        chainName.text = chain?.name
        chainName.textAlignment = .center
        chainName.font = UIFont.boldSystemFont(ofSize: 32)
        chainName.textColor = UIColor.black
        containerView.addSubview(chainName)

        tableHeader.text = currentDateViewModel?.selectedMonthName
        tableHeader.textAlignment = .center
        tableHeader.font = UIFont.boldSystemFont(ofSize: 20) // same font size as chainEditTextField
        tableHeader.textColor = UIColor.black
        containerView.addSubview(tableHeader)
        
        shareButton.frame.size = CGSize(width: 30, height: 30)
        shareButton.setImage(UIImage.imageFromSystemBarButton(.action), for: .normal)
        shareButton.addTarget(self, action: #selector(ChainViewController.shareButtonClicked), for: UIControlEvents.touchUpInside)
        containerView.addSubview(shareButton)

        configureButton.setTitle("Edit", for: .normal)
        configureButton.addTarget(self, action: #selector(ChainViewController.configureButtonClicked), for: UIControlEvents.touchUpInside)
        containerView.addSubview(configureButton)
        
        if GlobalSettings.showAds {
            bannerView.adUnitID = GlobalSettings.adMobAdUnitID()
            bannerView.rootViewController = self
            let adReq = GADRequest()
            adReq.testDevices = [kGADSimulatorID]
            bannerView.load(adReq)
        }
        containerView.addSubview(bannerView)
        
        self.addTap()
        
        self.refresh()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override func panLeft() -> CalendarViewController? {
        if let currentDateViewModel = self.currentDateViewModel {
            if let chain = self.chain {
                return ChainViewController(chain: chain, currentDateViewModel: currentDateViewModel.adjustedViewModel(directon: 1))
            }
        }
        return nil
    }
    
    override func panRight() -> CalendarViewController? {
        if let currentDateViewModel = self.currentDateViewModel {
            if let chain = self.chain {
                if chain.startDateEnabled, let startDate = chain.startDate {
                    if Calendar.current.isDate(currentDateViewModel.selectedDate, equalTo: startDate, toGranularity: .month) {
                        // start date is in the currently displayed month, if so don't allow to pan right to earlier months
                        return nil
                    }
                }
                return ChainViewController(chain: chain, currentDateViewModel: currentDateViewModel.adjustedViewModel(directon: -1))
            }
        }
        return nil
    }
    
    func shareButtonClicked() {
        log.debug("Share button clicked")

        shareViewModel.shareChain(chain)

        self.refresh()
    }
    
    func configureButtonClicked() {
        log.debug("Configure button clicked")
        
        if let chain = self.chain {
            chainConfigurationViewModel.configure(chain) {
                self.refresh()
            }
        }
        
        self.refresh()
    }
    
    func addTap() {
        calendarViewBuilder.dayPressedCallback = { (date: Date) in
            self.handleDayPressed(date)
            
            // vibrate device if possible
            switch UIDevice().type {
            case .iPhone5:
                fallthrough
            case .iPhone5S:
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            case .iPhone6:
                fallthrough
            case .iPhone6plus:
                fallthrough
            case .iPhone6S:
                fallthrough
            case .iPhone6Splus:
                // iphone 6/6+ 6s/6s+
                AudioServicesPlaySystemSound(1520) // strong
            case .iPhone7:
                fallthrough
            case .iPhone7plus:
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.prepare()
                    generator.impactOccurred()
                }
            default:
                log.debug("Not able to vibrate on this device")
            }
        }
    }
    
    func handleDayPressed(_ date: Date) {
        chainViewModel.addOrRemove(chainId: (chain?.id)!, date: date)
        refresh()
    }
    
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
        
        let startDate: Date? = self.chain?.startDateEnabled == true ? chain?.startDate : nil
        let chainsToShow: [(dates: [Date], color: String, startDate: Date?)] = [(chainViewModel.dates(chainId: chain?.id), (chain?.color)!, startDate)]
        
        if let currentDateViewModel = self.currentDateViewModel {
            self.calendarRows = calendarViewBuilder.createRows(currentDateViewModel.selectedDate, today: Date(), chainsToShow: chainsToShow)!
            tableHeader.text = currentDateViewModel.selectedMonthName
        }
        
        chainName.text = chain?.name
        
        for r in calendarRows {
            tableContainer.addSubview(r.container)
        }
        
        // show sharing controller if share button is pressed
        if shareViewModel.shareMode {
            if let sharedFileURL = shareViewModel.sharedFileURL() {
                let activityViewController = UIActivityViewController(activityItems: [sharedFileURL], applicationActivities: nil)
                activityViewController.excludedActivityTypes = shareViewModel.excludedActivityTypes
                present(activityViewController, animated: true, completion: {
                    self.shareViewModel.completed()
                    self.refresh()
                })
            }
        }
        
        // show chain configuration controller if configure button is pressed
        if chainConfigurationViewModel.configurationMode {
            let chainConfigurationViewController = ChainConfigurationViewController(chainConfigurationViewModel: chainConfigurationViewModel)
            self.present(chainConfigurationViewController, animated: true, completion: {
                // todoo self.chainConfigurationViewModel.completed()
                self.refresh()
            })
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        containerView.fillSuperview(left: 0, right: 0, top: 25, bottom: 10)
        
        tableContainer.backgroundColor = UIColor.white
        tableContainer.anchorInCenter(width: 315, height: 315) // 320 = 7 rows * row height (45px)
        
        tableHeader.align(.aboveCentered, relativeTo: tableContainer, padding: 0, width: 225, height: 40) // 225 = 315 - (2*45)
        
        shareButton.align(.toTheRightCentered, relativeTo: tableHeader, padding: 0, width: 45, height: 40)

        chainName.isHidden = false
        tableHeader.isHidden = false
        tableContainer.isHidden = false
            
        chainName.align(.aboveCentered, relativeTo: tableHeader, padding: 0, width: 315, height: 40)

        layoutCalender()
        
        configureButton.align(.underCentered, relativeTo: tableContainer, padding: 0, width: 50, height: 50)
        
        bannerView.alignAndFillWidth(align: .underCentered, relativeTo: configureButton, padding: 10, height: 50)
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


