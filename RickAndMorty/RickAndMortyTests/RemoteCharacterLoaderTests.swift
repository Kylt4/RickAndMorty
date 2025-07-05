//
//  RemoteCharacterLoaderTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 29/06/2025.
//

import Foundation
import XCTest
import RickAndMorty

class CharacterLoaderTests: XCTestCase {

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

    func test_load_deliversItemsOn200HTTPResponseStatusWithValidPayloadContract() async {
        let (sut, spy) = makeSUT()
        let item = makeItem()

        await expect(sut, toCompleteWithResult: .success(item.model), when: {
            await spy.completeWithStatusCode(code: 200, data: item.data)
        })
    }

    func test_load_deliversInvalidDataOn200HTTPResponseWithInvalidData() async {
        let (sut, spy) = makeSUT()

        await expect(sut, toCompleteWithResult: .failure(.invalidData), when: {
            await spy.completeWithStatusCode(code: 200, data: "invalid data".data(using: .utf8)!)
        })
    }

    // MARK: - helpers

    private func makeItem() -> (model: CharacterItem, data: Data) {
        let date = anyDate()
        let item = anyCharacterItem()
        let json: [String: Any] = [
            "id": item.id,
            "name": item.name,
            "status": item.status,
            "species": item.species,
            "type": item.type,
            "gender": item.gender,
            "origin": ["name": item.origin.name, "url": item.origin.url.absoluteString],
            "location": ["name": item.location.name, "url": item.location.url.absoluteString],
            "image": item.image.absoluteString,
            "created": date.iso8601
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        return (item, data)
    }

    private func expect(_ sut: RemoteCharacterLoader, toCompleteWithResult expectedResult: Swift.Result<CharacterItem, RemoteLoaderError>, when action: () async -> Void, file: StaticString = #filePath, line: UInt = #line) async {

        let task = performLoadTask(from: sut)
        await action()

        do {
            let values = try await task.value
            XCTAssertEqual(values, try expectedResult.get(), file: file, line: line)
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
    private func performLoadTask(from sut: RemoteCharacterLoader) -> Task<CharacterItem, Error> {
        Task {
            try await sut.load()
        }
    }

    private func makeSUT(url: URL = URL(string: "http://any-url.com")!) -> (sut: RemoteCharacterLoader, spy: HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = RemoteCharacterLoader(url: url, client: spy)
        return (sut, spy)
    }
}
