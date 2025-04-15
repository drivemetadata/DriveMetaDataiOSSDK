//
//  DMDException.swift
//  Pods
//
//  Created by DriveMetaData on 12/04/25.
//

import Foundation

class ExceptionLogger {
    
    // MARK: - Singleton
    static let shared = ExceptionLogger()
    
    private init() {} // Prevent external initialization

    // MARK: - Send Exception
    func sendException(message: String, stacktrace: String) {
       
       
        // Payload
        let payload: [String: Any] = [
            "exception": [
                "message": message,
                "stacktrace": stacktrace
            ]
        ]
        MetadataBuilder.sendEvent(
            eventType: "exception",
            tags: payload,
            includeExtraDetails: true,
            endPoint: "exception",

            onSuccess: { response in

                print("Send Exception to Server  Success: \(response)")
            },
            onFailure: { error in
                
               

            }
            )

       
    }
}
