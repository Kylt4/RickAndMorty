//
//  RemoteImageDataLoaderWithSomeFailure.swift
//  RickAndMortyApp
//
//  Created by Christophe Bugnon on 13/07/2025.
//

import Foundation
import RickAndMorty

final class RemoteImageDataLoaderWithSomeFailure: ImageDataLoader {
    private let decoratee: RemoteImageDataLoader

    init(decoratee: RemoteImageDataLoader) {
        self.decoratee = decoratee
    }

    public func load() async throws -> Data {
        if Int.random(in: 1...10) == 1 {
            throw NSError(domain: "any error", code: 0)
        } else {
            let random = TimeInterval.random(in: 0...1)
            try? await Task.sleep(for: .seconds(random))
            return try await decoratee.load()
        }
    }
}
