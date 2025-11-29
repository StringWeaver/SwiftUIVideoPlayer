//
//  PlayerView..swift
//  SwiftVideoPlayer
//
//  Created by StringWeaver on 2025-11-26.
//
import AVKit
import SwiftUI


struct PlayerView: View {
    @Binding var url: URL?
    @State private var showCloseButton = false
    @State private var filename : String = ""
    @StateObject  private var model = PlayerModel()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if(model.ready){
                VideoPlayer(player: model.player)
            }else {
                ProgressView("Loading…")
            }
            if (showCloseButton){
                HStack(spacing: 8) {
                    Button(action: {
                        url = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .opacity(0.5)
                    }
                    .buttonStyle(PlainButtonStyle()) // remove background and animation
                    .padding(.top, 40)
                    .padding(.leading, 20)
                    .task(id: showCloseButton) {
                        guard showCloseButton else { return }
                        try? await Task.sleep(nanoseconds: 2_750_000_000)
                        withAnimation(.easeOut(duration: 0.25)) {
                            showCloseButton = false
                        }
                    }
                    Text(filename)
                }
            }
                
            Button(action: {
                url = nil
            }){}.hidden()
            .allowsHitTesting(false)
            .keyboardShortcut(.escape, modifiers: [])
        }
        .task {
            model.load(url: url!)
        }
        .simultaneousGesture(
            TapGesture()
            .onEnded {
                withAnimation {
                    showCloseButton.toggle()
                }
            }
        )
        .onDisappear { model.cleanup() }
        .onAppear(){
            filename = trimLeadingNonDigits(url!.lastPathComponent)
            #if os(macOS)
            if let window = NSApp.keyWindow {
                window.title = filename
            }
            #endif
        }
    }
    private func trimLeadingNonDigits(_ input: String) -> String {
        let digits = CharacterSet.decimalDigits
        if let range = input.rangeOfCharacter(from: digits) {
            return String(input[range.lowerBound...])
        }
        return input
    }
}
