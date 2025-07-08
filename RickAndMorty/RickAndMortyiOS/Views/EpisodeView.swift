//
//  EpisodeView.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 07/07/2025.
//

import SwiftUI

struct EpisodeView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme

    let episode: EpisodePresentationModel
    var characterView: (URL) -> Content

    private var colorShadow: Color {
        Color(colorScheme == .dark ? .white : .black)
    }

    var body: some View {
        LazyVStack(spacing: 0) {
            HStack {
                Text(episode.name)
                    .font(.title).bold()
                Spacer()
            }
            .padding(.horizontal)
            charactersScrollView
        }
        .dynamicTypeSize(.xSmall ... .xxxLarge)
    }

    private var charactersScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                ForEach(episode.characters, id: \.absoluteString) { url in
                    characterView(url)
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(16)
                        .shadow(color: colorShadow.opacity(0.1), radius: 3, y: 2)
                }
            }
            .padding()
        }
    }
}
