//
//  Parser+Basic.swift
//  CommandLineParser
//
//  Created by Andrew Wagner on 5/24/19.
//

import Foundation

extension Parser {
    public func string(named: String) -> ParsePromise<String> {
        guard !self.hasOptionalPromise else {
            fatalError("Cannot specify required argument after optional argument")
        }
        guard !self.hasCommand else {
            fatalError("Cannot specify argument after command. Instead add them to command parser.")
        }

        let promise = ConcreteParsePromise<String>(name: named)

        self.specs.append(.promise(promise))

        return promise
    }

    public func optionalString(named: String) -> OptionalParsePromise<String> {
        guard !self.hasCommand else {
            fatalError("Cannot specify argument after command. Instead add them to command parser.")
        }

        let promise = ConcreteOptionalParsePromise<String>(name: named)

        self.specs.append(.promise(promise))

        return promise
    }

    public func int(named: String) -> ParsePromise<Int> {
        guard !self.hasOptionalPromise else {
            fatalError("Cannot specify required argument after optional argument")
        }
        guard !self.hasCommand else {
            fatalError("Cannot specify argument after command. Instead add them to command parser.")
        }

        let promise = ConcreteParsePromise<Int>(name: named)

        self.specs.append(.promise(promise))

        return promise
    }

    public func optionalInt(named: String) -> OptionalParsePromise<Int> {
        guard !self.hasCommand else {
            fatalError("Cannot specify argument after command. Instead add them to command parser.")
        }

        let promise = ConcreteOptionalParsePromise<Int>(name: named)

        self.specs.append(.promise(promise))

        return promise
    }

    public func url(named: String) -> ParsePromise<URL> {
        guard !self.hasOptionalPromise else {
            fatalError("Cannot specify required argument after optional argument")
        }
        guard !self.hasCommand else {
            fatalError("Cannot specify argument after command. Instead add them to command parser.")
        }

        let promise = ConcreteParsePromise<URL>(name: named)

        self.specs.append(.promise(promise))

        return promise
    }
}
