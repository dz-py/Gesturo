import Foundation
import Combine

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url = URL(string: "ws://169.254.206.14:5007")!
    private let encoder = JSONEncoder()
    
    enum GestureType: String, Codable {
        case move
        case leftClick
        case rightClick
        case scroll
        case doubleClick
    }
    
    struct MessageData: Codable {
        let type: GestureType
        let deltaX: Float
        let deltaY: Float
        let fingers: Int?
        let sendTime: Double
    }

    func connect() {
        let configuration = URLSessionConfiguration.default
        configuration.networkServiceType = .responsiveData // Prioritize websocket data
        let session = URLSession(configuration: configuration)
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        print("WebSocket connected!")
    }

    func sendBatch(messages: [MessageData]) {
        var timestampedMessages = messages.map { message in
            // Add current timestamp to each message
            MessageData(
                type: message.type,
                deltaX: message.deltaX,
                deltaY: message.deltaY,
                fingers: message.fingers,
                sendTime: Date().timeIntervalSince1970 * 1000 // Convert to milliseconds
            )
        }
        
        do {
            let jsonData = try encoder.encode(timestampedMessages)
            let message = URLSessionWebSocketTask.Message.data(jsonData)
            webSocketTask?.send(message) { error in
                if let error = error {
                    print("Error sending message: \(error)")
                }
            }
        } catch {
            print("JSON Encoding Error: \(error)")
        }
    }


    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}
