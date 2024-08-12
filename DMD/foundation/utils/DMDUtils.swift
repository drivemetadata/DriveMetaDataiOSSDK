//
//  DMDUtils.swift
//  DriveMetaDataiOSSDK
//
//  Created by DriveMetaData on 31/03/24.
//

import Foundation

class Utils
{
    public static func getDeviceNameAndOSVersion() -> (deviceName: String, osVersion: String) {
        let device = UIDevice.current
        let deviceName = device.name
        let osVersion = device.systemVersion
        return (deviceName, osVersion)
    }
    public static func getAppVersion()-> String
    {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        } else {
           return ""
        }
    }

  public static  func getIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }

                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family

                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    // Check if the interface is en0 (Wi-Fi) or another network interface
                    if let name = interface?.ifa_name, String(cString: name) == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo(interface?.ifa_addr, socklen_t(interface!.ifa_addr.pointee.sa_len),
                                       &hostname, socklen_t(hostname.count),
                                       nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                            address = String(cString: hostname)
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }

        return address
    }

    
}
