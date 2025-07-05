//
//  LoadEpisodePresenter.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 05/07/2025.
//

import Foundation

public protocol LoadResourceDelegate {
    associatedtype ResourcePresentationItem

    func didStartLoading()
    func didFinishLoading(with error: Error)
    func didFinishLoading(with item: ResourcePresentationItem)
}

public final class LoadResourcePresenter<Delegate: LoadResourceDelegate> {
    private let loader: () async throws -> Delegate.ResourcePresentationItem
    private let delegate: Delegate
    private var isLoading = false

    public init(loader: @escaping () async throws -> Delegate.ResourcePresentationItem, delegate: Delegate) {
        self.loader = loader
        self.delegate = delegate
    }

    public func loadEpisodes() {
        guard !isLoading else { return }

        delegate.didStartLoading()
        isLoading = true

        Task {
            defer { isLoading = false }

            do {
                let item = try await loader()
                delegate.didFinishLoading(with: item)
            } catch {
                delegate.didFinishLoading(with: error)
            }
        }
    }
}
