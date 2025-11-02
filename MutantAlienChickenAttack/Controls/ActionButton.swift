import SwiftUI


struct ActionButton: View {
    static let radius: CGFloat = 75
    static let opacity: CGFloat = 0.75
    static let color: Color = .gray.opacity(0.75)
    static let pressedColor: Color = .gray.opacity(0.25)
    
    var isPressed: Binding<Bool>
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 3))
                .frame(width: 2 * Self.radius, height: 2 * Self.radius)
                .foregroundStyle(Self.color)
            Circle()
                .foregroundStyle(isPressed.wrappedValue ? Self.pressedColor : Self.color)
                .frame(width: 1.9 * Self.radius, height: 1.9 * Self.radius)
                .gesture(DragGesture(minimumDistance: 0).onChanged { _ in
                    isPressed.wrappedValue = true
                }.onEnded { _ in
                    isPressed.wrappedValue = false
                })
        }
        .padding(20)
    }
}
