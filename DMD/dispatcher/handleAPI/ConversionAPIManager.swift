//
//  ConversionAPIManager.swift
//  Pods
//
//  Created by DriveMetaData on 06/04/25.
//

class ConversionAPIManager {
    
    static let shared = ConversionAPIManager()

    private init() {}

    func sendConversionRequest(
        includeValue: Bool = false,
        value: String? = nil,
        onCompletion: ((String?) -> Void)? = nil
    ) {
        // Generate base URL
        let requestID = DeviceInfoManager.shared.getAnonymousId()
        var urlString = APIConfig.shared.baseURL + requestID

        // Add query param if needed
        if includeValue, let value = value {
            urlString += "?value=\(value)"
        }

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            onCompletion?(nil)
            return
        }

        print("Final URL: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Set headers
        let retrievedData = StorageManager.shared.getClientData()

        if let clientId = retrievedData.clientId {
            request.setValue(String(clientId), forHTTPHeaderField: "client-id")
        }

        if let token = retrievedData.clientToken {
            request.setValue(token, forHTTPHeaderField: "token")
        }

        if let workspaceId = retrievedData.workspaceId {
            request.setValue(String(workspaceId), forHTTPHeaderField: "workspace-id")
        }
        print(request)

        // Perform request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request error: \(error)")
                ExceptionLogger.shared.sendException(message: "sendConversionRequest workspce id :\(retrievedData.workspaceId)",stacktrace: "Request error: \(error)")
                onCompletion?(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                onCompletion?(nil)
                return
            }

            print("Status Code: \(httpResponse.statusCode)")

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
                onCompletion?(responseString)
            } else {
                onCompletion?(nil)
            }
        }

        task.resume()
    }
}
