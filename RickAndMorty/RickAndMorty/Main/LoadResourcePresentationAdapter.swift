//
//  LoadResourcePresentationAdapter.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 06/07/2025.
//

import Foundation

public final class LoadResourcePresentationAdapter<L: Loader, Delegate: LoadResourceDelegate> where L.Item == Delegate.Item {
    private let loader: L
    private let delegate: Delegate

    private var isLoading = false

    public init(loader: L, delegate: Delegate) {
        self.loader = loader
        self.delegate = delegate
    }

    public func load() {
        guard !isLoading else { return }

        delegate.didStartLoading()
        isLoading = true

        Task {
            defer { isLoading = false }

            do {
                let item = try await loader.load()
                delegate.didFinishLoading(with: item)
            } catch {
                delegate.didFinishLoading(with: error)
            }
        }
    }
}
