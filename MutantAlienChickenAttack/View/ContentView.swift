//
//  ContentView.swift
//  MutantAlienChickenAttack
//
//  Created by tony on 02/11/2025.
//

import SwiftUI
import SpriteKit
import Combine

class ViewModel: ObservableObject {
    @Published var direction: CGSize = .zero
    @Published var actionPressed: Bool = false
    @Published var tapLocation: CGPoint?
    @Published var keyDown: KeyPress?
    @Published var keyUp: KeyPress?
}

struct ContentView: View {
    @State var direction: CGSize = .zero
    @State var actionPressed: Bool = false
    
    @ObservedObject var viewModel = ViewModel()
        
    var body: some View {
        ZStack {
            SpriteView(scene: IntroScene1.newGameScene(viewModel))
                .frame(width: Dimension.tileSize.width * 15, height: 10 * Dimension.tileSize.height)
#if os(iOS)
            VStack {
                Spacer()
                HStack {
                    Joystick(direction: $direction)
                    Spacer()
                    ActionButton(isPressed: $actionPressed)
                }
            }
#endif
        }
        .onChange(of: direction) {
            Task {
                viewModel.direction = direction
            }
        }
        .onChange(of: actionPressed) {
            Task {
                viewModel.actionPressed = actionPressed
            }
        }
        .onTapGesture { location in
            Task {
                viewModel.tapLocation = location
            }
        }
        .onKeyPress(phases: .down) { key in
            Task {
                viewModel.keyDown = key
            }
            return .handled
        }
        .onKeyPress(phases: .up) { key in
            Task {
                viewModel.keyUp = key
            }
            return .handled
        }
    }
}

#Preview {
    ContentView()
}
