//
//  EpisodeLoaderTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 28/06/2025.
//

import XCTest

class HTTPClient {
    var urls = [URL]()

    var getContinuation: CheckedContinuation<Void, Error>?

    func get(from url: URL) async throws  {
        urls.append(url)
        return try await withCheckedThrowingContinuation { continuation in
            getContinuation = continuation
        }
    }

    func completeSuccessfully() async {
        try? await Task.sleep(nanoseconds: 1_000_000)
        getContinuation?.resume(with: .success(()))
        getContinuation = nil
    }

    func completeWith(error: Error) async {
        try? await Task.sleep(nanoseconds: 1_000_000)
        getContinuation?.resume(throwing: error)
        getContinuation = nil
    }
}

class EpisodeLoader {
    private let url: URL
    private let client: HTTPClient

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() async throws {
        try await client.get(from: url)
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
        await spy.completeSuccessfully()

        XCTAssertEqual(spy.urls, [anyURL])
    }

    func test_loadTwice_requestGetFromURLTwice() async {
        let anyURL = anyURL()
        let (sut, spy) = makeSUT(url: anyURL)

        performLoadTask(from: sut)
        await spy.completeSuccessfully()
        performLoadTask(from: sut)
        await spy.completeSuccessfully()


        XCTAssertEqual(spy.urls, [anyURL, anyURL])
    }


    func test_load_deliversErrorOnClientError() async {
        let anyURL = anyURL()
        let (sut, spy) = makeSUT(url: anyURL)
        let clientError = NSError(domain: "client error", code: 0)

        let task = performLoadTask(from: sut)
        await spy.completeWith(error: clientError)

        do {
            try await task.value
            XCTFail("Expected \(clientError) error, got success instead")
        } catch {
            print("[DEBUG] error", error)
            XCTAssertEqual(error as NSError, clientError)
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
}
