//
//  RemoteCharacterLoader.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public final class RemoteCharacterLoader: CharacterLoader {
    private let loader: RemoteLoader<CharacterModel>

    public init(url: URL, client: HTTPClient) {
        self.loader = RemoteLoader(url: url, client: client, mapper: RemoteCharacterItemMapper.map(_:))
    }

    public func load() async throws -> CharacterModel {
        try await loader.load()
    }
}
