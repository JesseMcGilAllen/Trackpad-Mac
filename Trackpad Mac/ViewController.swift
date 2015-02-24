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
    var discoveredPeripheral : CBPeripheral?
    
    var peripherals = [CBPeripheral]()
    
    var count = 1
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        discoveredPeripheral?.delegate = self
        
        
        

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
            
            central.scanForPeripheralsWithServices([trackpadServiceUUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {


        discoveredPeripheral = peripheral
        peripheral.delegate = self
        central.connectPeripheral(peripheral, options: nil)


        
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Connected!")
        
        
        discoveredPeripheral = peripheral
        centralManager.stopScan()
        
        peripheral.discoverServices([trackpadServiceUUID])
        
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Failed to Connect :(")
        
        if error != nil {
            println("Error publishing service: \(error.localizedDescription)")
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        println("In Discovery")
        if error != nil {
            println("Error discovering service: \(error.localizedDescription)")
        }
        
        for service in peripheral.services {
            peripheral.discoverCharacteristics([trackingCharacteristicUUID], forService: service as! CBService)
            println("Discovered!")
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        if error != nil {
            println("Error discovering characteristic: \(error.localizedDescription)")
        }
        
        for characteristic in service.characteristics {
            let characteristicUUID = characteristic.UUID
            println(characteristicUUID)
            println(trackingCharacteristicUUID.UUIDString)
            
            if characteristicUUID == trackingCharacteristicUUID {
               peripheral.setNotifyValue(true, forCharacteristic: characteristic as! CBCharacteristic)
               
               println("Success!")
            }
            
        }
    }

    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {

        if error != nil {
            println("Error updating notification for characteristic: \(error.localizedDescription)")
        }

        println("Notification Value: \(characteristic.isNotifying)")
        println("Successfully subscribed to updates on \(characteristic)")
        peripheral.readValueForCharacteristic(characteristic)
    }
    
    typealias DoublePoint = (x: Double, y: Double)
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        println("Value updated")
        
        if error != nil {
            println("Error updating characteristic: \(error.code)")
        }
        
        let data = characteristic.value()
        
        // println(updatedValue)
        
       
        if (data.length == sizeof(DoublePoint)) {
            var receivedPair = UnsafePointer<DoublePoint>(data.bytes).memory
            var receivedPoint = CGPointMake(CGFloat(receivedPair.x), CGFloat(receivedPair.y))
            
            println(receivedPoint)
        }
        
        
        
    }
}


