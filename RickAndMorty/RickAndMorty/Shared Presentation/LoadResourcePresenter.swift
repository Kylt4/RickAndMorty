//
//  LoadResourcePresenter.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 06/07/2025.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourcePresentationModel

    func display(errorMessage: String?)
    func display(isLoading: Bool)
    func display(presentationModel: ResourcePresentationModel)
}

final class LoadResourcePresenter<Resource, View: ResourceView> {
    private let view: View
    private let mapper: (Resource) throws -> View.ResourcePresentationModel

    private var loadError: String {
        String(localized: "GENERIC_CONNECTION_ERROR",
               table: "Shared",
               bundle: Bundle(for: LoadResourcePresenter.self))
    }

    init(view: View, mapper: @escaping (Resource) throws -> View.ResourcePresentationModel) {
        self.view = view
        self.mapper = mapper
    }

    func didStartLoading() {
        view.display(errorMessage: nil)
        view.display(isLoading: true)
    }

    func didFinishLoading(with resource: Resource) {
        do {
            view.display(presentationModel: try mapper(resource))
            view.display(isLoading: false)
        } catch {
            didFinishLoading(with: error)
        }
    }

    func didFinishLoading(with error: Error) {
        view.display(errorMessage: loadError)
        view.display(isLoading: false)
    }
}
