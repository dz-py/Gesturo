import SwiftUI
import UIKit

struct TouchpadView: UIViewRepresentable {
    let gestureHandler: GestureHandler
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        // Pan gesture for movement and scrolling
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        view.addGestureRecognizer(panGesture)
        
        // Tap gesture for left click
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Two-finger tap for right click
        let twoFingerTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        twoFingerTapGesture.numberOfTouchesRequired = 2
        twoFingerTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(twoFingerTapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(gestureHandler: gestureHandler)
    }
    
    class Coordinator: NSObject {
        let gestureHandler: GestureHandler
        private var lastTranslation: CGPoint = .zero
        
        init(gestureHandler: GestureHandler) {
            self.gestureHandler = gestureHandler
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: gesture.view)
            let fingerCount = gesture.numberOfTouches
            
            // Calculate delta from last position
            let deltaX = translation.x - lastTranslation.x
            let deltaY = translation.y - lastTranslation.y
            
            // Update last translation
            lastTranslation = translation
            
            // Reset last translation when gesture ends
            if gesture.state == .ended || gesture.state == .cancelled {
                lastTranslation = .zero
                gestureHandler.stopSending()
                return
            }
            
            gestureHandler.handleSwipe(
                deltaX: deltaX,
                deltaY: deltaY,
                fingers: fingerCount
            )
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            gestureHandler.handleTap(fingers: gesture.numberOfTouchesRequired)
        }
    }
}
