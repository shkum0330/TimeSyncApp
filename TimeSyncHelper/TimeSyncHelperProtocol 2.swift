import Foundation

// 앱과 Helper 간 통신을 위한 XPC 프로토콜
@objc public protocol TimeSyncHelperProtocol {
    func setSystemTime(_ dateString: String, withReply reply: @escaping (Bool) -> Void)
}
