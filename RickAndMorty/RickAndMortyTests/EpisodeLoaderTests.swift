//
//  EpisodeLoaderTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 28/06/2025.
//

import XCTest

struct PageEpisodeItems: Decodable, Equatable {
    let info: PageInfo
    let results: [RemoteEpisodeItem]
}

struct PageInfo: Decodable, Equatable {
    let count: Int
    let pages: Int
    let prev: URL?
    let next: URL?
}

struct RemoteEpisodeItem: Decodable, Equatable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    let episodeURL: URL
    let created: Date
    let characters: [URL]

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case airDate = "air_date"
        case episode
        case characters
        case url
        case created
    }

    init(id: Int, name: String, airDate: String, episode: String, episodeURL: URL, created: Date, characters: [URL]) {
        self.id = id
        self.name = name
        self.airDate = airDate
        self.episode = episode
        self.episodeURL = episodeURL
        self.created = created
        self.characters = characters
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.airDate = try container.decode(String.self, forKey: .airDate)
        self.episode = try container.decode(String.self, forKey: .episode)
        self.characters = try container.decode([URL].self, forKey: .characters)
        self.episodeURL = try container.decode(URL.self, forKey: .url)
        let stringCreated = try container.decode(String.self, forKey: .created)
        self.created = Date.fromISO8601(stringCreated)!
    }
}

class HTTPClient {
    var urls = [URL]()

    var continuations: [CheckedContinuation<(response: HTTPURLResponse, data: Data), Error>?] = []

    func get(from url: URL) async throws -> (response: HTTPURLResponse, data: Data)  {
        urls.append(url)
        return try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func completeWithStatusCode(code: Int, data: Data = Data(), index: Int = 0) async {
        try? await Task.sleep(nanoseconds: 1_000_000)
        let response = HTTPURLResponse(
            url: urls[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil)!
        continuations[index]?.resume(with: .success((response, data)))
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

    func load() async throws -> PageEpisodeItems {
        guard let result = try? await client.get(from: url) else {
            throw EpisodeLoaderError.connectivity
        }

        if result.response.statusCode != 200 {
            throw EpisodeLoaderError.invalidData
        }

        do {
            let page = try JSONDecoder().decode(PageEpisodeItems.self, from: result.data)
            return page
        } catch {
            print(error)
            fatalError()
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

        await expect(sut, toCompleteWithError: .failure(.connectivity), when: {
            await spy.completeWith(error: clientError)
        })
    }

    func test_load_deliversInvalidDataErrorOnNon200HTTPResponseStatusCode() async {
        let (sut, spy) = makeSUT()
        let samples = [199, 201, 202, 203, 204]

        for (id, code) in samples.enumerated() {
            await expect(sut, toCompleteWithError: .failure(.invalidData), when: {
                await spy.completeWithStatusCode(code: code, index: id)
            })
        }
    }

    func test_load_deliversItemsOn200HTTPResponseStatusCodeWithNilValues() async {
        let (sut, spy) = makeSUT()
        let item = makeItems(prev: nil, next: nil)

        await expect(sut, toCompleteWithError: .success(item.model), when: {
            await spy.completeWithStatusCode(code: 200, data: item.data)
        })
    }

    func test_load_deliversItemsOn200HTTPResponseStatusCodeWithNonNilValues() async {
        let (sut, spy) = makeSUT()
        let item = makeItems(prev: URL(string: "http://prev-url.com")!, next: URL(string: "http://next-url.com")!)

        await expect(sut, toCompleteWithError: .success(item.model), when: {
            await spy.completeWithStatusCode(code: 200, data: item.data)
        })
    }

    // MARK: - helpers

    private func makeItems(prev: URL?, next: URL?) -> (model: PageEpisodeItems, data: Data) {
        let date = Date(timeIntervalSince1970: 1751179947)
        let pageInfo = PageInfo(count: 10, pages: 0, prev: prev, next: next)
        let item = RemoteEpisodeItem(id: 0, name: "any name", airDate: "any date", episode: "any episodes", episodeURL: URL(string: "http://any-episode-url.com")!, created: date, characters: [URL(string: "http://any-character-url.com")!])
        let page = PageEpisodeItems(info: pageInfo, results: [item])

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

    private func expect(_ sut: EpisodeLoader, toCompleteWithError expectedResult: Swift.Result<PageEpisodeItems, EpisodeLoader.EpisodeLoaderError>, when action: () async -> Void, file: StaticString = #filePath, line: UInt = #line) async {

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
                XCTAssertEqual(expectedError, error as? EpisodeLoader.EpisodeLoaderError, file: file, line: line)
            }
        }
    }

    @discardableResult
    private func performLoadTask(from sut: EpisodeLoader) -> Task<PageEpisodeItems, Error> {
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
        URL(string: "http://any-url.com")!
    }

    private func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
}

extension Date {
    var iso8601: String {
        Date.isoFormatter.string(from: self)
    }

    static func fromISO8601(_ string: String) -> Date? {
        return isoFormatter.date(from: string)
    }

    private static var isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        formatter.timeZone = .current
        return formatter
    }()
}
