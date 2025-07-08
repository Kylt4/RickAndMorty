//
//  PreviewView.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 12/07/2025.
//

import SwiftUI

struct PreviewView<Content: View>: View {
    let displayName: String
    let content: Content

    var body: some View {
        VStack(spacing: 4) {
            content
            Text(displayName)
        }
    }
}
