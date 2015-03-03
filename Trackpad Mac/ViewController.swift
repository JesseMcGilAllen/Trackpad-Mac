//  ViewController.swift
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
    
    var trackingOffset = NSPoint(x: 0.0, y: 0.0)
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    // MARK: Required to conform to CBCentralManagerDelegate Protocol
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        
        if central.state == .PoweredOn {
            println("Powered On!")
            
            central.scanForPeripheralsWithServices([trackpadServiceUUID()], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        } else {
            println(central.state.rawValue)
        }
    }
    
    // MARK: UUIDs
    
    func trackpadServiceUUID() -> CBUUID {
        
        return CBUUID(string: "AB8A3096-046C-49DD-8709-0361EC31EFED")
    }
    
    func beginTrackingCharacteristicUUID() -> CBUUID {
        return CBUUID(string: "E0A13890-5CAB-4763-863C-B639132CE144")
    }
    
    func trackingCharacteristicUUID() -> CBUUID {
        
        return CBUUID(string: "7754BF4E-9BB5-4719-9604-EE48A565F09C")
    }
    
    func eventCharacteristicUUID() -> CBUUID {
        return CBUUID(string: "DCF9D966-06D7-4663-8811-3E1A0B75EFB4")
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
            peripheral.discoverCharacteristics(nil, forService: service as! CBService)
            
            println("Discovered!")
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        if error != nil {
            println("Error discovering characteristic: \(error.localizedDescription)")
        }
        
        for characteristic in service.characteristics {
            
            discoverCharacteristic(characteristic as! CBCharacteristic, forPeripheral: peripheral)
            
        }
    }
    
    func discoverCharacteristic(characteristic : CBCharacteristic, forPeripheral peripheral: CBPeripheral) {
        
        
        
        //if characteristic.UUID == trackingCharacteristicUUID() || characteristic.UUID == beginTrackingCharacteristicUUID() {
        peripheral.setNotifyValue(true, forCharacteristic: characteristic as CBCharacteristic)
        
        
        // } else if characteristic.UUID == screenSizeCharacteristicUUID() {
        
        //     peripheral.readValueForCharacteristic(characteristic)
        
        //  }
        
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if error != nil {
            println("Error updating notification for characteristic: \(error.localizedDescription)")
        }
        
        println("Notification Value: \(characteristic.isNotifying)")
        
    }
    
    // MARK: receiving data from iPad
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        if error != nil {
            println("Error updating characteristic: \(error.code)")
            return
        }
        
        let data = characteristic.value()
        
        
        if characteristic.UUID == beginTrackingCharacteristicUUID() {
            
            trackingOffset(pointFromData(data))
            
        } else if characteristic.UUID == trackingCharacteristicUUID() {
            
            movingCursor(pointFromData(data))
            
        } else if characteristic.UUID == eventCharacteristicUUID() {
            
            eventFromData(data)
            
        }
    }
    
    // MARK: moving cursor
    
    func movingCursor(location : NSPoint) {
        
        if location != NSPoint(x: -1.0, y: 0.0) {
            
            
            let cursorLoc = cursorLocation() as NSPoint
            let difference = differenceBetweenTwoPoints(location, startPoint: trackingOffset)
            let movement = pointMultiplyScalar(difference, scalar: NSPoint(x: 0.10, y: 0.10))
            let newLocation = addingTwoPoints(cursorLoc, pointB: movement)
            
            
            
            CGDisplayMoveCursorToPoint(CGMainDisplayID(), newLocation)
        }
    }
    
    func pointFromData(data : NSData) -> NSPoint {
        
        let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        if dataString != nil {
            
            let point = NSPointFromString(dataString as! String)
            return point
            
            
        } else {
            
            return NSPoint(x: -1.0, y: 0)
        }
    }
    
    func trackingOffset(point : NSPoint) {
        
        trackingOffset = point
        println("Tracking Offset: \(trackingOffset).")
        
    }
    
    func cursorLocation() -> CGPoint {
        
        let mouseLocation = NSEvent.mouseLocation()
        return CGPoint(x: mouseLocation.x, y: NSScreen.mainScreen()!.frame.size.height - mouseLocation.y)
    }
    
    // MARK: Math
    
    func addingTwoPoints(pointA : NSPoint, pointB : NSPoint) -> NSPoint {
        
        
        return NSPoint(x: pointA.x + pointB.x, y: pointA.y + pointB.y)
    }
    
    
    
    func differenceBetweenTwoPoints(endPoint : NSPoint, startPoint : NSPoint) -> NSPoint {
        
        return NSPoint(x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
    }
    
    func pointMultiplyScalar(point : NSPoint, scalar : NSPoint) -> NSPoint {
        
        return NSPoint(x: point.x * scalar.x, y: point.y * scalar.y)
    }
    
    // MARK: Event Characteristic
    
    func eventFromData(data: NSData) {
        
        let eventString = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        if eventString != nil {
            
            println("in click event")
            
            let mouseLocation = NSEvent.mouseLocation() as CGPoint
            
            
            let leftClickDown = CGEventCreateMouseEvent(nil, CGEventType(kCGEventLeftMouseDown), cursorLocation(), CGMouseButton(kCGMouseButtonLeft)).takeUnretainedValue()
            let leftClickUp = CGEventCreateMouseEvent(nil, CGEventType(kCGEventLeftMouseUp), cursorLocation(), CGMouseButton(kCGMouseButtonLeft)).takeUnretainedValue()
            
            CGEventPost(CGEventTapLocation(kCGHIDEventTap), leftClickDown)
            CGEventPost(CGEventTapLocation(kCGHIDEventTap), leftClickUp)
            
            
        }
    }
    
}
