import Foundation

// @objc는 Objective-C와 호환되도록 하여 XPC에서 사용할 수 있게 함
// 이 프로토콜은 Helper가 제공할 기능을 정의
@objc(TimeSyncXPCProtocol)
public protocol TimeSyncXPCProtocol {
    /// 시스템 시간을 KRISS 서버와 동기화하고 결과를 콜백으로 반환
    func syncTime(with reply: @escaping (Error?) -> Void)
}
