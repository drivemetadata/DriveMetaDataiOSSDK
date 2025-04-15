import Network

class OfflineSyncManager {
    static let shared = OfflineSyncManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private var _isConnected = true
    private let stateQueue = DispatchQueue(label: "com.offlinesync.state", attributes: .concurrent)
    private var isConnected: Bool {
        get {
            return stateQueue.sync { _isConnected }
        }
        set {
            stateQueue.async(flags: .barrier) {
                self._isConnected = newValue
            }
        }
    }

    private var offlineDataQueue: [[String: Any]] = []

    private init() {
        startNetworkMonitoring()
    }

    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            self.isConnected = path.status == .satisfied
            print("Network status changed: \(self.isConnected ? "Connected" : "Disconnected")")
            if self.isConnected {
                self.syncOfflineData()
            }
        }
        monitor.start(queue: queue)
    }

    func sendUserDetails(_ details: [String: Any], eventType: String, endPoint: String) {
        if isConnected {
            sendToServer(details, eventType: eventType, endPoint: endPoint)
        } else {
            print("No internet. Caching data for later...")
            cacheFailedEvent(data: details, eventType: eventType, endPoint: endPoint)
        }
    }

    func cacheFailedEvent(data: [String: Any], eventType: String, endPoint: String) {
        print("Caching failed event: \(eventType)")
        var cached = data
        cached["__eventType"] = eventType
        cached["__endPoint"] = endPoint
        offlineDataQueue.append(cached)
    }

    private func sendToServer(_ data: [String: Any], eventType: String, endPoint: String) {
       
    }

    private func syncOfflineData() {
        print("Syncing offline data (\(offlineDataQueue.count) events)...")
        for data in offlineDataQueue {
            let eventType = data["__eventType"] as? String ?? ""
            let endPoint = data["__endPoint"] as? String ?? ""
            
            var cleanData = data
            cleanData.removeValue(forKey: "__eventType")
            cleanData.removeValue(forKey: "__endPoint")

            sendToServer(cleanData, eventType: eventType, endPoint: endPoint)
        }
        offlineDataQueue.removeAll()
    }
}
