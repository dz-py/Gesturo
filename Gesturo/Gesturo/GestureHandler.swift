import SwiftUI

class GestureHandler: ObservableObject {
    private var webSocketManager = WebSocketManager()
    private var messageQueue: [WebSocketManager.MessageData] = []
    private var timer: Timer?

    init() {
        webSocketManager.connect()
        startBatching()
    }

    func handleSwipe(deltaX: CGFloat, deltaY: CGFloat) {
        print("Swipe detected: deltaX=\(deltaX), deltaY=\(deltaY)")
        
        let messageData = WebSocketManager.MessageData(
            deltaX: Float(deltaX),
            deltaY: Float(deltaY),
            //timesend: Int64(Date().timeIntervalSince1970 * 1000)
        )
        
        messageQueue.append(messageData) // Add to batch queue
    }

    private func startBatching() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if !self.messageQueue.isEmpty {
                self.webSocketManager.sendBatch(messages: self.messageQueue)
                self.messageQueue.removeAll()
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
