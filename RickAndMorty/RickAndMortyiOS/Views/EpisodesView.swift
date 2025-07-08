//
//  EpisodesView.swift
//  RickAndMortyiOS
//
//  Created by Christophe Bugnon on 07/07/2025.
//

import SwiftUI
import RickAndMorty

public struct EpisodesView<Content: View>: View {
    var viewModel: EpisodesViewModel
    var characterView: (URL) -> Content

    var onLoad: () -> Void

    public init(viewModel: EpisodesViewModel, onLoad: @escaping () -> Void, characterView: @escaping (URL) -> Content) {
        self.viewModel = viewModel
        self.onLoad = onLoad
        self.characterView = characterView
    }

    public var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(errorMessage: errorMessage, onRetry: onLoad)
                } else if let item = viewModel.item {
                    VStack {
                        ScrollView(.vertical, content: {
                            VStack(spacing: 16) {
                                ForEach(item.episodes) { episode in
                                    EpisodeView(episode: episode, characterView: characterView)
                                }
                            }
                            .animation(.default, value: item.episodes)
                            if let loadMore = item.loadMore {
                                LazyVStack {
                                    ProgressView()
                                        .onAppear(perform: loadMore)
                                }
                            }
                        })
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .navigationTitle("Episodes")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear(perform: onLoad)
    }
}
