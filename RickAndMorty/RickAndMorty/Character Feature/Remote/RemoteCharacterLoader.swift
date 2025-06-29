//
//  RemoteCharacterLoader.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public final class RemoteCharacterLoader: CharacterLoader {
    private let url: URL
    private let client: HTTPClient

    public enum RemoteCharacterLoaderError: Error {
        case connectivity
        case invalidData
    }

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load() async throws -> CharacterItem {
        guard let result = try? await client.get(from: url) else {
            throw RemoteCharacterLoaderError.connectivity
        }

        guard result.response.statusCode == 200, let character = try? JSONDecoder().decode(RemoteCharacter.self, from: result.data) else {
            throw RemoteCharacterLoaderError.invalidData
        }
        return character.toApp
    }
}
