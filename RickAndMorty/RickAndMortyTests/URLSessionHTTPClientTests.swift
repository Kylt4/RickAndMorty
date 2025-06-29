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

    private struct UnexpectedValuesRepresentation: Error {}

    func get(from url: URL) async throws -> (response: HTTPURLResponse, data: Data) {
        let (data, response) = try await session.data(from: url)
        if let httpURLResponse = response as? HTTPURLResponse {
            return ((httpURLResponse, data))
        }
        throw UnexpectedValuesRepresentation()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    override func tearDown() {
        super.tearDown()

        MockURLProtocol.removeStub()
    }

    func test_getFromURL_performURLRequest() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        let sut = URLSessionHTTPClient(session: session)
        let url = anyURL()

        MockURLProtocol.observeRequests { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url, url)
        }

        _ = try? await sut.get(from: url)
    }

    func test_getFromURL_deliversEmptyDataOnNilDataWithHTTPURLResponse() async throws {
        let error = try await resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil)

        XCTAssertNil(error)
    }

    func test_getFromURL_deliversDataWithHTTPURLResponse() async throws {
        let httpURLResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = anyData()
        let sut = makeSUT()
        MockURLProtocol.stub(data: data, response: httpURLResponse, error: nil)

        let result = try await sut.get(from: anyURL())

        XCTAssertEqual(data, result.data)
        XCTAssertEqual(httpURLResponse?.statusCode, result.response.statusCode)
        XCTAssertEqual(httpURLResponse?.url, result.response.url)
    }

    func test_getFromURL_failsOnAllInvalidRepresentationValues() async throws {
        let t1 = try await resultErrorFor(data: Data(), response: anyURLResponse(), error: nil)
        let t2 = try await resultErrorFor(data: anyData(), response: anyURLResponse(), error: nil)
        let t3 = try await resultErrorFor(data: Data(), response: anyURLResponse(), error: anyNSError())
        let t4 = try await resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())
        let t5 = try await resultErrorFor(data: nil, response: anyURLResponse(), error: anyNSError())
        let t6 = try await resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError())
        let t7 = try await resultErrorFor(data: Data(), response: nil, error: anyNSError())
        let t8 = try await resultErrorFor(data: anyData(), response: nil, error: anyNSError())
        let t9 = try await resultErrorFor(data: nil, response: anyURLResponse(), error: nil)

        XCTAssertNotNil(t1)
        XCTAssertNotNil(t2)
        XCTAssertNotNil(t3)
        XCTAssertNotNil(t4)
        XCTAssertNotNil(t5)
        XCTAssertNotNil(t6)
        XCTAssertNotNil(t7)
        XCTAssertNotNil(t8)
        XCTAssertNotNil(t9)
    }

    // MARK: - Helpers

    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?) async throws -> Error? {
        let sut = makeSUT()

        MockURLProtocol.stub(data: data, response: response, error: error)

        do {
            _ = try await sut.get(from: anyURL())
            return nil
        } catch {
            return error
        }
    }

    private func makeSUT() -> URLSessionHTTPClient {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return URLSessionHTTPClient(session: session)
    }

    private class MockURLProtocol: URLProtocol {
        struct Stub {
            var data: Data?
            var response: URLResponse?
            var error: Error?
            var requestObserver: ((URLRequest) -> Void)?
        }

        static private(set) var stub: Stub?

        static func removeStub() {
            stub = nil
        }

        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: anyNSError(), requestObserver: observer)
        }

        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }

        override class func canInit(with request: URLRequest) -> Bool {
            true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }

        override func startLoading() {
            guard let stub = Self.stub else { return }

            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }

            stub.requestObserver?(request)
        }

        override func stopLoading() {}
    }
}
