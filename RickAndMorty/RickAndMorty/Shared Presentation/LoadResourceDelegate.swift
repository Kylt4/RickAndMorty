//
//  LoadResourceDelegate.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 07/07/2025.
//

import Foundation

public protocol LoadResourceDelegate {
    associatedtype Item

    func didStartLoading()
    func didFinishLoading(with error: Error)
    func didFinishLoading(with item: Item)
}
