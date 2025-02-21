//
//  BluetoothManager.swift
//  Orbi
//
//  Created by Pooria on 1403/12/3.
//


import Foundation
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var targetCharacteristic: CBCharacteristic?

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
        if let peripheralName = peripheral.name, peripheralName.contains("ESP32") {
            self.peripheral = peripheral
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        isConnected = true
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        isConnected = false
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
                    targetCharacteristic = characteristic
                    
                    // Enable notifications for this characteristic
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }
    }

    // This is where the iOS app will receive the response from ESP32
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            if let responseString = String(data: value, encoding: .utf8) {
                // Update your state to reflect the received data
                receivedData = responseString
                print("Received data from ESP32: \(responseString)")
            }
        }
    }

    // MARK: - Sending Data to ESP32
    func sendDataToESP32(data: String) {
        if let peripheral = peripheral, let characteristic = targetCharacteristic {
            let dataToSend = Data(data.utf8)
            peripheral.writeValue(dataToSend, for: characteristic, type: .withResponse)
        }
    }
}

