//
//  LoadCharacterPresenterTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 05/07/2025.
//

import RickAndMorty
import Foundation
import Testing

class LoadCharacterPresenterTests {
    @Test
    func test_init_doesNotRequestLoadEpisode() {
        let (_, spy) = makeSUT()

        #expect(spy.loadCallCount == 0)
    }

    @Test
    func test_loadEpisodes_requestLoadFromLoader() async {
        let (sut, spy) = makeSUT()

        sut.loadEpisodes()
        spy.completeLoad(with: anyNSError())

        #expect(spy.loadCallCount == 1)
    }

    @Test
    func test_loadEpisodes_canLoadAnotherRequestAfterTheLastOneIsFinished() async {
        let (sut, spy) = makeSUT()

        sut.loadEpisodes()
        spy.completeLoad(with: anyNSError())
        _ = try? await spy.waitForResponse()

        sut.loadEpisodes()
        spy.completeLoad(with: anyNSError())

        #expect(spy.loadCallCount == 2)
    }

    @Test
    func test_loadEpisodes_cannotLoadAnotherResourceWhileTheCurrentIsRunning() async {
        let (sut, spy) = makeSUT()

        sut.loadEpisodes()
        sut.loadEpisodes()

        #expect(spy.loadCallCount == 1)
    }

    @Test
    func test_loadEpisodes_deliversErrorOnFailure() async {
        let (sut, spy) = makeSUT()
        let error = anyNSError()

        sut.loadEpisodes()
        spy.completeLoad(with: error)

        let receivedError = await #expect(throws: Error.self, performing: spy.waitForResponse)
        #expect(receivedError as? NSError == error)
    }

    @Test
    func test_loadEpisodes_deliversItemOnSuccess() async {
        let (sut, spy) = makeSUT()
        let item = anyCharacterItem()
        
        sut.loadEpisodes()
        spy.completeLoad(with: item)

        let response = try? await spy.waitForResponse()
        #expect(response == item)
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: LoadResourcePresenter<LoadCharacterSpy>, spy: LoadCharacterSpy) {
        let spy = LoadCharacterSpy()
        let sut = LoadResourcePresenter(loader: spy.load, delegate: spy)
        return (sut, spy)
    }

    class LoadCharacterSpy: LoadResourceDelegate {
        typealias ResourcePresentationItem = CharacterItem
        private(set) var loadCallCount = 0

        private var loadContinuation: CheckedContinuation<CharacterItem, Error>?
        private var delegateContinuation: CheckedContinuation<CharacterItem, Error>?

        func waitForResponse() async throws -> CharacterItem {
            return try await withCheckedThrowingContinuation { continuation in
                delegateContinuation = continuation
            }
        }

        // MARK: - Load

        func load() async throws -> CharacterItem {
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

        func completeLoad(with item: CharacterItem) {
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

        func didFinishLoading(with item: CharacterItem) {
            Task {
                await waitForContinuation()
                delegateContinuation?.resume(returning: item)
                delegateContinuation = nil
            }
        }
    }
}
