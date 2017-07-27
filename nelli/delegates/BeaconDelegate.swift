//
//  BeaconDelegate.swift
//  nelli
//
//  Created by César Guadarrama on 7/17/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import Foundation
import CoreLocation

protocol BeaconDelegate: class {
    func didFoundClosestBeacon(_ beacon: CLBeacon?)
}
