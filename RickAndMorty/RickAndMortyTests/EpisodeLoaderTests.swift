//
//  EpisodeLoaderTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 28/06/2025.
//

import XCTest

class HTTPClient {
    var urls = [URL]()

    var continuations: [CheckedContinuation<HTTPURLResponse, Error>?] = []

    func get(from url: URL) async throws -> HTTPURLResponse  {
        urls.append(url)
        return try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func completeWithStatusCode(code: Int, index: Int = 0) async {
        try? await Task.sleep(nanoseconds: 1_000_000)
        let response = HTTPURLResponse(
            url: urls[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil)!
        continuations[index]?.resume(with: .success(response))
        continuations[index] = nil
    }

    func completeWith(error: Error, index: Int = 0) async {
        try? await Task.sleep(nanoseconds: 1_000_000)
        continuations[index]?.resume(throwing: error)
        continuations[index] = nil
    }
}

class EpisodeLoader {
    private let url: URL
    private let client: HTTPClient

    enum EpisodeLoaderError: Error {
        case connectivity
        case invalidData
    }

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() async throws {
        guard let response = try? await client.get(from: url) else {
            throw EpisodeLoaderError.connectivity
        }

        if response.statusCode != 200 {
            throw EpisodeLoaderError.invalidData
        }
    }
}

class EpisodeLoaderTests: XCTestCase {

    func test_init_doesNotRequestGetFromURL() {
        let (_, spy) = makeSUT()

        XCTAssertTrue(spy.urls.isEmpty)
    }

    func test_load_requestGetFromURL() async {
        let anyURL = anyURL()
        let (sut, spy) = makeSUT(url: anyURL)

        performLoadTask(from: sut)
        await spy.completeWith(error: anyNSError())

        XCTAssertEqual(spy.urls, [anyURL])
    }

    func test_loadTwice_requestGetFromURLTwice() async {
        let anyURL = anyURL()
        let (sut, spy) = makeSUT(url: anyURL)

        performLoadTask(from: sut)
        await spy.completeWith(error: anyNSError())
        performLoadTask(from: sut)
        await spy.completeWith(error: anyNSError())


        XCTAssertEqual(spy.urls, [anyURL, anyURL])
    }


    func test_load_deliversConnectivityErrorOnClientError() async {
        let anyURL = anyURL()
        let (sut, spy) = makeSUT(url: anyURL)
        let clientError = NSError(domain: "client error", code: 0)

        let task = performLoadTask(from: sut)
        await spy.completeWith(error: clientError)

        do {
            try await task.value
            XCTFail("Expected \(clientError) error, got success instead")
        } catch {
            XCTAssertEqual(error as? EpisodeLoader.EpisodeLoaderError, .connectivity)
        }
    }

    func test_load_deliversInvalidDataErrorOnNon200HTTPResponseStatusCode() async {
        let anyURL = anyURL()
        let (sut, spy) = makeSUT(url: anyURL)
        let clientError = NSError(domain: "client error", code: 0)

        let task = performLoadTask(from: sut)
        await spy.completeWithStatusCode(code: 199)

        do {
            try await task.value
            XCTFail("Expected \(clientError) error, got success instead")
        } catch {
            print("[DEBUG] error", error)
            XCTAssertEqual(error as? EpisodeLoader.EpisodeLoaderError, .invalidData)
        }
    }

    // MARK: - helpers

    @discardableResult
    private func performLoadTask(from sut: EpisodeLoader) -> Task<Void, Error> {
        Task {
            try await sut.load()
        }
    }

    private func makeSUT(url: URL = URL(string: "http://any-url.com")!) -> (sut: EpisodeLoader, spy: HTTPClient) {
        let spy = HTTPClient()
        let sut = EpisodeLoader(url: url, client: spy)

        return (sut, spy)
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
