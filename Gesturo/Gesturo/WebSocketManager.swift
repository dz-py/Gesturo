import Foundation
import Combine

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url = URL(string: "ws://169.254.213.33:5007")!
    private let encoder = JSONEncoder()
    
    enum GestureType: String, Codable {
        case move
        case leftClick
        case rightClick
        case scroll
    }
    
    struct MessageData: Codable {
        let type: GestureType
        let deltaX: Float
        let deltaY: Float
        let fingers: Int?
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
        do {
            let jsonData = try encoder.encode(messages)
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
