//
//  EpisodeLoaderTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 28/06/2025.
//

import XCTest

class HTTPClient {
    var urls = [URL]()

    func get(from url: URL) {
        urls.append(url)
    }
}

class EpisodeLoader {
    private let url: URL
    private let client: HTTPClient

    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    func load() {
        client.get(from: url)
    }
}

class EpisodeLoaderTests: XCTestCase {

    func test_init_doesNotRequestGetFromURL() {
        let (_, spy) = makeSUT()

        XCTAssertTrue(spy.urls.isEmpty)
    }

    func test_load_requestGetFromURL() {
        let anyURL = anyURL()
        let (sut, spy) = makeSUT(url: anyURL)

        sut.load()

        XCTAssertEqual(spy.urls, [anyURL])
    }

    func test_loadTwice_requestGetFromURLTwice() {
        let anyURL = anyURL()
        let (sut, spy) = makeSUT(url: anyURL)

        sut.load()
        sut.load()

        XCTAssertEqual(spy.urls, [anyURL, anyURL])
    }

    // MARK: - helpers

    private func makeSUT(url: URL = URL(string: "http://any-url.com")!) -> (sut: EpisodeLoader, spy: HTTPClient) {
        let spy = HTTPClient()
        let sut = EpisodeLoader(url: url, client: spy)

        return (sut, spy)
    }

    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}
