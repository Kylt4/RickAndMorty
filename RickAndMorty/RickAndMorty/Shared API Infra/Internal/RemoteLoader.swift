//
//  RemoteLoader.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public enum RemoteLoaderError: Error {
    case connectivity
    case invalidData
}

final class RemoteLoader<T: Equatable> {
    private let url: URL
    private let client: HTTPClient
    private let mapper: (Data) throws -> T

    init(url: URL, client: HTTPClient, mapper: @escaping (Data) throws -> T) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }

    func load() async throws -> T {
        guard let result = try? await client.get(from: url) else {
            throw RemoteLoaderError.connectivity
        }

        guard result.response.statusCode == 200, let item = try? mapper(result.data) else {
            throw RemoteLoaderError.invalidData
        }
        return item
    }
}
