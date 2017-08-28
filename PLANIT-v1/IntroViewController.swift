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
    private var rootView: UIView?
    private var intro: EAIntroView?

    //MARK: View lifecycle
    func viewDidLoad() {
        super.viewDidLoad()
        // using self.navigationController.view - to display EAIntroView above navigation bar
        rootView = navigationController?.view
        
        var page1 = EAIntroPage()
        page1.title = "Hello world"
        page1.desc = sampleDescription1
        page1.bgImage = UIImage(named: "bg1")
//        page1.titleIconView = UIImageView(image: UIImage(named: "title1"))
        var page2 = EAIntroPage()
        page2.title = "This is page 2"
        page2.desc = sampleDescription2
        page2.bgImage = UIImage(named: "bg2")
//        page2.titleIconView = UIImageView(image: UIImage(named: "title2"))
        var page3 = EAIntroPage()
        page3.title = "This is page 3"
        page3.desc = sampleDescription3
        page3.bgImage = UIImage(named: "bg3")
//        page3.titleIconView = UIImageView(image: UIImage(named: "title3"))
        var page4 = EAIntroPage()
        page4.title = "This is page 4"
        page4.desc = sampleDescription4
        page4.bgImage = UIImage(named: "bg4")
//        page4.titleIconView = UIImageView(image: UIImage(named: "title4"))
        
        intro = EAIntroView(frame: rootView.bounds, andPages: [page1, page2, page3, page4])
        intro.skipButtonAlignment = EAViewAlignmentCenter
        intro.skipButtonY = 80.0
        intro.pageControlY = 42.0
        intro.delegate = self
        intro.show(in: self.view, animateDuration: 0.1)

    }
}
