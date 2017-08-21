import UIKit

@objc protocol HLSearchFormDelegate {
    func onSearch(_ searchForm: HLSearchForm)
    func showKidsPicker()
	func showDatePicker()
    func showCityPicker()
    func selectCurrentLocation()
}

@objc class HLSearchForm: UIView {
    @IBOutlet weak var kidsButton: UIButton!

    @IBOutlet fileprivate weak var humansSelectorView: UIView!

    @IBOutlet fileprivate weak var datesSelectorButton: UIButton!
    @IBOutlet fileprivate weak var datesValueLabel: UILabel!
    @IBOutlet fileprivate weak var datesTitleLabel: UILabel!

    @IBOutlet fileprivate weak var citySelectorButton: UIButton!

    @IBOutlet fileprivate weak var searchButton: UIButton!
    @IBOutlet weak var comeBackToThisButton: UIButton!

    @IBOutlet fileprivate weak var currentCityButton: UIButton!
    @IBOutlet fileprivate weak var currentCityActivityIndicator: UIActivityIndicatorView!

    @IBOutlet fileprivate weak var cityTitleLabel: UILabel!
    @IBOutlet fileprivate weak var cityValueLabel: UILabel!

    @IBOutlet fileprivate weak var adultsTitleLabel: UILabel!
    @IBOutlet fileprivate weak var kidsTitleLabel: UILabel!

    @IBOutlet fileprivate weak var oneAdultsButton: UIButton!
    @IBOutlet fileprivate weak var twoAdultsButton: UIButton!
    @IBOutlet fileprivate weak var threeAdultsButton: UIButton!
    @IBOutlet fileprivate weak var fourAdultsButton: UIButton!

    @IBOutlet private weak var originIcon: UIImageView!
    @IBOutlet private weak var datesIcon: UIImageView!
    @IBOutlet private weak var guestsIcon: UIImageView!

    weak var delegate: HLSearchFormDelegate?
    var searchInfo: HLSearchInfo? {
        didSet {
            updateControls()
        }
    }

    // MARK: - Required methods

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        NotificationCenter.default.addObserver(self, selector:#selector(HLSearchForm.updateExpiredDates), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        registerForCurrentCityNotifications()
    }

    deinit {
        self.unregisterNotificationResponse()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        initialize()
    }

    // MARK: - Private methods

    @objc func updateExpiredDates() {
        searchInfo?.updateExpiredDates()
        updateControls()
    }

