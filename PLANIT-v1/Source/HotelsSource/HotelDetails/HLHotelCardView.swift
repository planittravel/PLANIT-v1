import GPUImage

class HLHotelCardView: UIView {
    @IBOutlet fileprivate weak var hotelInfoView: HLHotelInfoView!

    @IBOutlet fileprivate(set) weak var overlayView: GPUImageView!
    @IBOutlet fileprivate(set) weak var photoScrollView: HLPhotoScrollView!
    @IBOutlet fileprivate(set) weak var bottomGradientView: UIView!
    @IBOutlet weak var badgesContainerView: UIView!

    let infoViewLogic = HotelInfoViewLogic()

    private let controlsAnimationDuration: TimeInterval = 0.15
    fileprivate var showControlsTimer: Timer?

    var photoIndexChangeHandler: ((_ index: Int) -> Void)?
    var selectPhotoHandler: ((_ index: Int) -> Void)?

    var currentPhotoIndex: Int {
        get {
            return self.photoScrollView.currentPhotoIndex
        }

        set(newValue) {
            self.photoScrollView.scrollToPhotoIndex(newValue, animated: false)
        }
    }

    private(set) var hotel: HDKHotel! {
        didSet {
            if !(oldValue?.isValid() ?? false) || !hotel.isEqual(oldValue) {
                hotelInfoView.hotel = hotel
                updatePhotosContent()
            }
        }
    }

    func update(withVariant variant: HLResultVariant, shouldDrawBadges: Bool) {
        hotel = variant.hotel
        if shouldDrawBadges {
            drawBadges(variant: variant)
        }
    }

    func drawBadges(variant: HLResultVariant) {
        let badges = variant.badges as? [HLPopularHotelBadge] ?? []

        let badgesContainerSize = badgesContainerView.bounds.size
        let badgeViews = badgesContainerView.drawTextBadges(badges, forVariant: variant, startX: 15, bottomY: badgesContainerSize.height - 15, widthLimit: badgesContainerSize.width - 15 * 2)
        for badgeView in badgeViews {
            badgeView.autoSetDimensions(to: badgeView.bounds.size)
            badgeView.autoPinEdge(toSuperviewEdge: .leading, withInset: badgeView.frame.origin.x)
            badgeView.autoPinEdge(toSuperviewEdge: .bottom, withInset: badgesContainerView.bounds.size.height - (badgeView.frame.origin.y + badgeView.frame.height))
        }
    }

    var contentTransform: CATransform3D = CATransform3DIdentity {
        didSet {
            if let cell = self.photoScrollView.visibleCell {
                cell.layer.transform = self.contentTransform
            }
        }
    }

    var overlayViewOpacity: CGFloat = 0.0 {
        didSet {
            self.updateOverlayView()
        }
    }

    var hideInfoControls: Bool = false {
        didSet {
            self.hotelInfoView.isHidden = false
        }
    }

    // MARK: - Override methods

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.initialize()
    }

    override var bounds: CGRect {
        didSet {
            if !self.bounds.size.equalTo(oldValue.size) {
                self.photoScrollView.relayoutContent()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.initialize()
    }

    // MARK: - Internal Methods

    func showGradients(animated: Bool) {
        let duration = animated ? self.controlsAnimationDuration : 0.0

        UIView.animate(withDuration: duration,
            animations: { () -> Void in
                self.bottomGradientView.alpha = 1.0
            }, completion: nil)
    }

    func hideGradients(animated: Bool) {
        let duration = animated ? self.controlsAnimationDuration : 0.0

        UIView.animate(withDuration: duration,
            animations: { () -> Void in
                self.bottomGradientView.alpha = 0.0
            }, completion: nil)
    }

    func showInfoControls(animated: Bool) {
        self.hotelInfoView.showInfoControls(animated: animated)
    }

    func hideInfoControls(animated: Bool) {
        self.hotelInfoView.hideInfoControls(animated: animated)
    }

    // MARK: - Private methods

    private func initialize() {
        if let view = loadViewFromNib("HLHotelCardView", self) {
            view.frame = self.bounds
            view.clipsToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)

            view.autoPinEdgesToSuperviewEdges()
            setNeedsLayout()
        }
        photoScrollView.backgroundColor = JRColorScheme.hotelBackgroundColor()
        photoScrollView.placeholderImage = UIImage.photoPlaceholder
        overlayView.backgroundColor = JRColorScheme.mainButtonBackgroundColor()
    }

    fileprivate func updatePhotosContent() {
        self.photoScrollView.delegate = self
        self.photoScrollView.updateDataSource(withHotel: self.hotel, imageSize: HLPhotoManager.defaultHotelPhotoSize)
        self.photoScrollView.scrollToPhotoIndex(self.currentPhotoIndex, animated: false)
    }

    fileprivate func updateOverlayView() {
        self.overlayView.alpha = self.overlayViewOpacity
        self.overlayView.isUserInteractionEnabled = (self.overlayViewOpacity == 0.0)

        if !self.bottomGradientView.isHidden {
            self.bottomGradientView.alpha = 1.0 - self.overlayViewOpacity
        }
    }

    @objc fileprivate func showControlsAfterTimeout() {
        self.showControlsTimer?.invalidate()
        self.showControlsTimer = nil

        self.hotelInfoView.showInfoControls(animated: true)
    }

}

extension HLHotelCardView {

    fileprivate func processGPUPlaceholder(_ image: UIImage?) {
        if let img = image {
            let size = self.overlayView.bounds.size
            let bounds = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)

            UIGraphicsBeginImageContext(bounds.size)
            let context = UIGraphicsGetCurrentContext()
            context?.translateBy(x: 0, y: size.height)
            context?.scaleBy(x: 1.0, y: -1.0)
            context?.draw(img.cgImage!, in: bounds)

            let gpuImage = GPUImagePicture(image: UIGraphicsGetImageFromCurrentImageContext())

            UIGraphicsEndImageContext()

            let blurFilter: GPUImageGaussianBlurFilter = GPUImageGaussianBlurFilter()
            blurFilter.blurRadiusInPixels = 10.0
            blurFilter.texelSpacingMultiplier = 1.0

            gpuImage?.addTarget(blurFilter)
            blurFilter.addTarget(self.overlayView)

            gpuImage?.processImage()
        }
    }

}

extension HLHotelCardView: HLPhotoScrollViewDelegate {

    func photoCollectionViewImageContentMode() -> UIViewContentMode {
        return self.hotel.photosIds.count == 0 ? UIViewContentMode.center : UIViewContentMode.scaleAspectFill
    }

    func photoScrollPhotoIndexChanged(_ index: Int) {
        self.photoIndexChangeHandler?(index)
    }

    func photoScrollWillBeginDragging() {
        self.showControlsTimer?.invalidate()
        self.showControlsTimer = nil

        self.hotelInfoView.hideInfoControls(animated: true)
    }

    func photoScrollDidEndDragging() {
        self.showControlsTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(HLHotelCardView.showControlsAfterTimeout), userInfo: nil, repeats: false)
    }

    func photoCollectionViewDidSelectPhotoAtIndex(_ index: Int) {
        if self.hotel.photosIds.count > 0 {
            self.selectPhotoHandler?(index)
        }
    }

}
