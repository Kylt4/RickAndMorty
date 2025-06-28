//
//  EpisodeLoaderTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 28/06/2025.
//

import XCTest

class HTTPClient {
    var urls = [URL]()
}

class EpisodeLoader {

}

class EpisodeLoaderTests: XCTestCase {

    func test_init_doesNotRequestGetFromURL() {
        let spy = HTTPClient()
        let _ = EpisodeLoader()

        XCTAssertTrue(spy.urls.isEmpty)
    }
}
