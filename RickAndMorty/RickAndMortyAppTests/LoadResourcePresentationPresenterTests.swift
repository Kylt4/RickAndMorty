//
//  LoadResourcePresentationPresenterTests.swift
//  RickAndMortyAppTests
//
//  Created by Christophe Bugnon on 10/07/2025.
//

import Foundation
import Testing
import RickAndMorty
import RickAndMortyApp

class LoadResourcePresentationPresenterTests {
    @Test
    func test_init_doesNotRequestLoadCharacter() {
        let (_, spy) = makeSUT()

        #expect(spy.loadCallCount == 0)
    }

    @Test
    func test_loadCharacter_requestLoadFromLoader() async {
        let (sut, spy) = makeSUT()

        sut.load()
        spy.completeLoad(with: anyNSError())

        #expect(spy.loadCallCount == 1)
    }

    @Test
    func test_loadCharacter_canLoadAnotherRequestAfterTheLastOneIsFinished() async {
        let (sut, spy) = makeSUT()

        sut.load()
        spy.completeLoad(with: anyNSError())
        _ = try? await spy.waitForResponse()

        sut.load()
        spy.completeLoad(with: anyNSError())

        #expect(spy.loadCallCount == 2)
    }

    @Test
    func test_loadCharacter_cannotLoadAnotherResourceWhileTheCurrentIsRunning() async {
        let (sut, spy) = makeSUT()

        sut.load()
        sut.load()

        #expect(spy.loadCallCount == 1)
    }

    @Test
    func test_loadCharacter_deliversErrorOnFailure() async {
        let (sut, spy) = makeSUT()
        let error = anyNSError()

        sut.load()
        spy.completeLoad(with: error)

        let receivedError = await #expect(throws: Error.self, performing: spy.waitForResponse)
        #expect(receivedError as? NSError == error)
    }

    @Test
    func test_loadCharacter_deliversItemOnSuccess() async {
        let (sut, spy) = makeSUT()
        let item = "Any string"

        sut.load()
        spy.completeLoad(with: item)

        let response = try? await spy.waitForResponse()
        #expect(response == item)
    }

    // MARK: - Helpers

    private func makeSUT() -> (sut: LoadResourcePresentationAdapter<LoadDelegateSpy, LoadDelegateSpy>, spy: LoadDelegateSpy) {
        let spy = LoadDelegateSpy()
        let sut = LoadResourcePresentationAdapter(loader: spy, delegate: spy)
        return (sut, spy)
    }

    class LoadDelegateSpy: LoadResourceDelegate, Loader {
        typealias Item = String
        typealias PresentationModel = String
        private(set) var loadCallCount = 0

        private var loadContinuation: CheckedContinuation<String, Error>?
        private var delegateContinuation: CheckedContinuation<String, Error>?

        func waitForResponse() async throws -> String {
            return try await withCheckedThrowingContinuation { continuation in
                delegateContinuation = continuation
            }
        }

        // MARK: - Load

        func load() async throws -> String {
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

        func completeLoad(with item: String) {
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

        func didFinishLoading(with item: String) {
            Task {
                await waitForContinuation()
                delegateContinuation?.resume(returning: item)
                delegateContinuation = nil
            }
        }
    }
}

private func anyNSError() -> NSError {
    NSError(domain: "any error", code: 0)
}

private func waitForContinuation() async {
    try? await Task.sleep(for: .milliseconds(1))
}
