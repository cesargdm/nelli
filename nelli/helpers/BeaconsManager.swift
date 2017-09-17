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
    
    // CONSTANTS
    private var pieces = Piece.getPieces()
    
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
        
        
        
        print(("----------------"))
        for index in 0..<numberOfBeacons {
            //print("[PRE]index:\(index)")
            //print("isNIL:\(closestBeacon==nil)")

            if (closestBeacon == nil) {
                //print("NILclosest:\(index)")
                closestBeacon = beacons[index]
            } else {
                if (beacons[index].accuracy > 0 && beacons[index].accuracy < closestBeacon!.accuracy ) {
                    //print("STUFF")
                    closestBeacon = beacons[index]
                }
            }
            if(isBeaconRangeValid( beaconToValidate: closestBeacon! )){
                delegate?.didFoundClosestBeacon(closestBeacon)
            }else{
                delegate?.didFoundClosestBeacon(nil)
            }
            print("[REAL]index:\(index)")
            print("[\(beacons[index].major)][\(beacons[index].minor)] \(beacons[index].accuracy) > 0 && [\(beacons[index].major)][\(beacons[index].minor)]\(beacons[index].accuracy) < [\(closestBeacon!.major)][\(closestBeacon!.minor)] \(closestBeacon!.accuracy)")
            
        }
        print(("----------------"))
        
    }
    
    
    
    func isBeaconRangeValid( beaconToValidate: CLBeacon ) -> Bool {
        
        let major = beaconToValidate.major.intValue
        let minor = beaconToValidate.minor.intValue
        print("prox:\(beaconToValidate.proximity.rawValue)")
        if let piece = pieces[major]?[minor] {
            if(piece.minRange >= beaconToValidate.accuracy && beaconToValidate.accuracy >= 0 ){
                return true
            }else{
                return false
            }
        }
        return false
    }
    
    func startScanning() {
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: uuid!)!, identifier: beaconIdentifier!)
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
}
