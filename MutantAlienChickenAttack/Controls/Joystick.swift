import SwiftUI

struct Joystick: View {
    static let radius: CGFloat = 75
    static let opacity: CGFloat = 0.75
    static let color: Color = .gray.opacity(0.75)
    
    @State var offset = CGSize.zero
    
    let direction: Binding<CGSize>
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 3))
                .frame(width: 2 * Self.radius, height: 2 * Self.radius)
                .foregroundStyle(Self.color)
            Circle()
                .foregroundStyle(Self.color)
                .frame(width: Self.radius, height: Self.radius)
                .offset(offset)
                .gesture(DragGesture().onChanged { g in
                    offset = clipped(toRadius: Self.radius, g.translation)
                    direction.wrappedValue = normalized(translation: offset)
                }.onEnded { _ in
                    offset = .zero
                    direction.wrappedValue = .zero
                })
        }
        .padding(20)
    }
    
    private func clipped(toRadius radius: CGFloat, _ translation: CGSize) -> CGSize {
        let distance = sqrt((translation.width * translation.width) + (translation.height * translation.height))
        if distance > radius {
            let multiplier = radius / distance
            return CGSize(width: translation.width * multiplier, height: translation.height * multiplier)
        } else {
            return translation
        }
    }
    
    private func normalized(translation: CGSize) -> CGSize {
        let distance = sqrt((translation.width * translation.width) + (translation.height * translation.height))
        let multiplier = 1 / distance
        return CGSize(width: translation.width * multiplier, height: translation.height * -multiplier)
    }
}
