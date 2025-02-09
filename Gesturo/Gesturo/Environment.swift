import Foundation

enum Config {
    static var wsURL: String {
        guard let path = Bundle.main.path(forResource: "config", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: String]
        else {
            return "ws://localhost:5007"
        }
        return json["WS_URL"] ?? "ws://localhost:5007"
    }
}
