//
//  ContentView.swift
//  Orbi
//
//  Created by Pooria on 1403/12/3.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var textToSend = "Hello ESP32!"
    
    var body: some View {
        VStack {
            Text("Bluetooth Connection Status: \(bluetoothManager.isConnected ? "Connected" : "Disconnected")")
                .padding()
                .foregroundColor(bluetoothManager.isConnected ? .green : .red)
            
            TextField("Text to send", text: $textToSend)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Send to ESP32") {
                bluetoothManager.sendDataToESP32(data: textToSend)
            }
            .padding()
            .background(bluetoothManager.isConnected ? Color.green : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(!bluetoothManager.isConnected)
            
            Text("Received from ESP32: \(bluetoothManager.receivedData)")
                .padding()
        }
        .onAppear {
            bluetoothManager.centralManager.delegate = bluetoothManager
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
