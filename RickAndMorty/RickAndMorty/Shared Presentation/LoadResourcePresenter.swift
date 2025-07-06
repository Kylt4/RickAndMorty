//
//  LoadEpisodePresenter.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 05/07/2025.
//

import Foundation

public final class LoadResourcePresenter<L: Loader, View: LoadResourceDelegate> {
    private let loader: L
    private let view: View
    private let mapper: (L.Item) throws -> View.PresentationModel

    private var isLoading = false

    public init(loader: L, view: View, mapper: @escaping (L.Item) throws -> View.PresentationModel) {
        self.loader = loader
        self.view = view
        self.mapper = mapper
    }

    public init(loader: L, view: View) where L.Item == View.PresentationModel {
        self.loader = loader
        self.view = view
        self.mapper = { $0 }
    }

    public func load() {
        guard !isLoading else { return }

        view.didStartLoading()
        isLoading = true

        Task {
            defer { isLoading = false }

            do {
                let item = try await loader.load()
                view.didFinishLoading(with: try mapper(item))
            } catch {
                view.didFinishLoading(with: error)
            }
        }
    }
}
