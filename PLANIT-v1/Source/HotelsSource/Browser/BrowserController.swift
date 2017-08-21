@objc class BrowserController: HLCommonVC, HLWebBrowserDelegate {

    var webBrowser: HLWebBrowser?
    @IBOutlet weak var browserBackground: UIView?

    func createBrowser(title: String?) {
        if let browser = loadViewFromNibNamed("HLWebBrowser") as? HLWebBrowser {
            browser.pageTitle = title
            browserBackground?.addSubview(browser)
            browser.autoPinEdgesToSuperviewEdges()
            browser.delegate = self
            webBrowser = browser
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.statusBarStyle = .default
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.shared.statusBarStyle = .lightContent
    }

    // MARK: - HLWebBrowserDelegate

    func navigationFinished() {
    }

    func navigationFailed(_ error: Error!) {
    }

    func close() {
        presentingViewController?.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "HLWebBrowserClosed"), object: nil)
    }

    func reload() {

    }
}
