//
//  URLSessionHTTPClientTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation
import XCTest
import RickAndMorty

class URLSessionHTTPClient {
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func get(from url: URL) async {
        try? await session.data(from: url)
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    func test_getFromURL_performURLRequest() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let sut = URLSessionHTTPClient(session: session)
        let url = anyURL()

        MockURLProtocol.stub = MockURLProtocol.Stub(requestObserver: { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url, url)
        })

        await sut.get(from: url)
    }

    private class MockURLProtocol: URLProtocol {
        struct Stub {
            var requestObserver: (URLRequest) -> Void
        }

        static var stub: Stub?

        override class func canInit(with request: URLRequest) -> Bool {
            true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }

        override func startLoading() {
            client?.urlProtocol(self, didFailWithError: anyNSError())
            client?.urlProtocolDidFinishLoading(self)
            Self.stub?.requestObserver(request)
        }

        override func stopLoading() {}
    }
}
