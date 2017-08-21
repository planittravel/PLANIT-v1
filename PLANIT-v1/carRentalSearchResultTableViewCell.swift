//
//  carRentalSearchResultTableViewCell.swift
//  PLANIT-v1
//
//  Created by MICHAEL WURM on 6/23/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class carRentalSearchResultTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var departureDepartureTime: UILabel!
    @IBOutlet weak var departureOrigin: UILabel!
    @IBOutlet weak var departureArrivalTime: UILabel!
    @IBOutlet weak var departureDestination: UILabel!
    @IBOutlet weak var returnDepartureTime: UILabel!
    @IBOutlet weak var returnOrigin: UILabel!
    @IBOutlet weak var returnArrivalTime: UILabel!
    @IBOutlet weak var returnDestination: UILabel!
    @IBOutlet weak var additionalDetailsExpandedView: UILabel!
    @IBOutlet weak var expandedView: UIView!
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet weak var expandedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectFlightButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var showDetails = false {
        didSet {
            expandedViewHeightConstraint.priority = showDetails ? 250 :999
        }
    }
    
}
