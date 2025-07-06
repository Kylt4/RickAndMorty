//
//  RemoteImageDataLoaderTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 30/06/2025.
//

import Foundation
import XCTest
import RickAndMorty
import AppKit

class RemoteImageDataLoaderTests: XCTestCase {

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

        await expect(sut, toCompleteWithResult: .failure(.connectivity), when: {
            await spy.completeWith(error: clientError)
        })
    }

    func test_load_deliversInvalidDataErrorOnNon200HTTPResponseStatusCode() async {
        let (sut, spy) = makeSUT()
        let samples = [199, 201, 202, 203, 204]

        for (id, code) in samples.enumerated() {
            await expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
                await spy.completeWithStatusCode(code: code, index: id)
            })
        }
    }

    func test_load_deliversItemsOn200HTTPResponseStatusWithAnyData() async {
        let (sut, spy) = makeSUT()
        let data = anyData()

        await expect(sut, toCompleteWithResult: .success(data), when: {
            await spy.completeWithStatusCode(code: 200, data: data)
        })
    }

    // MARK: - helpers

    private func expect(_ sut: RemoteImageDataLoader, toCompleteWithResult expectedResult: Swift.Result<Data, RemoteLoaderError>, when action: () async -> Void, file: StaticString = #filePath, line: UInt = #line) async {

        let task = performLoadTask(from: sut)
        await action()

        do {
            let values = try await task.value
            XCTAssertEqual(values, try expectedResult.get(), "Expected \(expectedResult), got \(values) instead", file: file, line: line)
        } catch {
            switch expectedResult {
            case .success:
                XCTFail("Expected \(expectedResult), but received \(error) error instead", file: file, line: line)
            case let .failure(expectedError):
                XCTAssertEqual(expectedError, error as? RemoteLoaderError, file: file, line: line)
            }
        }
    }

    @discardableResult
    private func performLoadTask(from sut: RemoteImageDataLoader) -> Task<Data, Error> {
        Task {
            try await sut.load()
        }
    }

    private func makeSUT(url: URL = URL(string: "http://any-url.com")!) -> (sut: RemoteImageDataLoader, spy: HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = RemoteImageDataLoader(url: url, client: spy)
        return (sut, spy)
    }
}
