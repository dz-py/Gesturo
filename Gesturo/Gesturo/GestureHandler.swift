import SwiftUI

class GestureHandler: ObservableObject {
    private var webSocketManager = WebSocketManager()

    init() {
        webSocketManager.connect()
    }

    func handleSwipe(deltaX: CGFloat, deltaY: CGFloat) {
        print("Swipe detected: deltaX=\(deltaX), deltaY=\(deltaY)")
        let message = """
        { "deltaX": \(deltaX), "deltaY": \(deltaY) }
        """
        webSocketManager.send(message: message)
    }
}
