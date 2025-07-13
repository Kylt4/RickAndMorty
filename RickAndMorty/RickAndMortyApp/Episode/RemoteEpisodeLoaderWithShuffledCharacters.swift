//
//  RemoteEpisodeLoaderWithShuffledCharacters.swift
//  RickAndMortyApp
//
//  Created by Christophe Bugnon on 13/07/2025.
//

import Foundation
import RickAndMorty

final class RemoteEpisodeLoaderWithShuffledCharacters: EpisodeLoader {
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
