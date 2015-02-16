//
//  ViewController.swift
//  Trackpad Mac
//
//  Created by Jesse McGil Allen on 2/14/15.
//  Copyright (c) 2015 Jesse McGil Allen. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, CBCentralManagerDelegate {
    
    let trackpadServiceUUID = CBUUID(string: "AB8A3096-046C-49DD-8709-0361EC31EFED")
    var centralManager : CBCentralManager!
    var discoveredPeripheral : CBPeripheral!
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        
        

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
    println("State: \(central.state.rawValue)")
        
        if central.state == .PoweredOn {
            println("Powered On!")
            
            central.scanForPeripheralsWithServices([trackpadServiceUUID], options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("Discovered \(peripheral.identifier), RSSI: \(RSSI)!")
        
        discoveredPeripheral = peripheral
        centralManager.connectPeripheral(discoveredPeripheral, options: nil)
        
        centralManager.stopScan()
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Connected!")
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Failed to Connect :(")
        
        if error != nil {
            println("Error publishing service: \(error.localizedDescription)")
        }
    }


}

