//
//  BatteryLog.swift
//  
//
//  Created  on 26/08/2020.
//  Copyright © 2020 . All rights reserved.
//

import UIKit
import NotificationCenter
import os

/// Battery log for monitoring battery level over time
class BatteryLog {
    private let logger = ConcreteSensorLogger(subsystem: "Sensor", category: "BatteryLog")
    private let textFile: TextFile
    private let dateFormatter = DateFormatter()

    init(filename: String) {
        textFile = TextFile(filename: filename)
        if textFile.empty() {
            textFile.write("time,source,level")
        }
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        update()
    }
    
    private func timestamp() -> String {
        let timestamp = dateFormatter.string(from: Date())
        return timestamp
    }

    private func update() {
        let powerSource = (UIDevice.current.batteryState == .unplugged ? "battery" : "external")
        let batteryLevel = Float(UIDevice.current.batteryLevel * 100).description
        textFile.write(timestamp() + "," + powerSource + "," + batteryLevel)
        logger.debug("update (powerSource=\(powerSource),batteryLevel=\(batteryLevel))");
    }
    
    @objc func batteryLevelDidChange(_ sender: NotificationCenter) {
        update()
    }
    
    @objc func batteryStateDidChange(_ sender: NotificationCenter) {
        update()
    }
}