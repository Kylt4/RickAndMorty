//
//  RemoteEpisodeLoader.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public final class RemoteEpisodeLoader: EpisodeLoader {
    private let loader: RemoteLoader<PageEpisodeItems>

    public init(url: URL, client: HTTPClient) {
        self.loader = RemoteLoader(url: url, client: client, mapper: RemotePageEpisodeItemsMapper.map(_:))
    }

    public func load() async throws -> PageEpisodeItems {
        try await loader.load()
    }
}
