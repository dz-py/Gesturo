import SwiftUI

class GestureHandler: ObservableObject {
    private var webSocketManager = WebSocketManager()
    private var messageQueue: [WebSocketManager.MessageData] = []
    private var timer: Timer?
    private var lastSwipeTime: TimeInterval = 0

    init() {
        webSocketManager.connect()
        startBatching()
    }

    func handleSwipe(deltaX: CGFloat, deltaY: CGFloat) {
        let deadZone: CGFloat = 0.5  // Ignore tiny unintended movements
        let smallMoveThreshold: CGFloat = 1500  // Threshold for scaling small moves

        var adjustedDeltaX = abs(deltaX) > deadZone ? deltaX : 0
        var adjustedDeltaY = abs(deltaY) > deadZone ? deltaY : 0

        // Reduce sensitivity for small movements
        if abs(adjustedDeltaX) < smallMoveThreshold {
            adjustedDeltaX *= 0.2
        }
        if abs(adjustedDeltaY) < smallMoveThreshold {
            adjustedDeltaY *= 0.2
        }

        let messageData = WebSocketManager.MessageData(
            deltaX: Float(adjustedDeltaX),
            deltaY: Float(adjustedDeltaY)
        )

        messageQueue.append(messageData)
    }

    private func startBatching() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if !self.messageQueue.isEmpty {
                self.webSocketManager.sendBatch(messages: self.messageQueue)
                self.messageQueue.removeAll()
            }
        }
    }

    func stopSending() {
        webSocketManager.sendBatch(messages: [WebSocketManager.MessageData(deltaX: 0, deltaY: 0)])
    }

    deinit {
        timer?.invalidate()
    }
}
