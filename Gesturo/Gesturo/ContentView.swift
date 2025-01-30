import SwiftUI

struct ContentView: View {
    @StateObject private var gestureHandler = GestureHandler()
    @State private var touchLocation = CGPoint.zero
    
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
                .frame(width: 300, height: 300)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let deltaX = value.translation.width
                            let deltaY = value.translation.height
                            gestureHandler.handleSwipe(deltaX: deltaX, deltaY: deltaY)
                        }
                )
            
            Spacer()
            
            Text("Swipe within the touchpad to move cursor")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
