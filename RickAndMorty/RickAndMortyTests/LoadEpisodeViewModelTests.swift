//
//  LoadEpisodeViewModelTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 05/07/2025.
//

import RickAndMorty
import Foundation
import Testing

class LoadEpisodeViewModelTests {
    @Test
    func test_init_doesNotRequestLoadEpisode() {
        let (sut, spy) = makeSUT()

        #expect(spy.loadCallCount == 0)
        #expect(sut.isLoading == false)
    }

    @Test
    func test_loadEpisodes_requestLoadFromLoader() async {
        let (sut, spy) = makeSUT()

        let task = Task { await sut.load() }
        spy.completeLoad(with: anyNSError())
        await task.value

        #expect(spy.loadCallCount == 1)
        #expect(spy.isOnMainThread == false)
        #expect(sut.isLoading == false)
    }

    @Test
    func test_loadEpisodes_canLoadAnotherRequestAfterTheLastOneIsFinished() async {
        let (sut, spy) = makeSUT()

        let task = Task {
            await sut.load()
        }

        spy.completeLoad(with: anyNSError())
        await task.value

        Task { await sut.load() }
        try? await Task.sleep(nanoseconds: 1_000_000)

        #expect(spy.isOnMainThread == false)
        #expect(spy.loadCallCount == 2)
        #expect(sut.isLoading == true)
    }

    @Test
    func test_loadEpisodes_cannotLoadAnotherResourceWhileTheCurrentIsRunning() async {
        let (sut, spy) = makeSUT()

        Task { await sut.load() }
        Task { await sut.load() }

        await waitForCompletions()
        #expect(spy.isOnMainThread == false)
        #expect(spy.loadCallCount == 1)
        #expect(sut.isLoading == true)
    }

    @Test
    func test_loadEpisodes_deliversErrorOnFailure() async {
        let (sut, spy) = makeSUT()
        let error = anyNSError()

        let task = Task { await sut.load() }
        spy.completeLoad(with: error)
        await task.value

        await waitForCompletions()
        #expect(spy.isOnMainThread == false)
        #expect((spy.receivedError as? NSError) == error)
        #expect((sut.error as? NSError) == error)
    }

    @Test
    func test_loadEpisodes_deliversItemOnSuccess() async {
        let (sut, spy) = makeSUT()
        let item = anyPageEpisodeItems()

        let task = Task { await sut.load() }
        spy.completeLoad(with: item)
        await task.value

        await waitForCompletions()
        #expect(spy.isOnMainThread == false)
        #expect(spy.receivedItem == item)
        #expect(sut.item == item)
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: LoadResourceViewModel<LoadCharacterSpy, LoadCharacterSpy>, spy: LoadCharacterSpy) {
        let spy = LoadCharacterSpy()
        let sut = LoadResourceViewModel(loader: spy, delegate: spy)
        return (sut, spy)
    }

    class LoadCharacterSpy: LoadResourceDelegate, EpisodeLoader {
        typealias Item = PageEpisodeModels
        typealias PresentationModel = PageEpisodeModels
        private(set) var loadCallCount = 0
        private(set) var receivedItem: Item?
        private(set) var receivedError: Error?
        private(set) var isOnMainThread: Bool?

        private var loadContinuation: CheckedContinuation<PageEpisodeModels, Error>?

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
            isOnMainThread = Thread.isMainThread
            loadCallCount += 1
        }

        func didFinishLoading(with error: Error) {
            isOnMainThread = Thread.isMainThread
            receivedError = error
        }

        func didFinishLoading(with item: PageEpisodeModels) {
            isOnMainThread = Thread.isMainThread
            receivedItem = item
        }
    }
}
