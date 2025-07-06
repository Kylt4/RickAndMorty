//
//  LoadResourceViewModel.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 05/07/2025.
//

import Foundation

@Observable
public final class LoadResourceViewModel<L: Loader, Delegate: LoadResourceDelegate> {
    private let loader: L
    private let delegate: Delegate
    private let mapper: (L.Item) throws -> Delegate.PresentationModel

    public var isLoading = false
    public var item: Delegate.PresentationModel?
    public var error: Error?

    public init(loader: L, delegate: Delegate, mapper: @escaping (L.Item) throws -> Delegate.PresentationModel) {
        self.loader = loader
        self.delegate = delegate
        self.mapper = mapper
    }

    public init(loader: L, delegate: Delegate) where L.Item == Delegate.PresentationModel {
        self.loader = loader
        self.delegate = delegate
        self.mapper = { $0 }
    }

    @MainActor
    public func load() async {
        guard !isLoading else { return }
        defer { isLoading = false }

        let delegate = delegate
        let mapper = mapper
        
        Task.detached { delegate.didStartLoading() }
        isLoading = true
        error = nil

        do {
            let item = try mapper(await loader.load())
            self.item = item
            Task.detached { delegate.didFinishLoading(with: item) }
        } catch let receivedError {
            error = receivedError
            Task.detached { delegate.didFinishLoading(with: receivedError) }
        }
    }
}
