//
//  LoadResourceViewModel.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 05/07/2025.
//

import Foundation

@Observable
public final class LoadResourceViewModel<L: Loader, Delegate: LoadResourceDelegate> where L.Item == Delegate.Item {
    private let loader: L
    private let delegate: Delegate

    public var isLoading = false
    public var item: L.Item?
    public var error: Error?

    public init(loader: L, delegate: Delegate) {
        self.loader = loader
        self.delegate = delegate
    }

    @MainActor
    public func load() async {
        guard !isLoading else { return }
        let delegate = delegate
        Task.detached {
            delegate.didStartLoading()
        }

        defer { isLoading = false }
        isLoading = true
        error = nil

        do {
            let item = try await loader.load()
            self.item = item
            Task.detached {
                delegate.didFinishLoading(with: item)
            }
        } catch let receivedError {
            error = receivedError
            Task.detached {
                delegate.didFinishLoading(with: receivedError)
            }
        }
    }
}
