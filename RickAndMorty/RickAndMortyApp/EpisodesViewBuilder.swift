//
//  EpisodesViewBuilder.swift
//  RickAndMortyApp
//
//  Created by Christophe Bugnon on 08/07/2025.
//

import RickAndMorty
import RickAndMortyiOS
import SwiftUI

class EpisodesViewBuilder {
    static func build(client: HTTPClient, characterView: @escaping (URL) -> CharacterView) -> EpisodesView<CharacterView> {
        var viewModel: EpisodesViewModel!
        viewModel = EpisodesViewModel { pageEpisode in
            let episodes = pageEpisode.results.map {
                EpisodePresentationModel(
                    name: $0.name,
                    characters: $0.characters
                )
            }

            return EpisodesPresentationModel(
                episodes: episodes,
                loadMore: Self.load(url: pageEpisode.info.next, in: viewModel, oldItem: pageEpisode, client: client)
            )
        }

        let loader = RemoteEpisodeLoaderWithShuffledCharacters(decoratee: RemoteEpisodeLoader(
            url: URL(string: "https://rickandmortyapi.com/api/episode")!,
            client: client
        ))

        let adapter = LoadResourcePresentationAdapter(
            loader: loader,
            delegate: makeComposer(viewModel: viewModel)
        )

        return EpisodesView(
            viewModel: viewModel,
            onLoad: adapter.load,
            characterView: characterView)
    }

    private static func load(url: URL?, in viewModel: EpisodesViewModel, oldItem: PageEpisodeModels, client: HTTPClient) -> (() -> Void)? {
        guard let url else { return nil }
        return { [weak viewModel] in
            guard let viewModel else { return }

            let loader = RemoteEpisodeLoaderWithShuffledCharacters(decoratee: RemoteEpisodeLoader(
                url: url,
                client: client
            ))
            let adapter = LoadResourcePresentationAdapter(
                loader: loader,
                delegate: makeComposer(viewModel: PaginatedEpisodeLoaderDelegate(viewModel: viewModel, oldItem: oldItem))
            )
            adapter.load()
        }
    }

    private static func makeComposer(viewModel: any LoadEpisodeDelegate) -> EpisodeResourceDelegateComposer {
        return EpisodeResourceDelegateComposer(delegates: [AnalyticsTracker(), FirebaseTracker(), viewModel])
    }
}
