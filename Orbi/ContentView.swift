//
//  ContentView.swift
//  Orbi
//
//  Created by Pooria on 1403/12/3.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    
    var body: some View {
        VStack {
            Text("Bluetooth Connection Status: \(bluetoothManager.isConnected ? "Connected" : "Disconnected")")
                .padding()
                .foregroundColor(bluetoothManager.isConnected ? .green : .red)
            
            Text("Received Data: \(bluetoothManager.receivedData)")
                .padding()
                .foregroundColor(.blue)
        }
        .onAppear {
            // This can be used to initiate Bluetooth scanning on screen load if needed
        }
        .onChange(of: bluetoothManager.isConnected) { newValue in
            if newValue {
                print("Successfully connected to ESP32!")
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
