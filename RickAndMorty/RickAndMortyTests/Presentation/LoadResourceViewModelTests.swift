//
//  LoadResourceViewModelTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 07/07/2025.
//

import Foundation
import Testing
import RickAndMorty

class LoadResourceViewModelTests {
    @Test
    func test_init_doesNotSendMessageUponCreation() {
        let sut = makeSUT()

        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
        #expect(sut.item == nil)
    }

    @Test
    func test_didStartLoading_displaysNoErrorAndStartLoading() {
        let sut = makeSUT()

        sut.didStartLoading()

        #expect(sut.isLoading == true)
        #expect(sut.errorMessage == nil)
        #expect(sut.item == nil)
    }

    @Test
    func test_didFinishedLoadingWithError_displaysErrorMessageAndStopLoading() {
        let sut = makeSUT()

        sut.didFinishLoading(with: anyNSError())

        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == "Couldn't connect to server")
        #expect(sut.item == nil)
    }

    @Test
    func test_didFinishedLoadingResourceWithMapping_displaysPresentationResourceAndStopLoading() {
        let message = "Any message"
        let sut = makeSUT { message in
            message + " mapper message"
        }

        sut.didFinishLoading(with: message)

        #expect(sut.item == "Any message mapper message")
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
    }

    @Test
    func test_didFinishedLoadingResourceWithoutMapping_displaysResourceAndStopLoading() {
        let sut = makeSUT()

        let message = "Any message"
        sut.didFinishLoading(with: message)

        #expect(sut.item == message)
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == nil)
    }

    @Test
    func test_didFinishedLoadingResourceWithMappingError_displaysErrorMessageAndStopLoading() {
        let sut = makeSUT { _ in throw anyNSError() }

        sut.didFinishLoading(with: "Any message")

        #expect(sut.item == nil)
        #expect(sut.isLoading == false)
        #expect(sut.errorMessage == "Couldn't connect to server")
    }

    // MARK: - Helpers

    private func makeSUT(mapper: @escaping (String) throws -> String = { $0 }) -> LoadResourceViewModel<String, String> {
        return LoadResourceViewModel(mapper: mapper)
    }
}
