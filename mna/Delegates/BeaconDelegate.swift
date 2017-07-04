//
//  BeaconDelegate.swift
//  mna
//
//  Created by César Guadarrama on 7/3/17.
//  Copyright © 2017 ibm-mx. All rights reserved.
//

import Foundation
import CoreLocation

protocol BeaconDelegate: class {
    func didFoundClosestBeacon(_ beacon: CLBeacon?)
}
