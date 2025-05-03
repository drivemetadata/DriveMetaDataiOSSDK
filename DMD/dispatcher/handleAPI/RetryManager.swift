//
//  RetryManager.swift
//  Pods
//
//  Created by DriveMetaData on 03/05/25.
//

class RetryManager {
    private let baseDelay: TimeInterval = 0.5 // 500ms
    private let maxWait: TimeInterval = 60.0 // 60s
    private let maxRetries = 8
    private var failedEvents: [[String: Any]] = []
    private let batchSize = 5
    private let retryQueue = DispatchQueue(label: "retry.queue", attributes: .concurrent)
    
    func sendRequest(url: URL, payload: [String: Any], attempt: Int = 0) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                self.handleRetry(url: url, payload: payload, attempt: attempt, errorType: "Network")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            switch httpResponse.statusCode {
            case 200..<300:
                print("Request successful")
            case 400:
                print("Bad request, not retrying.")
            case 429:
                if #available(iOS 13.0, *) {
                    let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After") ?? "60"
                    let waitTime = Double(retryAfter) ?? 60.0
                    self.scheduleRetry(url: url, payload: payload, attempt: attempt, delay: waitTime)
                } else {
                    // Fallback on earlier versions
                }
               
            case 500..<600:
                self.handleRetry(url: url, payload: payload, attempt: attempt, errorType: "Server")
            default:
                print("Unexpected response: \(httpResponse.statusCode)")
            }
        }
        task.resume()
    }
    
    private func handleRetry(url: URL, payload: [String: Any], attempt: Int, errorType: String) {
        if attempt >= maxRetries {
            print("Max retries reached for event, storing locally.")
            storeFailedEvent(payload)
            return
        }
        let jitter = Double.random(in: -0.5...0.5) * baseDelay
        let waitTime = min(baseDelay * pow(2.0, Double(attempt)) + jitter, maxWait)
        scheduleRetry(url: url, payload: payload, attempt: attempt, delay: waitTime)
    }
    
    private func scheduleRetry(url: URL, payload: [String: Any], attempt: Int, delay: TimeInterval) {
        retryQueue.asyncAfter(deadline: .now() + delay) {
            print("Retrying request (attempt \(attempt + 1)) after \(delay)s")
            self.sendRequest(url: url, payload: payload, attempt: attempt + 1)
        }
    }
    
    private func storeFailedEvent(_ payload: [String: Any]) {
        failedEvents.append(payload)
        UserDefaults.standard.setValue(failedEvents, forKey: "failedEvents")
    }
    
    func retryStoredEvents(url: URL) {
        let events = UserDefaults.standard.array(forKey: "failedEvents") as? [[String: Any]] ?? []
        if events.isEmpty { return }
        
        for event in events.prefix(batchSize) {
            sendRequest(url: url, payload: event)
        }
        
      //  failedEvents.removeAll(where: { events.contains(where: $0) })
        UserDefaults.standard.setValue(failedEvents, forKey: "failedEvents")
    }
    
    private func refreshAuthToken(completion: @escaping (Bool) -> Void) {
        // Simulate token refresh
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            print("Token refreshed.")
            completion(true)
        }
    }
}
