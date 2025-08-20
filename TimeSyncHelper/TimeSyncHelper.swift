import Foundation

class TimeSyncHelper: NSObject, NSXPCListenerDelegate, TimeSyncXPCProtocol {

    private let listener: NSXPCListener

    override init() {
        // XPC 리스너를 서비스 이름으로 초기화
        self.listener = NSXPCListener(machServiceName: "com.yourname.TimeSyncHelper")
        super.init()
        self.listener.delegate = self
    }

    // XPC 연결 요청이 들어오면 호출
    func listener(_ listener: NSXPCListener, shouldAcceptNewXPCConnection newConnection: NSXPCConnection) -> Bool {
        // 통신 규약(프로토콜)을 설정
        newConnection.exportedInterface = NSXPCInterface(with: TimeSyncXPCProtocol.self)
        newConnection.exportedObject = self
        
        // 연결을 재개하고 수락
        newConnection.resume()
        return true
    }
    
    // 이 객체가 XPC 리스너를 실행하도록 함
    func run() {
        self.listener.resume()
        // Helper가 바로 종료되지 않도록 RunLoop를 실행
        RunLoop.current.run()
    }
    
    // MARK: - TimeSyncXPCProtocol 구현
    
    /// 시스템 시간을 KRISS 서버와 동기화
    func syncTime(with reply: @escaping (Error?) -> Void) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sntp")
        process.arguments = ["-sS", "time.kriss.re.kr"]
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                // 성공적으로 종료되면 에러 없이 콜백 호출
                reply(nil)
            } else {
                // 오류가 발생하면 에러 객체를 만들어 콜백으로 전달
                let error = NSError(domain: "TimeSyncHelperError", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: "sntp command failed."])
                reply(error)
            }
        } catch {
            // Process 실행 자체에 실패한 경우
            reply(error)
        }
    }
}
