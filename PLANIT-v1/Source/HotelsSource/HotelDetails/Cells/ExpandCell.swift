class ExpandCell: HLHotelDetailsTableCell {

    @IBOutlet private weak var button: RightSideImageButton!
    var selectionBlock: (() -> Void)?

    var title: String? {
        didSet {
            button?.setTitle(title, for: .normal)
        }
    }

    func showArrow() {
        let image = UIImage(named: "lightGreenRightArrow")
        button.setImage(image, for: .normal)
        button.tintColor = JRColorScheme.mainButtonBackgroundColor()
    }

    func hideArrow() {
        button.setImage(nil, for: .normal)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        button.setTitleColor(JRColorScheme.mainButtonBackgroundColor(), for: .normal)
    }

    @IBAction func action() {
        selectionBlock?()
    }
}
