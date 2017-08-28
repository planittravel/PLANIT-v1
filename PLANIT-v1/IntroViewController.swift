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
    
    
    
    
    func setTripViewControllerAsCenterViewController() {
        
        var centerViewController = self.storyboard?.instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
        
        centerViewController.NewOrAddedTripFromSegue = 1
        centerViewController.isTripSpawnedFromBucketList = 0
        
        var centerNavController = UINavigationController(rootViewController: centerViewController)
        centerViewController.navigationController?.isNavigationBarHidden = true
        var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.centerContainer!.centerViewController = centerNavController

        
        
        
//        var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "setUpTripController"), object: nil)
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//
//        //Instantiate VCs from storyboard
//        let centerViewController = mainStoryboard.instantiateViewController(withIdentifier: "CenterViewController") as! CenterViewController
//        let leftViewController = mainStoryboard.instantiateViewController(withIdentifier: "LeftViewController") as! LeftViewController
//        let rightViewController = mainStoryboard.instantiateViewController(withIdentifier: "RightViewController") as! RightViewController
//        
//        //Create nav controllers
//        let leftSideNav = UINavigationController(rootViewController: leftViewController)
//        let centerNav = UINavigationController(rootViewController: centerViewController)
//        let rightNav = UINavigationController(rootViewController: rightViewController)
//        
//        //Create instance of DrawerController and set open and close gesture modes
//        appDelegate.centerContainer = DrawerController(centerViewController: centerNav, leftDrawerViewController: leftSideNav)
//        appDelegate.centerContainer!.openDrawerGestureModeMask = OpenDrawerGestureMode.panningCenterView
//        appDelegate.centerContainer!.closeDrawerGestureModeMask = CloseDrawerGestureMode.panningCenterView
//        appDelegate.centerContainer!.maximumLeftDrawerWidth = 305
//        
//        //Set root VC
//        appDelegate.window!.rootViewController = centerContainer

    }
}
