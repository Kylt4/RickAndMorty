//
//  LoadEpisodePresenterTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 02/07/2025.
//

import RickAndMorty
import Foundation
import Testing

class LoadEpisodePresenterTests {
    @Test
    func test_init_doesNotRequestLoadEpisode() {
        let spy = LoadEpisodeSpy()
        let _ = LoadEpisodePresenter(delegate: spy, loader: spy)

        #expect(spy.loadCallCount == 0)
    }

    @Test
    func test_loadEpisodes_requestLoadFromLoader() async {
        let spy = LoadEpisodeSpy()
        let sut = LoadEpisodePresenter(delegate: spy, loader: spy)

        sut.loadEpisodes()
        spy.completeLoad(with: anyNSError())

        #expect(spy.loadCallCount == 1)
    }

    @Test
    func test_loadEpisodes_canLoadAnotherRequestAfterTheLastOneIsFinished() async {
        let spy = LoadEpisodeSpy()
        let sut = LoadEpisodePresenter(delegate: spy, loader: spy)

        sut.loadEpisodes()
        spy.completeLoad(with: anyNSError())
        _ = try? await spy.waitForResponse()

        sut.loadEpisodes()
        spy.completeLoad(with: anyNSError())

        #expect(spy.loadCallCount == 2)
    }

    @Test
    func test_loadEpisodes_cannotLoadAnotherResourceWhileTheCurrentIsRunning() async {
        let spy = LoadEpisodeSpy()
        let sut = LoadEpisodePresenter(delegate: spy, loader: spy)

        sut.loadEpisodes()
        sut.loadEpisodes()

        #expect(spy.loadCallCount == 1)
    }

    @Test
    func test_loadEpisodes_deliversErrorOnFailure() async {
        let spy = LoadEpisodeSpy()
        let sut = LoadEpisodePresenter(delegate: spy, loader: spy)
        let error = anyNSError()

        sut.loadEpisodes()
        spy.completeLoad(with: error)

        let receivedError = await #expect(throws: Error.self, performing: spy.waitForResponse)
        #expect(receivedError as? NSError == error)
    }

    @Test
    func test_loadEpisodes_deliversItemOnSuccess() async {
        let spy = LoadEpisodeSpy()
        let sut = LoadEpisodePresenter(delegate: spy, loader: spy)
        let item = anyPageEpisodeItems()

        sut.loadEpisodes()
        spy.completeLoad(with: item)

        let response = try? await spy.waitForResponse()
        #expect(response == item)
    }

    // MARK: - Helpers

    class LoadEpisodeSpy: LoadEpisodeDelegate, EpisodeLoader {
        private(set) var loadCallCount = 0

        private var loadContinuation: CheckedContinuation<PageEpisodeItems, Error>?
        private var delegateContinuation: CheckedContinuation<PageEpisodeItems, Error>?

        func waitForResponse() async throws -> PageEpisodeItems {
            return try await withCheckedThrowingContinuation { continuation in
                delegateContinuation = continuation
            }
        }

        // MARK: - Load

        func load() async throws -> PageEpisodeItems {
            return try await withCheckedThrowingContinuation { continuation in
                loadContinuation = continuation
            }
        }

        func completeLoad(with error: Error) {
            Task {
                await waitForContinuation()
                loadContinuation?.resume(throwing: error)
                loadContinuation = nil
            }
        }

        func completeLoad(with item: PageEpisodeItems) {
            Task {
                await waitForContinuation()
                loadContinuation?.resume(returning: item)
                loadContinuation = nil
            }
        }

        // MARK: - Delegate

        func didStartLoading() {
            loadCallCount += 1
        }

        func didFinishLoading(with error: Error) {
            Task {
                await waitForContinuation()
                delegateContinuation?.resume(throwing: error)
                delegateContinuation = nil
            }
        }

        func didFinishLoading(with item: PageEpisodeItems) {
            Task {
                await waitForContinuation()
                delegateContinuation?.resume(returning: item)
                delegateContinuation = nil
            }
        }
    }
}
