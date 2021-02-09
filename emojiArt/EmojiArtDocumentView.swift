//
//  EmojiArtContentView.swift
//  emojiArt
//
//  Created by Jean Claude Ndayisenga on 01/02/2021.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    var body: some View {
        
        VStack {
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) {
                        emoji in Text(emoji).font(Font.system(size: self.defaultEmojiSize))
                            .onDrag {
                                NSItemProvider(object: emoji as  NSString)
                                
                            }
                    }
                }
            }
            .padding(.horizontal)
            
            GeometryReader {
                geometry in
                
                ZStack {
                    Color.white.overlay(OptionalImage(uiImage: self.document.backgroundImage)
                                            .scaleEffect(self.zoomScale)
                    )
                    .gesture(self.doubleTapZoom(in: geometry.size))
                    
                    ForEach(self.document.emojis) { emoji in
                        Text(emoji.text)
                            .font(self.font(for: emoji))
                            .position(self.position(for:emoji, in: geometry.size))
                    }
                }
                
                .clipped()
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    
                    var location = geometry.convert(location, from: .global)
                    
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    
                    return self.drop(providers: providers, at: location )
                    
                }
            }
        }
    }
    
    
    @State private var zoomScale: CGFloat = 1.0
    
    private func doubleTapZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.linear(duration: 4)) {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }
    
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.zoomScale = min(hZoom, vZoom)
        }
    }
    
    private func font(for emoji: EmojiArt.Emoji) -> Font {
        Font.system(size: emoji.fontSize)
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y + size.height/2)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        return location
        
    }
    
    private func drop(providers: [NSItemProvider], at location:CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) {
            url in
            
            print("dropped \(url)")
            self.document.setBackgroundURL(url)
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) {
                String in
                self.document.addEmoji(String, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}



