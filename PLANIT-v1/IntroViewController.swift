//
//  IntroViewController.swift
//  PLANIT-v1
//
//  Created by MICHAEL WURM on 8/27/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import EAIntroView

class IntroViewController: UIViewController, EAIntroDelegate {
    
    //MARK: Class vars
    private var intro: EAIntroView?
    private var description1 = ""
    private var description2 = ""
    private var description3 = ""
    
    //MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        var page1 = EAIntroPage()
        page1.title = "Propose itineraries and share"
        page1.titleFont = UIFont.boldSystemFont(ofSize: 25)
        page1.desc = description1
        page1.titleIconView = UIImageView(image: #imageLiteral(resourceName: "itineraryIcon"))
        var page2 = EAIntroPage()
        page2.title = "See everyone else's plans"
        page2.titleFont = UIFont.boldSystemFont(ofSize: 25)
        page2.desc = description2
        page2.titleIconView = UIImageView(image: #imageLiteral(resourceName: "twoPeopleIcon"))
        var page3 = EAIntroPage()
        page3.title = "Track where you want to go\nand where you've been"
        page3.titleFont = UIFont.boldSystemFont(ofSize: 25)
        page3.desc = description3
        page3.titleIconView = UIImageView(image: #imageLiteral(resourceName: "globePinIcon"))
        intro = EAIntroView(frame: self.view.frame, andPages: [page1, page2, page3])
        intro?.delegate = self
        intro?.skipButtonAlignment = EAViewAlignment.center
        intro?.skipButton.addTarget(self, action: #selector(setTripViewControllerAsCenterViewController), for: UIControlEvents.touchUpInside)
        intro?.skipButtonY = 80.0
        intro?.pageControlY = 42.0
        intro?.show(in: self.view, animateDuration: 0.1)
        
    }
    
    func introWillFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        setTripViewControllerAsCenterViewController()
    }
    
    func setTripViewControllerAsCenterViewController() {
        
        var centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
        
        centerViewController.NewOrAddedTripFromSegue = 1
        centerViewController.isTripSpawnedFromBucketList = 0
        
        var centerNavController = UINavigationController(rootViewController: centerViewController)
        centerViewController.navigationController?.isNavigationBarHidden = true
        var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer!.centerViewController = centerNavController


    }
}
