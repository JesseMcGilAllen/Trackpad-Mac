//w//  ViewController.swift
//  Trackpad Mac
//
//  Created by Jesse McGil Allen on 2/14/15.
//  Copyright (c) 2015 Jesse McGil Allen. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    let trackpadServiceUUID = CBUUID(string: "AB8A3096-046C-49DD-8709-0361EC31EFED")
    let trackingCharacteristicUUID = CBUUID(string: "7754BF4E-9BB5-4719-9604-EE48A565F09C")
    
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
        
        peripheral.delegate = self
        
        peripheral.discoverServices([trackpadServiceUUID])
        
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Failed to Connect :(")
        
        if error != nil {
            println("Error publishing service: \(error.localizedDescription)")
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        
        if error != nil {
            println("Error discovering service: \(error.localizedDescription)")
        }
        
        for service in peripheral.services {
            peripheral.discoverCharacteristics([trackingCharacteristicUUID], forService: service as! CBService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        if error != nil {
            println("Error discovering characteristic: \(error.localizedDescription)")
        }
        
        for characteristic in service.characteristics {
            let characteristicUUID = characteristic.UUID
            println(characteristic.UUIDString)
            println(trackingCharacteristicUUID.UUIDString)
            
            if characteristicUUID == trackingCharacteristicUUID {
                peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
                println("Success!")
            }
            
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        println("data updated")
        if error != nil {
            println("Error updating characteristic: \(error.localizedDescription)")
        }
        
        let updatedData = characteristic.value()
        let count = updatedData.length / sizeof(UInt32)
        
        var dataArray = [UInt32](count: count, repeatedValue: 0)
        
        updatedData.getBytes(&dataArray, length:count * sizeof(UInt32))
        
        println(dataArray)
        
    }
}


