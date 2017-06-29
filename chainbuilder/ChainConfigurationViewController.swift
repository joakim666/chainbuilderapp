//
//  ChainConfigurationViewController.swift
//  chainbuilder
//
//  Created by Joakim Ek on 2017-06-22.
//  Copyright © 2017 Morrdusk. All rights reserved.
//

import UIKit
import Neon

class ChainConfigurationViewController: UIViewController, HSBColorPickerDelegate {
    
    // view model
    var chainConfigurationViewModel: ChainConfigurationViewModel?
    
    // views
    let containerView = UIView()
    let dismissButton = UIButton(type: .system)
    
    let nameContainer = UIView()
    let nameLabel = UILabel()
    let nameTextField = UITextField()
    
    let startDateContainer = UIView()
    let startDateLabel = UILabel()
    let startDateDescription = UILabel()
    let startDateSwitch = UISwitch()
    let startDatePicker = UIDatePicker()
    
    let colorContainer = UIView()
    let colorLabel = UILabel()
    let currentColorLabel = UILabel()
    let currentColor = UIView()
    let colorPicker = HSBColorPicker()
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    init(chainConfigurationViewModel: ChainConfigurationViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.chainConfigurationViewModel = chainConfigurationViewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.clipsToBounds = true
        containerView.backgroundColor = UIColor.white
        view.addSubview(containerView)

        //nameContainer.backgroundColor = UIColor.red
        //startDateContainer.backgroundColor = UIColor.green
        //colorContainer.backgroundColor = UIColor.blue
        
        containerView.addSubview(nameContainer)
        containerView.addSubview(startDateContainer)
        containerView.addSubview(colorContainer)
        
        // chain name label
        //chainNameLabel.backgroundColor = UIColor.red
        nameLabel.text = "Name"
        nameLabel.textAlignment = .left
        nameLabel.font = UIFont.boldSystemFont(ofSize: 32)
        nameLabel.textColor = UIColor.black
        nameContainer.addSubview(nameLabel)
        
        // chain name text field
        nameTextField.borderStyle = .roundedRect
        nameTextField.textAlignment = .left
        nameTextField.font = UIFont.systemFont(ofSize: 18)
        nameTextField.autocorrectionType = .no
        nameTextField.addTarget(self, action: #selector(ChainConfigurationViewController.nameTextFieldValueChanged), for: UIControlEvents.editingChanged)
        nameContainer.addSubview(nameTextField)

        // chain start date label
        startDateLabel.backgroundColor = UIColor.white
        startDateLabel.text = "Start date"
        startDateLabel.textAlignment = .left
        startDateLabel.font = UIFont.boldSystemFont(ofSize: 32)
        startDateLabel.textColor = UIColor.black
        startDateContainer.addSubview(startDateLabel)

        // chain start date description
        startDateDescription.textColor = UIColor.darkGray
        startDateDescription.backgroundColor = UIColor.white
        startDateDescription.textAlignment = .left
        startDateDescription.font = UIFont.systemFont(ofSize: 12)
        var desc = "Set a start date for a chain to hide dates before the selected date from the user interface for the current chain."
        desc.append(" That way it is easier to see how many successful days you've had since you started to track a thing.")
        startDateDescription.text = desc
        startDateDescription.lineBreakMode = .byWordWrapping
        startDateDescription.numberOfLines = 0
        startDateDescription.sizeToFit()
        startDateContainer.addSubview(startDateDescription)
        
        // chain start date switch
        startDateSwitch.addTarget(self, action: #selector(ChainConfigurationViewController.startDateSwitchValueChanged), for: UIControlEvents.valueChanged)
        startDateContainer.addSubview(startDateSwitch)
        
        // chain start date picker
        startDatePicker.datePickerMode = UIDatePickerMode.date
        startDatePicker.maximumDate = Date()
        startDatePicker.addTarget(self, action: #selector(ChainConfigurationViewController.startDatePickerValueChanged), for: UIControlEvents.valueChanged)
        startDateContainer.addSubview(startDatePicker)
        
        // color label
        colorLabel.text = "Color"
        colorLabel.textAlignment = .left
        colorLabel.font = UIFont.boldSystemFont(ofSize: 32)
        colorLabel.textColor = UIColor.black
        colorContainer.addSubview(colorLabel)
        
        // current color label
        currentColorLabel.text = "Current color: "
        currentColorLabel.textAlignment = .left
        currentColorLabel.font = UIFont.boldSystemFont(ofSize: 18)
        currentColorLabel.textColor = UIColor.black
        colorContainer.addSubview(currentColorLabel)
        
        // current color
        currentColor.backgroundColor = chainConfigurationViewModel?.color
        colorContainer.addSubview(currentColor)
        
        // color picker
        colorPicker.elementSize = 15.0
        colorPicker.delegate = self
        colorContainer.addSubview(colorPicker)
        
        dismissButton.setTitle("Save", for: .normal)
        dismissButton.addTarget(self, action: #selector(ChainConfigurationViewController.dismissButtonClicked), for: UIControlEvents.touchUpInside)
        containerView.addSubview(dismissButton)
        
        self.refresh()
    }

    // delegate callback from the color picker
    func HSBColorColorPickerTouched(sender:HSBColorPicker, color:UIColor, point:CGPoint, state:UIGestureRecognizerState) {
        if isValidColor(color: color) {
            chainConfigurationViewModel?.color = color
            refresh()
        }
    }
    
    func nameTextFieldValueChanged() {
        chainConfigurationViewModel?.name = nameTextField.text
    }
    
    func startDateSwitchValueChanged() {
        chainConfigurationViewModel?.startDateEnabled = startDateSwitch.isOn
        refresh()
    }
    
    func startDatePickerValueChanged() {
        chainConfigurationViewModel?.startDate = startDatePicker.date
    }
    
    func refresh() {
        log.debug("refresh")

        if let vm = chainConfigurationViewModel {
            nameTextField.text = vm.name
            
            if let startDateEnabled = vm.startDateEnabled {
                startDateSwitch.isOn = startDateEnabled
                startDatePicker.isUserInteractionEnabled = startDateEnabled
                startDatePicker.alpha = startDateEnabled ? 1.0 : 0.5 // dim date picker when disabled
            }

            if let startDate = vm.startDate {
                startDatePicker.date = startDate
            }
            
            currentColor.backgroundColor = vm.color
        }

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func dismissButtonClicked() {
        log.debug("Dismiss button clicked")
        
        chainConfigurationViewModel?.save()
        
        // call callback before doing animation so the parent ui is updated
        if let cb = self.chainConfigurationViewModel?.callback {
            cb()
        }
        
        dismiss(animated: true, completion: {})
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        containerView.fillSuperview(left: 0, right: 0, top: 0, bottom: 0)
        
        nameLabel.anchorAndFillEdge(.top, xPad: 0, yPad: 30, otherSize: 25)
        nameTextField.alignAndFillWidth(align: .underMatchingLeft, relativeTo: nameLabel, padding: 15, height: 35)
        
        nameContainer.anchorAndFillEdge(.top, xPad: 10, yPad: 0, otherSize: 120)
        
        startDateLabel.anchorInCorner(.topLeft, xPad: 0, yPad: 20, width: 175, height: 25)
        startDateDescription.alignAndFillWidth(align: .underMatchingLeft, relativeTo: startDateLabel, padding: 15, height: AutoHeight)
        startDateSwitch.align(.toTheRightCentered, relativeTo: startDateLabel, padding: 0, width: AutoWidth, height: AutoHeight)
        startDatePicker.alignAndFillWidth(align: .underMatchingLeft, relativeTo: startDateDescription, padding: 35, height: 100)
        
        startDateContainer.alignAndFillWidth(align: .underCentered, relativeTo: nameContainer, padding: 10, height: 250)
        
        colorLabel.anchorAndFillEdge(.top, xPad: 0, yPad: 20, otherSize: 25)
        currentColorLabel.align(.underMatchingLeft, relativeTo: colorLabel, padding: 10, width: AutoWidth, height: AutoHeight)
        currentColor.align(.toTheRightCentered, relativeTo: currentColorLabel, padding: 0, width: 15, height: 15)
        colorPicker.alignAndFillWidth(align: .underCentered, relativeTo: currentColorLabel, padding: 5, height: 45)
        
        colorContainer.alignAndFillWidth(align: .underCentered, relativeTo: startDateContainer, padding: 10, height: 150)
        
        dismissButton.anchorToEdge(.bottom, padding: 0, width: 100, height: 50)
    }
    
    private func isValidColor(color: UIColor) -> Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return false
        }
        if red == 1.0 && green == 1.0 && blue == 1.0 {
            return false // white is not a valid color from the color picker
        }
        
        if red > 0.0 && red <= 1.0 &&
            green > 0.0 && green <= 1.0 &&
            blue > 0.0 && blue <= 1.0 {
            return true
        }
        
        return false
    }

}
