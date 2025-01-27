import SwiftUI

struct ContentView: View {
    @StateObject private var gestureHandler = GestureHandler()

    var body: some View {
        VStack {
            Text("Swipe to move the cursor!")
                .padding()
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let deltaX = value.translation.width
                    let deltaY = value.translation.height
                    gestureHandler.handleSwipe(deltaX: deltaX, deltaY: deltaY)
                }
        )
    }
}
