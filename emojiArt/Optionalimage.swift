//
//  Optionalimage.swift
//  emojiArt
//
//  Created by Jean Claude Ndayisenga on 09/02/2021.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
           
            }
        }
    }
}
