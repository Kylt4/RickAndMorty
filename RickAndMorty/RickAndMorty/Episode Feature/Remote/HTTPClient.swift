//
//  HTTPClient.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL) async throws -> (response: HTTPURLResponse, data: Data)
}
