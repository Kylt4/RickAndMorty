//
//  HTTPClientSpy.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation
import RickAndMorty

class HTTPClientSpy: HTTPClient {
    var urls = [URL]()

    var continuations: [CheckedContinuation<(response: HTTPURLResponse, data: Data), Error>?] = []

    func get(from url: URL) async throws -> (response: HTTPURLResponse, data: Data)  {
        urls.append(url)
        return try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func completeWithStatusCode(code: Int, data: Data = Data(), index: Int = 0) async {
        try? await Task.sleep(nanoseconds: 1_000_000)
        let response = HTTPURLResponse(
            url: urls[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil)!
        continuations[index]?.resume(with: .success((response, data)))
        continuations[index] = nil
    }

    func completeWith(error: Error, index: Int = 0) async {
        try? await Task.sleep(nanoseconds: 1_000_000)
        continuations[index]?.resume(throwing: error)
        continuations[index] = nil
    }
}
