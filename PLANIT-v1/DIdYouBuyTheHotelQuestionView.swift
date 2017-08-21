//
//  DIdYouBuyTheHotelQuestionView.swift
//  PLANIT-v1
//
//  Created by MICHAEL WURM on 7/25/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class DidYouBuyTheHotelQuestionView: UIView {
        //Class vars
        var questionLabel: UILabel?
        var button1: UIButton?
        var button2: UIButton?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        override func awakeFromNib() {
            super.awakeFromNib()
            addViews()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            let bounds = UIScreen.main.bounds
            
            questionLabel?.frame = CGRect(x: 20, y: 50, width: super.frame.width - 20, height: 60)
            
            button1?.sizeToFit()
            button1?.frame.size.height = 30
            button1?.frame.size.width += 20
            button1?.frame.origin.x = (super.frame.width - (button1?.frame.width)!) / 2
            button1?.frame.origin.y = 140
            button1?.layer.cornerRadius = (button1?.frame.height)! / 2
            
            button2?.sizeToFit()
            button2?.frame.size.height = 30
            button2?.frame.size.width += 20
            button2?.frame.origin.x = (super.frame.width - (button2?.frame.width)!) / 2
            button2?.frame.origin.y = 190
            button2?.layer.cornerRadius = (button2?.frame.height)! / 2
        }
        
        
        func addViews() {
            //Question label
            questionLabel = UILabel(frame: CGRect.zero)
            questionLabel?.translatesAutoresizingMaskIntoConstraints = false
            questionLabel?.numberOfLines = 0
            questionLabel?.textAlignment = .center
            questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
            questionLabel?.textColor = UIColor.black
            questionLabel?.adjustsFontSizeToFitWidth = true
            questionLabel?.text = "Hotel booked?"
            self.addSubview(questionLabel!)
            
            //Button2
            button1 = UIButton(type: .custom)
            button1?.frame = CGRect.zero
            button1?.setTitleColor(UIColor.black, for: .normal)
            button1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
            button1?.layer.borderWidth = 1
            button1?.layer.borderColor = UIColor.black.cgColor
            button1?.layer.masksToBounds = true
            button1?.titleLabel?.numberOfLines = 0
            button1?.titleLabel?.textAlignment = .center
            button1?.setTitle("Yes", for: .normal)
            button1?.translatesAutoresizingMaskIntoConstraints = false
            button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
            self.addSubview(button1!)
            
            
            //Button2
            button2 = UIButton(type: .custom)
            button2?.frame = CGRect.zero
            button2?.setTitleColor(UIColor.black, for: .normal)
            button2?.setBackgroundColor(color: UIColor.clear, forState: .normal)
            button2?.layer.borderWidth = 1
            button2?.layer.borderColor = UIColor.black.cgColor
            button2?.layer.masksToBounds = true
            button2?.titleLabel?.numberOfLines = 0
            button2?.titleLabel?.textAlignment = .center
            button2?.setTitle("No", for: .normal)
            button2?.translatesAutoresizingMaskIntoConstraints = false
            button2?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
            self.addSubview(button2!)
        }
        
        func buttonClicked(sender:UIButton) {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle as! NSString, color: UIColor.black)
            } else {
                sender.removeMask(button:sender, color: UIColor.white)
            }
            if sender == button1 {
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                var lastHotelOpenInBrowser = SavedPreferencesForTrip["lastHotelOpenInBrowser"] as! [String:Any]
                let indexOfDestinationBeingPlanned = SavedPreferencesForTrip["indexOfDestinationBeingPlanned"] as! Int
                var placeToStayDictionaryArray = SavedPreferencesForTrip["placeToStayDictionaryArray"] as! [[String:Any]]

                let lastHotelOpen = lastHotelOpenInBrowser["unbooked"]
                lastHotelOpenInBrowser.removeValue(forKey: "unbooked")
                lastHotelOpenInBrowser["booked"] = lastHotelOpen
                placeToStayDictionaryArray[indexOfDestinationBeingPlanned]["placeToStayBookedOnPlanit"] = lastHotelOpen
                SavedPreferencesForTrip["lastHotelOpenInBrowser"] = lastHotelOpenInBrowser
                SavedPreferencesForTrip["placeToStayDictionaryArray"] = placeToStayDictionaryArray
                saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hotelBookingBrowserClosed_HotelBooked"), object: nil)
                
            } else if sender == button2 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hotelBookingBrowserClosed_HotelNotBooked"), object: nil)
            }
            for subview in self.subviews {
                if subview.isKind(of: UIButton.self) && subview != sender {
                    (subview as! UIButton).isSelected = false
                    (subview as! UIButton).removeMask(button: subview as! UIButton, color: UIColor.white)
                }
            }
        }
        
      
}
