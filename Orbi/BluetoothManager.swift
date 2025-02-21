//
//  BluetoothManager.swift
//  Orbi
//
//  Created by Pooria on 1403/12/3.
//


import Foundation
import CoreBluetooth
import UserNotifications

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    
    @Published var isConnected = false
    @Published var receivedData = ""
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    // MARK: - Central Manager Delegate Methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        // Assuming you are looking for a device with a known name or UUID
        if let peripheralName = peripheral.name, peripheralName.contains("ESP32") {
            self.peripheral = peripheral
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        isConnected = true
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if service.uuid == CBUUID(string: "12345678-1234-1234-1234-123456789012") {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == CBUUID(string: "87654321-4321-4321-4321-210987654321") {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value,
           let stringValue = String(data: value, encoding: .utf8),
           stringValue == "Trigger Notification" {
            // Update the received data
            receivedData = stringValue
            showNotification()
        }
    }
    
    // MARK: - Show Notification
    func showNotification() {
        let content = UNMutableNotificationContent()
        content.title = "BLE Alert!"
        content.body = "The ESP32 just sent a notification trigger."
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "BLENotification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}