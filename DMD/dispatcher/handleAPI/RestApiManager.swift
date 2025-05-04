import Foundation

final class RestApiManager {
    
    // MARK: - Constants
    private enum Constants {
        static let conversionMappingKey = "skan_conversion_mapping"
        static let maxRetries = 3
        static let retryDelay: TimeInterval = 2.0
        static let contentType = "application/json"
        static let acceptHeader = "Accept"
        static let contentTypeHeader = "Content-Type"
    }
    
    // MARK: - Shared Instance
    static let shared = RestApiManager()
    
    // MARK: - Properties
    private var conversionMappings: [String: Any] = [:]
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    public func sendRequest(
        jsonData: [String: Any],
        endPoint: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        sendRequestWithRetry(
            jsonData: jsonData,
            endPoint: endPoint,
            attempt: 1,
            completion: completion
        )
    }
    
    public func sendEventToBackend(
        name: String,
        timestamp: Date,
        fineValue: Int,
        coarseValue: String,
        window: Int,
        attempt: Int = 1,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let path = EndPointConfig.shared.updateConversionApi + DeviceInfoManager.shared.getAnonymousId()
        let query = "?value=\(fineValue)"
        
        guard let url = URL(string: APIConfig.shared.baseURL + path + query) else {
            debugPrint("Invalid URL")
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let retrievedData = StorageManager.shared.getClientData()
        guard let clientId = retrievedData.clientId,
              let workspaceId = retrievedData.workspaceId,
              let clientAppId = retrievedData.clientAppId,
              let clientToken = retrievedData.clientToken else {
            debugPrint("Missing required header value(s) in retrievedData")
            completion(.failure(NSError(domain: "Missing Header", code: 400, userInfo: nil)))
            return
        }
        
        request.addValue(String(clientId), forHTTPHeaderField: DMDConstants.CLIENT_ID)
        request.addValue(String(workspaceId), forHTTPHeaderField: DMDConstants.WORKSPACE_ID)
        request.addValue(String(clientAppId), forHTTPHeaderField: DMDConstants.APP_ID)
        request.addValue(clientToken, forHTTPHeaderField: DMDConstants.TOKEN)
        
        executeRequestWithRetry(
            request: request,
            attempt: attempt,
            completion: completion
        )
    }
    
    public func fetchConversionConfig(
        attempt: Int = 1,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let url = URL(string: APIConfig.shared.baseURL + EndPointConfig.shared.conversionValueMappingApi) else {
            debugPrint("Invalid URL for conversion config")
            loadCachedConfig()
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let retrievedData = StorageManager.shared.getClientData()
        guard let clientId = retrievedData.clientId,
              let workspaceId = retrievedData.workspaceId,
              let clientAppId = retrievedData.clientAppId,
              let clientToken = retrievedData.clientToken else {
            debugPrint("Missing required header value(s) in retrievedData")
            loadCachedConfig()
            completion(.failure(NSError(domain: "Missing Header", code: 400, userInfo: nil)))
            return
        }
        
        request.addValue(String(clientId), forHTTPHeaderField: DMDConstants.CLIENT_ID)
        request.addValue(String(workspaceId), forHTTPHeaderField: DMDConstants.WORKSPACE_ID)
        request.addValue(String(clientAppId), forHTTPHeaderField: DMDConstants.APP_ID)
        request.addValue(clientToken, forHTTPHeaderField: DMDConstants.TOKEN)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self else { return }
            
            if let error = error {
                self.loadCachedConfig()
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                self.loadCachedConfig()
                completion(.failure(NSError(domain: "Network error", code: 500, userInfo: nil)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    self.conversionMappings = json
                    debugPrint(self.conversionMappings)
                    
                    UserDefaults.standard.setValue(json, forKey: Constants.conversionMappingKey)
                    completion(.success("Conversion config fetched successfully"))
                } else {
                    self.loadCachedConfig()
                    completion(.failure(NSError(domain: "Invalid JSON Format", code: 500, userInfo: nil)))
                }
            } catch {
                debugPrint("JSON decoding error: \(error)")
                self.loadCachedConfig()
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // MARK: - Private Methods
    private func sendRequestWithRetry(
        jsonData: [String: Any],
        endPoint: String,
        attempt: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let urlString = endPoint == "exception"
            ? APIConfig.shared.baseUrl + EndPointConfig.shared.apiException
            : APIConfig.shared.baseUrl + endPoint
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(Constants.contentType, forHTTPHeaderField: Constants.contentTypeHeader)
        request.setValue(Constants.contentType, forHTTPHeaderField: Constants.acceptHeader)
        
        do {
            let jsonDataEncoded = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
            request.httpBody = jsonDataEncoded
            if let jsonString = String(data: jsonDataEncoded, encoding: .utf8) {
                debugPrint("Request Body: \(jsonString)")
            }
        } catch {
            completion(.failure(error))
            return
        }
        
        executeRequestWithRetry(
            request: request,
            attempt: attempt,
            completion: completion
        )
    }
    
    private func executeRequestWithRetry(
        request: URLRequest,
        attempt: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleRequestError(
                    error: error,
                    request: request,
                    attempt: attempt,
                    completion: completion
                )
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "No HTTP Response", code: 500, userInfo: nil)
                self.handleRequestError(
                    error: error,
                    request: request,
                    attempt: attempt,
                    completion: completion
                )
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let error = NSError(domain: "HTTP Error", code: httpResponse.statusCode, userInfo: nil)
                self.handleRequestError(
                    error: error,
                    request: request,
                    attempt: attempt,
                    completion: completion
                )
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "No Data Received", code: httpResponse.statusCode, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            self.handleSuccessfulResponse(
                data: data,
                statusCode: httpResponse.statusCode,
                completion: completion
            )
        }.resume()
    }
    
    private func handleRequestError(
        error: Error,
        request: URLRequest,
        attempt: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        debugPrint("Attempt \(attempt) failed with error: \(error.localizedDescription)")
        
        if attempt < Constants.maxRetries {
            DispatchQueue.global().asyncAfter(deadline: .now() + Constants.retryDelay) { [weak self] in
                self?.executeRequestWithRetry(
                    request: request,
                    attempt: attempt + 1,
                    completion: completion
                )
            }
        } else {
            completion(.failure(error))
        }
    }
    
    private func handleSuccessfulResponse(
        data: Data,
        statusCode: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let success = jsonObject["success"] as? Bool, success {
                    if !StorageManager.shared.isFirstTimeInstall() {
                        StorageManager.shared.setFirstTimeInstall(true)
                    }
                    completion(.success("Success: \(jsonObject)"))
                } else {
                    completion(.failure(NSError(
                        domain: "Request Failed",
                        code: statusCode,
                        userInfo: jsonObject
                    )))
                }
            } else {
                completion(.failure(NSError(
                    domain: "Invalid JSON Format",
                    code: statusCode,
                    userInfo: nil
                )))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func loadCachedConfig() {
        if let savedConfig = UserDefaults.standard.value(forKey: Constants.conversionMappingKey) as? [String: Any] {
            conversionMappings = savedConfig
            debugPrint("Loaded cached conversion mappings: \(conversionMappings)")
        } else {
            debugPrint("No cached conversion config found.")
        }
    }
}
