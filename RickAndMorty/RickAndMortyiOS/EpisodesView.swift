//
//  EpisodesView.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 07/07/2025.
//

import SwiftUI
import UIKit
import RickAndMorty

public typealias EpisodesViewModel = LoadResourceViewModel<PageEpisodeModels, [EpisodePresentationModel]>

struct EpisodesView: View {
    var viewModel: EpisodesViewModel
    var characterViewModel: (URL) -> CharacterViewModel

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                } else if let episodes = viewModel.item {
                    ScrollView(.vertical, content: {
                        VStack(spacing: 16) {
                            ForEach(episodes, id: \.id) { episode in
                                EpisodeView(episode: episode, characterViewModel: characterViewModel)
                            }
                        }
                    })
                }
            }
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Episodes")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct EpisodeView: View {
    @Environment(\.colorScheme) var colorScheme

    let episode: EpisodePresentationModel
    var characterViewModel: (URL) -> CharacterViewModel

    private var colorShadow: Color {
        Color(colorScheme == .dark ? .white : .black)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(episode.name)
                    .font(.title).bold()
                Spacer()
            }
            .padding(.horizontal)
            charactersScrollView
        }
    }

    private var charactersScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(episode.characters, id: \.self) { url in
                    CharacterView(viewModel: characterViewModel(url))
                        .padding()
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(16)
                        .shadow(color: colorShadow.opacity(0.3), radius: 5, y: 2)
                }
            }
            .padding()
        }
    }
}
