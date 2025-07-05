//
//  Loader.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 05/07/2025.
//

import Foundation

public protocol Loader {
    associatedtype Item

    func load() async throws -> Item
}
