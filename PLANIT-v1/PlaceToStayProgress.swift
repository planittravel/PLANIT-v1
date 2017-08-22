//
//  PlaceToStayProgress.swift
//  PLANIT-v1
//
//  Created by MICHAEL WURM on 8/22/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import Foundation
import UIKit


enum PlaceToStayProgress {
    case noProgress
    case onlyTypeChosenHotel
    case onlyTypeChosenShortTermRental
    case onlyTypeChosenStayWithSomeoneIKnow
    case typeChosenHotelAndDetailsProvided
    case typeChosenShortTermRentalAndDetailsProvided
    case typeChosenStayWithSomeoneIKnowAndDetailsProvided
    case typeChosenHotelAndPlanitHotelFavorited
    case typeChosenHotelAndPlanitHotelBooked
}

