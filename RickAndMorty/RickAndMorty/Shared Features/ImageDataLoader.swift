//
//  ImageDataLoader.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 30/06/2025.
//

import Foundation

public protocol ImageDataLoader: Loader {
    func load() async throws -> Data
}
