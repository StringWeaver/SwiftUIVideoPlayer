//
//  DocumentView.swift
//  SwiftVideoPlayer
//
//  Created by StringWeaver on 2025-11-26.
//

import SwiftUI
import UniformTypeIdentifiers
struct DocumentView: View {
    @State private var showPicker = true
    @State private var selectedURL: URL?
    
    var body: some View {
         Group {
            if selectedURL != nil {
                PlayerView(url: $selectedURL)
                    .ignoresSafeArea(.all)
                    .onDisappear{ showPicker = true }
            } else {
                Button("Select File") {
                    showPicker = true
                }
                .buttonStyle(.borderedProminent)
                .fileImporter(
                    isPresented: $showPicker,
                    allowedContentTypes: [.movie, .video, .audio],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        selectedURL = urls.first
                    case .failure:
                        break
                    }
                }
            }
        }
    }
    
}
#Preview {
    DocumentView()
}
