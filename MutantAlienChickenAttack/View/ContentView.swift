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
}

struct ContentView: View {
    @State var direction: CGSize = .zero
    @State var actionPressed: Bool = false
    
    @ObservedObject var viewModel = ViewModel()
        
    var body: some View {
        ZStack {
            SpriteView(scene: IntroScene2.newGameScene(viewModel))
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
            viewModel.direction = direction
        }
        .onChange(of: actionPressed) {
            viewModel.actionPressed = actionPressed
        }
    }
}

#Preview {
    ContentView()
}
