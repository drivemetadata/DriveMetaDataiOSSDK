//
//  DMDLogger.swift
//  Pods
//
//  Created by DriveMetaData on 01/03/25.
//

import Foundation
import UIKit

class DMDLogger {
    static let shared = DMDLogger()
    
    private let logFileName = "velev_sdk_logs.txt"
    private var logFileURL: URL? {
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDir.appendingPathComponent(logFileName)
    }

    private init() {}

    func log(_ message: String, level: LogLevel = .info) {
        let timestamp: String

        if #available(iOS 15.0, *) {
            timestamp = Date().formatted()
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Fallback format for iOS <15
            timestamp = formatter.string(from: Date())
        }

        let logMessage = "[\(timestamp)] [\(level.rawValue)] \(message)\n"

        print(logMessage) // Print to Xcode console
        appendToFile(logMessage) // Save to file
    }


    func shareLogs(from viewController: UIViewController) {
        guard let logURL = logFileURL else {
            log("Log file URL not found.", level: .error)
            return
        }

        let activityVC = UIActivityViewController(activityItems: [logURL], applicationActivities: nil)
        viewController.present(activityVC, animated: true)
    }

    private func appendToFile(_ message: String) {
        guard let logURL = logFileURL else { return }

        if !FileManager.default.fileExists(atPath: logURL.path) {
            FileManager.default.createFile(atPath: logURL.path, contents: nil, attributes: nil)
        }

        if let fileHandle = try? FileHandle(forWritingTo: logURL) {
            fileHandle.seekToEndOfFile()
            if let data = message.data(using: .utf8) {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        } else {
            try? message.write(to: logURL, atomically: true, encoding: .utf8)
        }
    }
}

enum LogLevel: String {
    case info = "INFO"
    case debug = "DEBUG"
    case error = "ERROR"
}


