//
//  RemoteImageDataLoader.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 30/06/2025.
//

import Foundation

public final class RemoteImageDataLoader: ImageDataLoader {
    private let loader: RemoteLoader<Data>

    public init(url: URL, client: HTTPClient) {
        self.loader = RemoteLoader(url: url, client: client, mapper: { $0 })
    }

    public func load() async throws -> Data {
        try await loader.load()
    }
}
