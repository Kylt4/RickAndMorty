//
//  LoadResourcePresenterTests.swift
//  RickAndMortyTests
//
//  Created by Christophe Bugnon on 06/07/2025.
//

import Foundation
import Testing
import RickAndMorty

class LoadResourcePresenterTests {
    @Test
    func test_init_doesNotSendMessageUponCreation() {
        let (_, spy) = makeSUT()

        #expect(spy.messages.isEmpty)
    }

    @Test
    func test_didStartLoading_displaysNoErrorAndStartLoading() {
        let (sut, spy) = makeSUT()

        sut.didStartLoading()

        #expect(spy.messages == [
            .display(errorMessage: nil),
            .display(isLoading: true)
        ])
    }

    @Test
    func test_didFinishedLoadingWithError_displaysErrorMessageAndStopLoading() {
        let (sut, spy) = makeSUT()

        sut.didFinishLoading(with: anyNSError())

        #expect(spy.messages == [
            .display(errorMessage: "Couldn't connect to server"),
            .display(isLoading: false)
        ])
    }

    @Test
    func test_didFinishedLoadingResourceWithMapping_displaysPresentationResourceAndStopLoading() {
        let message = "Any message"
        let (sut, spy) = makeSUT { message in
            message + " mapper message"
        }

        sut.didFinishLoading(with: message)

        #expect(spy.messages == [
            .display(presentationModel: "Any message mapper message"),
            .display(isLoading: false)
        ])
    }

    @Test
    func test_didFinishedLoadingResourceWithoutMapping_displaysResourceAndStopLoading() {
        let (sut, spy) = makeSUT()

        let message = "Any message"
        sut.didFinishLoading(with: message)

        #expect(spy.messages == [
            .display(presentationModel: message),
            .display(isLoading: false)
        ])
    }

    @Test
    func test_didFinishedLoadingResourceWithMappingError_displaysErrorMessageAndStopLoading() {
        let (sut, spy) = makeSUT { _ in throw anyNSError() }

        sut.didFinishLoading(with: "Any message")

        #expect(spy.messages == [
            .display(errorMessage: "Couldn't connect to server"),
            .display(isLoading: false)
        ])
    }

    // MARK: - Helpers

    private func makeSUT(mapper: @escaping (String) throws -> String = { $0 }) -> (sut: LoadResourcePresenter<String, ViewSpy>, spy: ViewSpy) {
        let spy = ViewSpy()
        let sut = LoadResourcePresenter(view: spy, mapper: mapper)
        return (sut, spy)
    }

    class ViewSpy: ResourceView {
        typealias Resource = String

        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(presentationModel: String)
        }

        private(set) var messages = [Message]()

        func display(errorMessage: String?) {
            messages.append(.display(errorMessage: errorMessage))
        }

        func display(isLoading: Bool) {
            messages.append(.display(isLoading: isLoading))
        }

        func display(presentationModel: String) {
            messages.append(.display(presentationModel: presentationModel))
        }

    }
}
