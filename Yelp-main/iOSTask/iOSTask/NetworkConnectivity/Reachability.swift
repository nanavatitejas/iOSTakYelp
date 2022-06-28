
import Foundation
import Network
import SystemConfiguration

class Reachability {
    static let shared = Reachability()
     func checkNetwork(completion: @escaping (Bool) -> Void) {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            completion(false)
            return
            //return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            completion(false)

            //return false
        }
        if flags.isEmpty {
            completion(false)

           // return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        completion(isReachable && !needsConnection)

       // return (isReachable && !needsConnection)
    }
}


