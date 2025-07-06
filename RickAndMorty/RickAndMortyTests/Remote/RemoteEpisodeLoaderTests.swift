//
//  RemoteEpisodeLoaderTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 28/06/2025.
//

import XCTest
import RickAndMorty

class RemoteEpisodeLoaderTests: XCTestCase {

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

    func test_load_deliversItemsOn200HTTPResponseStatusCodeWithNilValues() async {
        let (sut, spy) = makeSUT()
        let item = makeItems(prev: nil, next: nil)

        await expect(sut, toCompleteWithResult: .success(item.model), when: {
            await spy.completeWithStatusCode(code: 200, data: item.data)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseStatusCodeWithNonNilValues() async {
        let (sut, spy) = makeSUT()
        let item = makeItems(prev: URL(string: "http://prev-url.com")!, next: URL(string: "http://next-url.com")!)

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

    private func makeItems(prev: URL?, next: URL?) -> (model: PageEpisodeModels, data: Data) {
        let date = anyDate()
        let pageInfo = pageInfo(prev: prev, next: next)
        let item = anyEpisodeItem()
        let page = PageEpisodeModels(info: pageInfo, results: [item])

        let infoJSON: [String: Any?] = [
            "count": pageInfo.count,
            "pages": pageInfo.pages,
            "next": pageInfo.next?.absoluteString,
            "prev": pageInfo.prev?.absoluteString
        ]
        let json: [String: Any] = [
            "info": infoJSON.compactMapValues { $0 },
            "results": [
                [
                "id": item.id,
                "name": item.name,
                "air_date": item.airDate,
                "episode": item.episode,
                "url": item.episodeURL.absoluteString,
                "created": date.iso8601,
                "characters": item.characters.map(\.absoluteString)
                ]
            ]
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        return (page, data)
    }

    private func expect(_ sut: RemoteEpisodeLoader, toCompleteWithResult expectedResult: Swift.Result<PageEpisodeModels, RemoteLoaderError>, when action: () async -> Void, file: StaticString = #filePath, line: UInt = #line) async {

        let task = performLoadTask(from: sut)
        await action()

        do {
            let values = try await task.value
            XCTAssertEqual(values, try expectedResult.get(), file: file, line: line)
        } catch {
            switch expectedResult {
            case let .success(receivedItems):
                XCTFail("Expected failure, but received \(receivedItems) items instead", file: file, line: line)
            case let .failure(expectedError):
                XCTAssertEqual(expectedError, error as? RemoteLoaderError, file: file, line: line)
            }
        }
    }

    @discardableResult
    private func performLoadTask(from sut: RemoteEpisodeLoader) -> Task<PageEpisodeModels, Error> {
        Task {
            try await sut.load()
        }
    }

    private func makeSUT(url: URL = URL(string: "http://any-url.com")!) -> (sut: RemoteEpisodeLoader, spy: HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = RemoteEpisodeLoader(url: url, client: spy)
        return (sut, spy)
    }
}
