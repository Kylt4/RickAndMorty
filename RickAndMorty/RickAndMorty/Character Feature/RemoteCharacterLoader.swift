//
//  RemoteCharacterLoader.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public final class RemoteCharacterLoader: CharacterLoader {
    private let loader: RemoteLoader<CharacterItem>

    public init(url: URL, client: HTTPClient) {
        self.loader = RemoteLoader(url: url, client: client, mapper: RemoteCharacterItemMapper.map(_:))
    }

    public func load() async throws -> CharacterItem {
        try await loader.load()
    }
}
