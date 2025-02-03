import SwiftUI

struct ContentView: View {
    @StateObject private var gestureHandler = GestureHandler()
    
    var body: some View {
        VStack {
            Spacer()
            
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .overlay(
                    TouchpadView(gestureHandler: gestureHandler)
                )
                .frame(width: 300, height: 300)
            
            Spacer()
            
            Text("Tap = Left Click | Two-Finger Tap = Right Click\nTwo-Finger Swipe = Scroll")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
