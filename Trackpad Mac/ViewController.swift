//w//  ViewController.swift
//  Trackpad Mac
//
//  Created by Jesse McGil Allen on 2/14/15.
//  Copyright (c) 2015 Jesse McGil Allen. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager : CBCentralManager!
    var discoveredPeripheral : CBPeripheral?
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }

    // MARK: Required to conform to CBCentralManagerDelegate Protocol
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
   
        
        if central.state == .PoweredOn {
            println("Powered On!")
            
            central.scanForPeripheralsWithServices([trackpadServiceUUID()], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func trackpadServiceUUID() -> CBUUID {
        
        return CBUUID(string: "AB8A3096-046C-49DD-8709-0361EC31EFED")
    }
    
    func trackingCharacteristicUUID() -> CBUUID {
        
        return CBUUID(string: "7754BF4E-9BB5-4719-9604-EE48A565F09C")
    }
    
    // MARK: Discovering Peripherals
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {


        discoveredPeripheral = peripheral
        discoveredPeripheral!.delegate = self
        
        central.connectPeripheral(peripheral, options: nil)


        
    }
    
    // MARK: Connecting Peripherals
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("Connected!")
        
        
        // discoveredPeripheral = peripheral
        centralManager.stopScan()
        
        peripheral.discoverServices([trackpadServiceUUID()])
        
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Failed to Connect :(")
        
        if error != nil {
            println("Error publishing service: \(error.localizedDescription)")
        }
    }
    
    // MARK: Discovering Services & Characteristics
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        println("In Discovery")
        if error != nil {
            println("Error discovering service: \(error.localizedDescription)")
        }
        
        for service in peripheral.services {
            peripheral.discoverCharacteristics([trackingCharacteristicUUID()], forService: service as! CBService)
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
            println(trackingCharacteristicUUID().UUIDString)
            
            if characteristicUUID == trackingCharacteristicUUID() {
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
        
    }
    
    // MARK: receiving data from iPad
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        println("Value updated")
        
        if error != nil {
            println("Error updating characteristic: \(error.code)")
            return
        }
        
        let data = characteristic.value()
        
        movingCursor(pointFromData(data))

    }
    
    // MARK: moving cursor
    
    func movingCursor(location : NSPoint) {
        if location != NSPoint(x: -1.0, y: 0.0) {
            CGDisplayMoveCursorToPoint(CGMainDisplayID(), location)
        }
    }
    
    func pointFromData(data : NSData) -> NSPoint {
        let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        if dataString != nil {
            return NSPointFromString(dataString as! String)
        } else {
            return NSPoint(x: -1.0, y: 0)
        }
    }
    
    
}


