//
//  StayWithSomeoneIKnowQuestionView.swift
//  PLANIT-v1
//
//  Created by MICHAEL WURM on 6/26/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class StayWithSomeoneIKnowQuestionView: UIView, UITextViewDelegate {
    
    //Class vars
    var questionLabel: UILabel?
    var button1: UIButton?
    var button2: UIButton?
    var textView: UITextView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addViews()
        //        self.layer.borderColor = UIColor.green.cgColor
        //        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = UIScreen.main.bounds
        
        questionLabel?.frame = CGRect(x: 10, y: 40, width: bounds.size.width - 20, height: 100)
        
        textView?.frame = CGRect(x: 10, y: 130, width: bounds.size.width - 20, height: 140)
        let width = 1.0
        let borderLine = UIView()
        borderLine.frame = CGRect(x: Double((textView?.frame.minX)!), y: Double((textView?.frame.maxY)!) - width, width: Double((textView?.frame.width)!), height: width)
        borderLine.backgroundColor = UIColor.white
        self.addSubview(borderLine)
        var topCorrect: CGFloat? = ((textView?.bounds.size.height)! - (textView?.contentSize.height)!)
        topCorrect = (topCorrect! < CGFloat(0.0) ? 0.0 : topCorrect)
        textView?.contentOffset = CGPoint()
        textView?.contentOffset.x = 0
        textView?.contentOffset.y = -topCorrect!
        
        button1?.sizeToFit()
        button1?.frame.size.height = 30
        button1?.frame.size.width += 20
        button1?.frame.origin.x = (bounds.size.width - (button1?.frame.width)!) / 2
        button1?.frame.origin.y = 300
        button1?.layer.cornerRadius = (button1?.frame.height)! / 2
        button1?.isHidden = true
        
        button2?.sizeToFit()
        button2?.frame.size.height = 30
        button2?.frame.size.width += 20
        button2?.frame.origin.x = (bounds.size.width - (button2?.frame.width)!) / 2
        button2?.frame.origin.y = 350
        button2?.layer.cornerRadius = (button2?.frame.height)! / 2
    }
    
    func addViews() {
        //Question label
        questionLabel = UILabel(frame: CGRect.zero)
        questionLabel?.translatesAutoresizingMaskIntoConstraints = false
        questionLabel?.numberOfLines = 0
        questionLabel?.textAlignment = .center
        questionLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        questionLabel?.textColor = UIColor.white
        questionLabel?.adjustsFontSizeToFitWidth = true
        questionLabel?.text = "Share your plan with your group?"
        self.addSubview(questionLabel!)
        
        //Button1
        button1 = UIButton(type: .custom)
        button1?.frame = CGRect.zero
        button1?.setTitleColor(UIColor.white, for: .normal)
        button1?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button1?.layer.borderWidth = 1
        button1?.layer.borderColor = UIColor.white.cgColor
        button1?.layer.masksToBounds = true
        button1?.titleLabel?.numberOfLines = 0
        button1?.titleLabel?.textAlignment = .center
        button1?.setTitle("Next", for: .normal)
        button1?.translatesAutoresizingMaskIntoConstraints = false
        button1?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button1!)
        
        
        //Button2
        button2 = UIButton(type: .custom)
        button2?.frame = CGRect.zero
        button2?.setTitleColor(UIColor.white, for: .normal)
        button2?.setBackgroundColor(color: UIColor.clear, forState: .normal)
        button2?.layer.borderWidth = 1
        button2?.layer.borderColor = UIColor.white.cgColor
        button2?.layer.masksToBounds = true
        button2?.titleLabel?.numberOfLines = 0
        button2?.titleLabel?.textAlignment = .center
        button2?.setTitle("Add later", for: .normal)
        button2?.translatesAutoresizingMaskIntoConstraints = false
        button2?.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        self.addSubview(button2!)
        
        textView = UITextView(frame: CGRect.zero)
        textView?.delegate = self
        textView?.textColor = UIColor.white
        textView?.dataDetectorTypes = .all
        textView?.contentMode = .bottomLeft
        textView?.layer.masksToBounds = true
        textView?.textAlignment = .left
        textView?.returnKeyType = .next
        textView?.backgroundColor = UIColor.clear
        textView?.font = UIFont.systemFont(ofSize: 18)
        let textViewPlaceholder = "\nExample: Staying at my sisters. Her address is 555 Market Street, San Franciso, CA 91000"
        textView?.text = textViewPlaceholder
        textView?.indicatorStyle = .white
        textView?.clearsOnInsertion = true
        textView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(textView!)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        var topCorrect: CGFloat? = textView.bounds.size.height - textView.contentSize.height
        topCorrect = (topCorrect! < CGFloat(0.0) ? 0.0 : topCorrect)
        textView.contentOffset = CGPoint()
        textView.contentOffset.x = 0
        textView.contentOffset.y = -topCorrect!
        
        if textView.text != "" {
            button1?.isHidden = false
        } else {
            button1?.isHidden = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "stayWithSomeoneIKnowTextViewNextPressed"), object: nil)
            return false
        }
        return true
    }
    
    func buttonClicked(sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            sender.setButtonWithTransparentText(button: sender, title: sender.currentTitle as! NSString, color: UIColor.white)
        } else {
            sender.removeMask(button:sender, color: UIColor.white)
        }
        for subview in self.subviews {
            if subview.isKind(of: UIButton.self) && subview != sender {
                (subview as! UIButton).isSelected = false
                (subview as! UIButton).removeMask(button: subview as! UIButton, color: UIColor.white)
            }
        }
    }
    
}
