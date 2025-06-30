//
//  ImageDataLoader.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 30/06/2025.
//

import Foundation

protocol ImageDataLoader {
    func load() async throws -> Data
}
