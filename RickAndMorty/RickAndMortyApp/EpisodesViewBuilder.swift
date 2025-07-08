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
            delegate: viewModel
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
                delegate: PaginatedEpisodeLoaderDelegate(viewModel: viewModel, oldItem: oldItem)
            )
            adapter.load()
        }
    }
}

fileprivate class PaginatedEpisodeLoaderDelegate: LoadResourceDelegate {
    typealias Item = PageEpisodeModels
    var viewModel: EpisodesViewModel
    var oldItem: PageEpisodeModels

    init(viewModel: EpisodesViewModel, oldItem: PageEpisodeModels) {
        self.viewModel = viewModel
        self.oldItem = oldItem
    }

    func didStartLoading() {}

    func didFinishLoading(with item: PageEpisodeModels) {
        viewModel.didFinishLoading(
            with: PageEpisodeModels(info: item.info,
                                    results: oldItem.results + item.results)
        )
    }

    func didFinishLoading(with error: any Error) {}
}

private class RemoteEpisodeLoaderWithShuffledCharacters: EpisodeLoader {
    public typealias Item = PageEpisodeModels

    private let decoratee: RemoteEpisodeLoader

    public init(decoratee: RemoteEpisodeLoader) {
        self.decoratee = decoratee
    }

    public func load() async throws -> PageEpisodeModels {
        let item = try await decoratee.load()
        return PageEpisodeModels(info: item.info,
                                 results: item.results.charactersShuffled)
    }
}

extension Array where Element == EpisodeModel {
    var charactersShuffled: [EpisodeModel] {
        return map {
            EpisodeModel(id: $0.id,
                         name: $0.name,
                         airDate: $0.airDate,
                         episode: $0.episode,
                         episodeURL: $0.episodeURL,
                         created: $0.created,
                         characters: $0.characters.shuffled())
        }
    }
}
