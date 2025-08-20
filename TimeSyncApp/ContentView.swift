import SwiftUI

struct ContentView: View {
    @StateObject private var helperManager = HelperManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("대한민국 표준시 동기화")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(helperManager.statusMessage)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                if helperManager.isHelperInstalled {
                    helperManager.syncTime()
                } else {
                    helperManager.installHelper()
                }
            }) {
                HStack {
                    Image(systemName: helperManager.isHelperInstalled ? "arrow.triangle.2.circlepath" : "square.and.arrow.down")
                    Text(helperManager.isHelperInstalled ? "표준시와 동기화" : "도우미 도구 설치")
                }
                .frame(minWidth: 180)
            }
            .disabled(helperManager.isWorking)
            
            if helperManager.isWorking {
                ProgressView()
            }
        }
        .padding(40)
        .frame(minWidth: 400, minHeight: 250)
        .onAppear {
            helperManager.checkHelperStatus()
        }
    }
}
