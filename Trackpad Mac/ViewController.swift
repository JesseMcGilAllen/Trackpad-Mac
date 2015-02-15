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
    
    var centralManager : CBCentralManager!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        centralManager.scanForPeripheralsWithServices(nil, options: nil)

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println(central.state.rawValue)
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("Discovered \(peripheral.name)!")
    }


}

