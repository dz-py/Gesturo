import SwiftUI

struct ContentView: View {
    @StateObject private var gestureHandler = GestureHandler()
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let frameWidth = isLandscape ? 600 : 350
            
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
                    .frame(width: CGFloat(frameWidth), height: 325)
                
                Spacer()
                
                Text("Tap = Left Click | Two-Finger Tap = Right Click\nTwo-Finger Swipe = Scroll | Double Tap = Double Click")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(width: geometry.size.width * 0.9, alignment: .center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
    }
}
