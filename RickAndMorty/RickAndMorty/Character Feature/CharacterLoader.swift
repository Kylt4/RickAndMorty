//
//  CharacterLoader.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public protocol CharacterLoader: Loader {
    func load() async throws -> CharacterItem
}
