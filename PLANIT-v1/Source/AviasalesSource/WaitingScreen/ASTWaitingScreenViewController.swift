//
//  ASTWaitingScreenViewController.swift
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

import UIKit

class ASTWaitingScreenViewController: UIViewController {

    let presenter: ASTWaitingScreenPresenter

    @IBOutlet weak var progressView: ASTWaitingScreenProgressView!
    @IBOutlet weak var planeScene: ASTWaitingScreenPlaneSceneView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var appodealAdvertisementView: UIView!
    @IBOutlet weak var aviasalesAdvertisementView: UIView!

    @IBOutlet weak var aviasalesAdvertisementViewHeightConstraint: NSLayoutConstraint!

    init(searchInfo: JRSDKSearchInfo) {
        presenter = ASTWaitingScreenPresenter(searchInfo: searchInfo)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        presenter.handleUnload()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
        presenter.handleLoad(view: self)
        infoLabel.textColor = UIColor.white
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "flightSearchWaitingScreenViewController_ViewDidLoad"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pop), name: NSNotification.Name(rawValue: "popFromWaitingScreenViewControllerToFlightSearch"), object: nil)
    }

    // MARK: - Setup

    func setupViewController() {
        edgesForExtendedLayout = .top
        view.backgroundColor = UIColor.clear
        progressView.backgroundColor = UIColor.clear
        progressView.progressColor = UIColor(colorLiteralRed: 200/255, green: 213/255, blue: 221/255, alpha: 1)
    }

    // MARK: - Update

    func updateInfoLabel(text: String, range: NSRange) {
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: range)
        infoLabel.attributedText = attributedText
    }

    // MARK: - Error

    func showErrorAlert(title: String, message: String, cancel: String, completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancel, style: .cancel) { (_) in
            completion()
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }

    // MARK: - Navigation

    func showSearchResultsViewController(searchResult: JRSDKSearchResult, searchInfo: JRSDKSearchInfo) {

        let viewController: UIViewController
        if iPad() {
            viewController = ASTSearchResultsSceneViewController(searchResult: searchResult, searchInfo: searchInfo)
        } else {
            viewController = JRSearchResultsVC(searchInfo: searchInfo, response: searchResult)
        }

        navigationController?.replaceTopViewController(with: viewController)
    }
}

extension ASTWaitingScreenViewController: ASTWaitingScreenViewProtocol {

    func startAnimating() {
        planeScene.startAnimating()
    }

    func animateProgress(duration: TimeInterval) {
        progressView.animateProgress(duration: duration)
    }

    func update(title: String) {
        let tripViewController = self.parent?.parent as! TripViewController
        tripViewController.navigationItem.titleView = nil
        tripViewController.navigationItem.title = title
//        tripViewController.shyNavBarManager.stickyNavigationBar = true
//        navigationItem.title = title
    }

    func updateInfo(text: String, range: NSRange) {
        updateInfoLabel(text: text, range: range)
    }

    func showAppodealAdvertisement() {
        JRAdvertisementManager.sharedInstance().presentVideoAd(inViewIfNeeded: appodealAdvertisementView, rootViewController: self)
    }

    func showAviasalesAdvertisement(searchInfo: JRSDKSearchInfo) {
        AviasalesSDK.sharedInstance().adsManager.loadAdsViewForWaitingScreen(with: searchInfo) { [weak self] (adsView, error) in
            if let adsView = adsView {
                adsView.place(into: self?.aviasalesAdvertisementView)
                self?.aviasalesAdvertisementViewHeightConstraint.constant = 90
            }
        }
    }

    func showSearchResults(searchResult: JRSDKSearchResult, searchInfo: JRSDKSearchInfo) {
        showSearchResultsViewController(searchResult: searchResult, searchInfo: searchInfo)
    }

    func showError(title: String, message: String, cancel: String) {
        showErrorAlert(title: title, message: message, cancel: cancel) { [weak self] in
            self?.presenter.handleError()
        }
    }

    func pop() {
        self.navigationController?.popViewController(animated: true)
    }
}
