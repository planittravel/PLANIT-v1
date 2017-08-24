//
//  TravelProgress.swift
//  PLANIT-v1
//
//  Created by MICHAEL WURM on 8/22/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import Foundation
import UIKit


enum TravelProgress {
    case noProgress
    case onlyTypeChosenFly
    case onlyTypeChosenDrive
    case onlyTypeChosenBusTrainOther
    case typeChosenFlyAndDetailsProvided
    case typeChosenDriveAlreadyHaveCar
    case typeChosenDriveRentalCar
    case typeChosenBusTrainOtherAndDetailsProvided
    case typeChosenFlyAndPlanitFlightFavorited
    case typeChosenFlyAndPlanitFlightBooked
    case typeChosenIllAlreadyBeThere
}
