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
        let (_, spy) = makeSUT()

        #expect(spy.loadCallCount == 0)
    }

    @Test
    func test_loadEpisodes_requestLoadFromLoader() async {
        let (sut, spy) = makeSUT()

        sut.load()
        spy.completeLoad(with: anyNSError())

        #expect(spy.loadCallCount == 1)
    }

    @Test
    func test_loadEpisodes_canLoadAnotherRequestAfterTheLastOneIsFinished() async {
        let (sut, spy) = makeSUT()

        sut.load()
        spy.completeLoad(with: anyNSError())
        _ = try? await spy.waitForResponse()

        sut.load()
        spy.completeLoad(with: anyNSError())

        #expect(spy.loadCallCount == 2)
    }

    @Test
    func test_loadEpisodes_cannotLoadAnotherResourceWhileTheCurrentIsRunning() async {
        let (sut, spy) = makeSUT()

        sut.load()
        sut.load()

        #expect(spy.loadCallCount == 1)
    }

    @Test
    func test_loadEpisodes_deliversErrorOnFailure() async {
        let (sut, spy) = makeSUT()
        let error = anyNSError()

        sut.load()
        spy.completeLoad(with: error)

        let receivedError = await #expect(throws: Error.self, performing: spy.waitForResponse)
        #expect(receivedError as? NSError == error)
    }

    @Test
    func test_loadEpisodes_deliversItemOnSuccess() async {
        let (sut, spy) = makeSUT()
        let item = anyPageEpisodeItems()

        sut.load()
        spy.completeLoad(with: item)

        let response = try? await spy.waitForResponse()
        #expect(response == item)
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: LoadResourcePresenter<LoadEpisodeSpy, LoadEpisodeSpy>, spy: LoadEpisodeSpy) {
        let spy = LoadEpisodeSpy()
        let sut = LoadResourcePresenter(loader: spy, view: spy)
        return (sut, spy)
    }

    class LoadEpisodeSpy: LoadResourceDelegate, EpisodeLoader {
        typealias Item = PageEpisodeModels
        typealias PresentationModel = PageEpisodeModels
        private(set) var loadCallCount = 0

        private var loadContinuation: CheckedContinuation<PageEpisodeModels, Error>?
        private var delegateContinuation: CheckedContinuation<PageEpisodeModels, Error>?

        func waitForResponse() async throws -> PageEpisodeModels {
            return try await withCheckedThrowingContinuation { continuation in
                delegateContinuation = continuation
            }
        }

        // MARK: - Load

        func load() async throws -> PageEpisodeModels {
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

        func completeLoad(with item: PageEpisodeModels) {
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

        func didFinishLoading(with item: PageEpisodeModels) {
            Task {
                await waitForContinuation()
                delegateContinuation?.resume(returning: item)
                delegateContinuation = nil
            }
        }
    }
}
