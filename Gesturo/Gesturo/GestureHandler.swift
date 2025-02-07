import SwiftUI

class GestureHandler: ObservableObject {
    private var webSocketManager = WebSocketManager()
    private var messageQueue: [WebSocketManager.MessageData] = []
    private var timer: Timer?
    private var lastTapTime: TimeInterval = 0
    private var tapCount = 0
    private let doubleTapTimeThreshold = 0.3
    
    init() {
        webSocketManager.connect()
        startBatching()
    }
    
    func handleTap(fingers: Int, tapCount: Int = 1) {
        let messageData: WebSocketManager.MessageData
        let currentTime = Date().timeIntervalSince1970 * 1000 // Current time in milliseconds
            
        switch (fingers, tapCount) {
        case (1, 1):  // Single tap
            messageData = WebSocketManager.MessageData(
                type: .leftClick,
                deltaX: 0,
                deltaY: 0,
                fingers: 1,
                sendTime: currentTime
            )
        case (1, 2):  // Double tap
            messageData = WebSocketManager.MessageData(
                type: .doubleClick,
                deltaX: 0,
                deltaY: 0,
                fingers: 1,
                sendTime: currentTime
            )
        case (2, 1):  // Two-finger tap
            messageData = WebSocketManager.MessageData(
                type: .rightClick,
                deltaX: 0,
                deltaY: 0,
                fingers: 2,
                sendTime: currentTime
            )
        default:
            return
        }
            
        messageQueue.append(messageData)
    }
    
    func handleSwipe(deltaX: CGFloat, deltaY: CGFloat, fingers: Int) {
        let deadZone: CGFloat = 0.5
        let smallMoveThreshold: CGFloat = 7
        let currentTime = Date().timeIntervalSince1970 * 1000 // Current time in milliseconds
        
        var adjustedDeltaX = abs(deltaX) > deadZone ? deltaX : 0
        var adjustedDeltaY = abs(deltaY) > deadZone ? deltaY : 0
        
        if abs(adjustedDeltaX) < smallMoveThreshold {
            adjustedDeltaX *= 0.5
        }
        if abs(adjustedDeltaY) < smallMoveThreshold {
            adjustedDeltaY *= 0.5
        }
        
        let messageData: WebSocketManager.MessageData
        if fingers == 1 {
            messageData = WebSocketManager.MessageData(
                type: .move,
                deltaX: Float(adjustedDeltaX),
                deltaY: Float(adjustedDeltaY),
                fingers: 1,
                sendTime: currentTime
            )
        } else if fingers == 2 {
            // Two-finger scroll - Adjust sensitivity for scrolling
            messageData = WebSocketManager.MessageData(
                type: .scroll,
                deltaX: Float(adjustedDeltaX),
                deltaY: Float(adjustedDeltaY),
                fingers: 2,
                sendTime: currentTime
            )
        } else {
            return
        }
        
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
        // Send a final message to stop movement
        let messageData = WebSocketManager.MessageData(
            type: .move,
            deltaX: 0,
            deltaY: 0,
            fingers: 1,
            sendTime: Date().timeIntervalSince1970 * 1000
        )
        webSocketManager.sendBatch(messages: [messageData])
    }

    deinit {
        timer?.invalidate()
    }
}
