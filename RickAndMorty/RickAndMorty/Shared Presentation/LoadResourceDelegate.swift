//
//  LoadResourceDelegate.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 06/07/2025.
//

import Foundation

public protocol LoadResourceDelegate {
    associatedtype PresentationModel

    func didStartLoading()
    func didFinishLoading(with error: Error)
    func didFinishLoading(with item: PresentationModel)
}
