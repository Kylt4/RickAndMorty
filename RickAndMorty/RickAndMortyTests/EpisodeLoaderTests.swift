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
        let spy = HTTPClient()
        let _ = EpisodeLoader(url: URL(string: "http://any-url.com")!, client: spy)

        XCTAssertTrue(spy.urls.isEmpty)
    }

    func test_load_requestGetFromURL() {
        let anyURL = URL(string: "http://any-url.com")!
        let spy = HTTPClient()
        let sut = EpisodeLoader(url: anyURL, client: spy)

        sut.load()

        XCTAssertEqual(spy.urls, [anyURL])
    }
}