    private func initialize() {
        backgroundColor = UIColor.clear
        setTitlesColors()
        setupSearchButton()
        setupComeBackToThisButton()
        setupAdultsButtons()
        setupIconsTint()
        currentCityButton.tintColor = UIColor(red: 198/255, green: 206/255, blue: 220/255, alpha: 1)

        cityTitleLabel.text = NSLS("HL_SEARCH_FORM_CITY_TITLE")
        datesTitleLabel.text = NSLS("HL_LOC_SEARCH_DATES_LABEL")
        adultsTitleLabel.text = NSLS("HL_LOC_SEARCH_ADULTS_TITLE")
        kidsTitleLabel.text = NSLS("HL_LOC_SEARCH_KIDS_TITLE")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(hotelSearchSpawnedFromItinerary), name: NSNotification.Name(rawValue: "hotelSearchSpawnedFromItinerary"), object: nil)

    }
    func hotelSearchSpawnedFromItinerary() {
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.searchButton.sendActions(for: .touchUpInside)
        }
    }

    private func setupSearchButton() {
        searchButton.tintColor = JRColorScheme.mainButtonTitleColor()
        searchButton.backgroundColor = UIColor.clear
        searchButton.layer.cornerRadius = searchButton.frame.size.height / 2
        searchButton.layer.borderColor = UIColor.white.cgColor
        searchButton.layer.borderWidth = 1
    }
    
    private func setupComeBackToThisButton() {
        comeBackToThisButton.tintColor = UIColor.white
        comeBackToThisButton.backgroundColor = UIColor.clear
        comeBackToThisButton.layer.cornerRadius = 15
        comeBackToThisButton.layer.borderColor = UIColor.white.cgColor
        comeBackToThisButton.layer.borderWidth = 1
        comeBackToThisButton.titleLabel?.textColor = UIColor.white
        comeBackToThisButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    }

    private func setTitlesColors() {
        datesTitleLabel.textColor = JRColorScheme.searchFormTextColor()
        adultsTitleLabel.textColor = JRColorScheme.searchFormTextColor()
        kidsTitleLabel.textColor = JRColorScheme.searchFormTextColor()
        cityTitleLabel.textColor = JRColorScheme.searchFormTextColor()

        datesValueLabel.textColor = JRColorScheme.searchFormTextColor()
        cityValueLabel.textColor = JRColorScheme.searchFormTextColor()
    }

    private func setupAdultsButtons() {
        let image = UIImage(named: "searchFormButton")
        let selected = UIImage(named: "searchFormButtonSelected")
        for button in [oneAdultsButton, twoAdultsButton, threeAdultsButton, fourAdultsButton, kidsButton] {
            button?.setBackgroundImage(image, for: .normal)
            button?.tintColor = UIColor(red: 198/255, green: 206/255, blue: 220/255, alpha: 1)
            button?.setBackgroundImage(selected, for: .selected)
            button?.setTitleColor(JRColorScheme.searchFormTextColor(), for: .normal)
            button?.setTitleColor(JRColorScheme.searchFormTextColor(), for: .selected)
        }

        kidsButton.setBackgroundImage(UIImage(named: "emptyKidsButton"), for: .normal)
    }

    private func setupIconsTint() {
        originIcon.tintColor = JRColorScheme.searchFormTintColor()
        datesIcon.tintColor = JRColorScheme.searchFormTintColor()
        guestsIcon.tintColor = JRColorScheme.searchFormTintColor()
    }

    func updateControls() {
        if let searchInfo = searchInfo {

            cityValueLabel?.text = StringUtils.destinationString(by: searchInfo)

            updateAdultsButtons(searchInfo.adultsCount)
            datesValueLabel.text = StringUtils.datesDescriptionWithCheck(in: searchInfo.checkInDate!, checkOut: searchInfo.checkOutDate!)
            let days = DateUtil.hl_daysBetweenDate(searchInfo.checkInDate, andOtherDate:searchInfo.checkOutDate)
            datesTitleLabel.text = NSLS("HL_LOC_SEARCH_DATES_LABEL") + " (" + StringUtils.durationDescription(withDays: days) + ")"

            if searchInfo.kidAgesArray.count > 0 {
                kidsButton?.setTitle("\(searchInfo.kidAgesArray.count)", for: .normal)
                kidsButton.isSelected = true
            } else {
                kidsButton?.setTitle("", for: .normal)
                kidsButton.isSelected = false
            }
            searchButton.setTitle("SEARCH", for: .normal)
        }
    }

    private func searchTitle(for searchInfo: HLSearchInfo) -> String {
        let title = searchInfo.searchInfoType == .hotel
            ? NSLS("HL_LOC_SEARCH_BUTTON_TITLE_PRICES")
            : NSLS("HL_LOC_SEARCH_BUTTON_TITLE")

        return title.uppercased()
    }

    private func updateAdultsButtons(_ count: Int) {
        for tag in 1000 ... 1003 {
            if let button: UIButton = humansSelectorView?.viewWithTag(tag) as? UIButton {
                button.isSelected = (tag == (count + 999))
                button.isUserInteractionEnabled = (tag != (count + 999))
            }
        }
    }

    // MARK: - IBActions methods
    @IBAction func comeBackToThisButtonTouchedUpInside(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "comeBackToThisHotelsButtonTouchedUpInside"), object: nil)
    }

    @IBAction fileprivate func onSearch(_ sender: AnyObject) {
        self.delegate?.onSearch(self)
    }

    @IBAction fileprivate func onAdultsCountChanged(_ sender: AnyObject) {
        let newCount: NSInteger = (sender.tag - 999)

        self.updateAdultsButtons(newCount)
        self.searchInfo?.adultsCount = newCount
    }

    @IBAction private func kidsButtonPressed() {
        delegate?.showKidsPicker()
    }

    @IBAction private func onGeo() {
        delegate?.selectCurrentLocation()
        updateControls()
        currentCityButton.tintColor = UIColor.white
    }

    @IBAction private func selectCity() {
        delegate?.showCityPicker()
    }

    @IBAction private func selectDates() {
		delegate?.showDatePicker()
    }
}

extension HLSearchForm: HLNearbyCitiesDetectionDelegate {

    func nearbyCitiesDetectionStarted(_ notification: Notification!) {
        hideCurrentCityButton()
    }

    func nearbyCitiesDetected(_ notification: Notification!) {
        showCurrentCityButton()

        if (notification.object as? NSArray) != nil {
            if notification.userInfo?[kCurrentLocationDestinationKey] as? String == kForceCurrentLocationToSearchForm {
                if let locationPoint = HLSearchUserLocationPoint.forCurrentLocation() {
                    searchInfo?.locationPoint = locationPoint
                }
                updateControls()
            }
        } else {
            nearbyCitiesDetectionFailed(notification)
        }
    }

    func nearbyCitiesDetectionFailed(_ notification: Notification!) {
        showCurrentCityButton()
    }

    func nearbyCitiesDetectionCancelled(_ notification: Notification!) {
        showCurrentCityButton()
    }

    func locationServicesAccessFailed(_ notification: Notification!) {
        showCurrentCityButton()
    }

    func locationDetectionFailed(_ notification: Notification!) {
        showCurrentCityButton()
    }

    func showCurrentCityButton() {
        currentCityButton.isHidden = false
        currentCityActivityIndicator.stopAnimating()
    }

    func hideCurrentCityButton() {
        currentCityButton.isHidden = true
        currentCityActivityIndicator.startAnimating()
    }
}
