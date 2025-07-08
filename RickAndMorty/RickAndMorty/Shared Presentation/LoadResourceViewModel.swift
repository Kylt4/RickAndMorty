//
//  LoadResourceViewModel.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 07/07/2025.
//

import Foundation

@Observable
final public class LoadResourceViewModel<Resource, PresentationModel>: LoadResourceDelegate {
    public typealias Item = Resource

    public var isLoading = false
    public var errorMessage: String? = nil
    public var item: PresentationModel? = nil

    public let mapper: (Resource) throws -> PresentationModel

    public init(mapper: @escaping (Resource) throws -> PresentationModel) {
        self.mapper = mapper
    }

    public func didStartLoading() {
        isLoading = true
        errorMessage = nil
    }

    public func didFinishLoading(with resource: Resource) {
        do {
            item = try mapper(resource)
            isLoading = false
        } catch {
            didFinishLoading(with: error)
        }
    }

    public func didFinishLoading(with error: Error) {
        isLoading = false
        errorMessage = SharedStringsHelper.loadError
    }
}
