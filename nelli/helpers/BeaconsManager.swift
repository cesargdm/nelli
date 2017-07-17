//
//  BeaconsManager.swift
//  nelli
//
//  Created by César Guadarrama on 7/17/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import Foundation
import CoreLocation

class BeaconsManager: NSObject, CLLocationManagerDelegate {
    
    var uuid:String?
    var beaconIdentifier:String?
    
    var locationManager: CLLocationManager?
    weak var delegate: BeaconDelegate?
    
    init(uuid: String, beaconIdentifier: String) {
        super.init()
        
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
        case .authorizedWhenInUse:
            // Suggest set to allways to enable push notifications
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        default:
            // TODO promot to change this
            print("NOT AUTHORIZED, STATUS: \(status)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        let numberOfBeacons = beacons.count
        // Set a closestBeacon variable
        var closestBeacon: CLBeacon?
        
        if (numberOfBeacons == 0) {
            delegate?.didFoundClosestBeacon(nil)
            return
        }
        
        for index in 0..<numberOfBeacons {
            if (closestBeacon == nil) {
                closestBeacon = beacons[index]
            } else {
                if (index+1 == numberOfBeacons-1 && beacons[index+1].accuracy > 0 && beacons[index+1].accuracy < closestBeacon!.accuracy) {
                    closestBeacon = beacons[index+1]
                }
            }
        }
        
        delegate?.didFoundClosestBeacon(closestBeacon)
    }
    
    func startScanning() {
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: uuid!)!, identifier: beaconIdentifier!)
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
}
