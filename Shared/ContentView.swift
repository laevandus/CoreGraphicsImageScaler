//
//  ContentView.swift
//  Shared
//
//  Created by Toomas Vahter on 28.11.2020.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.displayScale) var displayScale: CGFloat
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            if viewModel.cgImage != nil {
                Image(viewModel.cgImage!,
                      scale: displayScale,
                      orientation: .up,
                      label: Text("photo")
                )
            }
        }
        .padding()
        .onAppear(perform: { viewModel.prepareImage(withScale: displayScale) })
    }
}

extension ContentView {
    final class ViewModel: ObservableObject {
        static let queue = DispatchQueue(label: "com.augmentedcode.imageloader")

        @Published var cgImage: CGImage?
        
        func prepareImage(withScale displayScale: CGFloat) {
            Self.queue.async {
                guard let url = Bundle.main.url(forResource: "ExamplePhoto", withExtension: "jpeg") else { return }
                guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return }
                guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return }
                let targetSize = CGSize(width: CGFloat(200.0) * displayScale, height: CGFloat(200.0) * displayScale)
                let scaledImage = ImageScaler.scaleToFill(image, in: targetSize)
                DispatchQueue.main.async {                
                    self.cgImage = scaledImage
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
