//
//  RemoteEpisodeLoader.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public final class RemoteEpisodeLoader: EpisodeLoader {
    private let url: URL
    private let client: HTTPClient

    public enum RemoteEpisodeLoaderError: Error {
        case connectivity
        case invalidData
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load() async throws -> PageEpisodeItems {
        guard let result = try? await client.get(from: url) else {
            throw RemoteEpisodeLoaderError.connectivity
        }

        guard result.response.statusCode == 200, let page = try? JSONDecoder().decode(RemotePageEpisodeItems.self, from: result.data) else {
            throw RemoteEpisodeLoaderError.invalidData
        }
        return page.toLocal
    }
}
