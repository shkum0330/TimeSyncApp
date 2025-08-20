import Foundation
import ServiceManagement

@MainActor
class HelperManager: ObservableObject {
    @Published var statusMessage = "상태를 확인 중입니다..."
    @Published var isWorking = false
    @Published var isHelperInstalled = false

    private var xpcConnection: NSXPCConnection?
    private let helperLabel = "com.yourname.TimeSyncHelper"

    init() {
        checkHelperStatus()
    }

    func checkHelperStatus() {
        // SMAppService API를 사용하여 Helper가 등록되었는지 확인합니다.
        let service = SMAppService.daemon(plistName: "\(helperLabel).plist")
        
        DispatchQueue.global().async {
            let status = service.status
            DispatchQueue.main.async {
                self.isHelperInstalled = (status == .enabled)
                self.updateStatusMessage()
            }
        }
    }
    
    private func updateStatusMessage() {
        if isHelperInstalled {
            statusMessage = "도우미 도구가 설치되었습니다.\n동기화 버튼을 누르세요."
        } else {
            statusMessage = "정확한 시간 동기화를 위해\n관리자 권한이 필요한 도우미 도구를 설치해야 합니다."
        }
    }

    func installHelper() {
        guard !isWorking else { return }
        isWorking = true
        statusMessage = "도우미 도구를 설치합니다...\n암호를 입력해주세요."
        
        let service = SMAppService.daemon(plistName: "\(helperLabel).plist")
        
        DispatchQueue.global().async {
            do {
                // 사용자에게 암호를 묻고 Helper를 시스템에 등록
                try service.register()
                DispatchQueue.main.async {
                    self.isHelperInstalled = true
                    self.statusMessage = "✅ 도우미 도구 설치 성공!"
                    self.isWorking = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.statusMessage = "❌ 도우미 도구 설치 실패: \(error.localizedDescription)"
                    self.isWorking = false
                }
            }
        }
    }

    func syncTime() {
        guard !isWorking else { return }
        isWorking = true
        statusMessage = "표준시와 동기화 중입니다..."

        // XPC 연결 생성 및 재개
        let connection = NSXPCConnection(machServiceName: helperLabel, options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: TimeSyncXPCProtocol.self)
        connection.resume()
        self.xpcConnection = connection

        // Helper의 함수 호출
        guard let helper = connection.remoteObjectProxyWithErrorHandler({ error in
            DispatchQueue.main.async {
                self.statusMessage = "❌ 동기화 실패 (연결 오류): \(error.localizedDescription)"
                self.isWorking = false
            }
        }) as? TimeSyncXPCProtocol else {
            statusMessage = "❌ Helper와 통신할 수 없습니다."
            isWorking = false
            return
        }

        helper.syncTime { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.statusMessage = "❌ 동기화 실패: \(error.localizedDescription)"
                } else {
                    self.statusMessage = "✅ 동기화 성공! 시간이 표준시에 맞춰졌습니다."
                }
                self.isWorking = false
                // 연결 종료
                connection.invalidate()
            }
        }
    }
}
