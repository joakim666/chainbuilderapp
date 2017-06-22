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
    
    var chain: Chain?
    
    var calendarViewBuilder = CalendarViewBuilder()
    
    // view model
    let chainNameViewModel = ChainNameViewModel()
    
    // views
    let containerView : UIView = UIView()
    let chainName = UILabel()
    let chainEditContainerView = UIView()
    let chainEditTextField = UITextField()
    let chainEditConfirmButton = UIButton(type: .system)
    let chainEditCancelButton = UIButton(type: .system)
    let tableContainer : UIView = UIView()
    let tableHeader = UILabel()
    let shareButton = UIButton(type: .system)
    let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
    
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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ChainViewController.chainNameClicked))
        tapGesture.numberOfTapsRequired = 1
        chainName.isUserInteractionEnabled = true
        chainName.addGestureRecognizer(tapGesture)
        containerView.addSubview(chainName)

        // text field
        chainEditTextField.borderStyle = .roundedRect
        chainEditTextField.text = chainNameViewModel.name
        chainEditTextField.textAlignment = .center
        chainEditTextField.font = UIFont.boldSystemFont(ofSize: 20) // same font size as tableHeader
        chainEditTextField.autocorrectionType = .no
        chainEditContainerView.addSubview(chainEditTextField)
        
        // confirm button
        chainEditConfirmButton.setTitle("Save", for: .normal)
        chainEditConfirmButton.backgroundColor = UIColor.green
        chainEditConfirmButton.addTarget(self, action: #selector(ChainViewController.confirmButtonClicked), for: UIControlEvents.touchUpInside)
        chainEditContainerView.addSubview(chainEditConfirmButton)
        
        // cancel button
        chainEditCancelButton.setTitle("Cancel", for: .normal)
        chainEditCancelButton.backgroundColor = UIColor.red
        chainEditCancelButton.addTarget(self, action: #selector(ChainViewController.cancelButtonClicked), for: UIControlEvents.touchUpInside)
        chainEditContainerView.addSubview(chainEditCancelButton)
        containerView.addSubview(chainEditContainerView)
        
        tableHeader.text = currentDateViewModel?.selectedMonthName
        tableHeader.textAlignment = .center
        tableHeader.font = UIFont.boldSystemFont(ofSize: 20) // same font size as chainEditTextField
        tableHeader.textColor = UIColor.black
        containerView.addSubview(tableHeader)
        
        shareButton.frame.size = CGSize(width: 30, height: 30)
        shareButton.setImage(UIImage.imageFromSystemBarButton(.action), for: .normal)
        shareButton.addTarget(self, action: #selector(ChainViewController.shareButtonClicked), for: UIControlEvents.touchUpInside)
        containerView.addSubview(shareButton)
        
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
                return ChainViewController(chain: chain, currentDateViewModel: currentDateViewModel.adjustedViewModel(directon: -1))
            }
        }
        return nil
    }
    
    func chainNameClicked() {
        log.debug("chainNameClicked")
        
        chainNameViewModel.reset(chain?.name)

        self.refresh()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func confirmButtonClicked() {
        log.debug("Confirm button clicked")
        chainNameViewModel.save(chainEditTextField.text)
        
        if let chain = chain {
            let n = chainEditTextField.text != nil ? chainEditTextField.text! : ""
            chainViewModel.updateName(chain: chain, name: n)
        }
        
        self.refresh()
    }
    
    func cancelButtonClicked() {
        log.debug("Cancel button clicked")

        chainNameViewModel.cancel()
        
        self.refresh()
    }
    
    func shareButtonClicked() {
        log.debug("Share button clicked")

        shareViewModel.shareChain(chain)

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
        
        let chainsToShow: [(dates: [Date], color: String)] = [(chainViewModel.dates(chainId: chain?.id), (chain?.color)!)]
        
        if let currentDateViewModel = self.currentDateViewModel {
            self.calendarRows = calendarViewBuilder.createRows(currentDateViewModel.selectedDate, today: Date(), chainsToShow: chainsToShow)!
            tableHeader.text = currentDateViewModel.selectedMonthName
        }
        
        chainName.text = chain?.name
        chainEditTextField.text = chainNameViewModel.name

        if chainNameViewModel.editMode {
            // set focus to the textfield
            chainEditTextField.becomeFirstResponder()
        }
        else {
            // remove focus from textfield as it's not visible. Hence, remove the keyboard
            chainEditTextField.resignFirstResponder()
        }
        
        for r in calendarRows {
            tableContainer.addSubview(r.container)
        }
        
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

        if !chainNameViewModel.editMode {
            // show the chain name
            chainName.isHidden = false
            tableHeader.isHidden = false
            tableContainer.isHidden = false
            chainEditContainerView.isHidden = true
            
            chainName.align(.aboveCentered, relativeTo: tableHeader, padding: 0, width: 315, height: 40)
        }
        else {
            // show the text field and confirm and cancel buttons so the name can be changed
            chainName.isHidden = true
            tableHeader.isHidden = true
            tableContainer.isHidden = true
            chainEditContainerView.isHidden = false
            
            // the container
            chainEditContainerView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: 110) // 110 = 55 + 5 + 50

            // textfield
            chainEditTextField.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: 55)
            
            // confirm and cancel
            chainEditContainerView.groupAndAlign(group: .horizontal, andAlign: .underCentered, views: [chainEditCancelButton, chainEditConfirmButton], relativeTo: chainEditTextField, padding: 5, width: chainEditContainerView.width/2.0, height: 50)
        }

        layoutCalender()
        
        bannerView.alignAndFillWidth(align: .underCentered, relativeTo: tableContainer, padding: 10, height: 50)
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


