//
//  URLSessionHTTPClient.swift
//  RickAndMorty
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}

    public func get(from url: URL) async throws -> (response: HTTPURLResponse, data: Data) {
        let (data, response) = try await session.data(from: url)
        if let httpURLResponse = response as? HTTPURLResponse {
            return ((httpURLResponse, data))
        }
        throw UnexpectedValuesRepresentation()
    }
}
