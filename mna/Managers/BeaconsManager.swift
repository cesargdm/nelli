//
//  BeaconsManager.swift
//  mna
//
//  Created by César Guadarrama on 6/21/17.
//  Copyright © 2017 ibm-mx. All rights reserved.
//

import Foundation
import CoreLocation

// Make class bound
protocol BeaconDelegate: class {
    func nearBeaconsLocations(_ beacons: [CLBeacon])
}

class BeaconsManager: NSObject, CLLocationManagerDelegate {
    
    var uuid:String?
    var beaconIdentifier:String?
    
    var locationManager: CLLocationManager?
    weak var delegate: BeaconDelegate?
    
    init(uuid: String, beaconIdentifier: String) {
        super.init()
        
        print("Init beacons manager")
        
        self.uuid = uuid
        self.beaconIdentifier = beaconIdentifier
        
        locationManager = CLLocationManager() // Init location manager
        locationManager?.delegate = self // Set delegate
        locationManager?.requestAlwaysAuthorization() // Request authorization
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        default:
            print("NOT AUTHORIZED, STATUS: \(status)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        delegate?.nearBeaconsLocations(beacons)
    }
    
    
    
    func startScanning() {
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: uuid!)!, identifier: beaconIdentifier!)
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
}


