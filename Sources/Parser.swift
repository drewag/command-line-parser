//
//  Parser.swift
//  command-line-parser
//
//  Created by Andrew J Wagner on 12/6/16.
//
//

import Foundation

public struct ParseError: Error, CustomStringConvertible {
    public let description: String
}

public protocol CommandHandler {
    static var name: String {get}
    static var shortDescription: String? {get}
    static var longDescription: String? {get}
    static func handler(parser: Parser) throws
}

public class Parser {
    enum Spec {
        case promise(InternalParsePromise)
        case commands([Command])
    }

    let arguments: [String]
    let shortOptions: [Character]
    let longOptions: [String]

    fileprivate let command: Command?
    var specs = [Spec]()
    var optionPromises: [OptionPromise]

    private init(arguments: [String], shortOptions: [Character], longOptions: [String], optionPromises: [OptionPromise], command: Command?) {
        var finalArguments = [String]()
        var shortOptions = shortOptions
        var longOptions = longOptions
        for argument in arguments {
            if argument.hasPrefix("--") {
                longOptions.append(String(argument[argument.index(argument.startIndex, offsetBy: 2)...]))
            }
            else if argument.hasPrefix("-") {
                let source = argument[argument.index(argument.startIndex, offsetBy: 1)...]
                shortOptions += source
            }
            else {
                finalArguments.append(argument)
            }
        }
        self.arguments = finalArguments
        self.shortOptions = shortOptions
        self.longOptions = longOptions

        self.command = command
        self.optionPromises = optionPromises
    }

    public convenience init(arguments: [String]) {
        self.init(arguments: arguments, shortOptions: [], longOptions: [], optionPromises: [], command: nil)
    }

    public func parse(beforeExecute: (() throws -> ())? = nil) throws {
        for option in self.optionPromises {
            guard self.longOptions.contains(option.name) || (option.abbreviation != nil && self.shortOptions.contains(option.abbreviation!)) else {
                continue
            }
            option.wasPresent = true
        }

        for (index, spec) in self.specs.enumerated() {
            switch spec {
            case .promise(let promise):
                guard index + 1 < arguments.count else {
                    guard !promise.isOptional else {
                        break
                    }
                    throw self.generateUsageError()
                }

                if let error = promise.parse(string: self.arguments[index + 1]) {
                    throw ParseError(description: "Failed to parse \(promise.name)\n\(error)\n\n\(self.generateUsage())")
                }
            case .commands(let commands):
                guard index + 1 < arguments.count else {
                    throw self.generateUsageError()
                }

                for command in commands {
                    if command.name == self.arguments[index + 1] {
                        let commandCall = self.arguments[0 ... index + 1].joined(separator: " ")
                        let remainingArguments = self.arguments[index + 2 ..< self.arguments.count]

                        let parser = Parser(
                            arguments: [commandCall] + remainingArguments,
                            shortOptions: self.shortOptions,
                            longOptions: self.longOptions,
                            optionPromises: self.optionPromises,
                            command: command
                        )
                        try beforeExecute?()
                        try command.handler(parser)

                        return
                    }
                }
                throw self.generateUsageError()
            }
        }

        if self.shortOptions.contains("h") || self.longOptions.contains("help") {
            throw self.generateUsageError()
        }
    }

    public func option(named: String, abbreviatedWith character: Character? = nil) -> OptionPromise {
        let promise = OptionPromise(name: named, abbreviation: character)
        self.optionPromises.append(promise)
        return promise
    }

    public func command(named: String, shortDescription: String? = nil, longDescription: String? = nil, handler: @escaping (Parser) throws -> ()) {
        let command = Command(name: named, shortDescription: shortDescription, longDescription: longDescription, handler: handler)

        guard let lastSpec = self.specs.last else {
            self.specs.append(.commands([command]))
            return
        }

        switch lastSpec {
        case .commands(var commands):
            commands.append(command)
            self.specs.removeLast()
            self.specs.append(.commands(commands))
        case .promise:
            self.specs.append(.commands([command]))
        }
    }

    public func command<Handler: CommandHandler>(_ handler: Handler.Type) {
        self.command(named: handler.name, shortDescription: handler.shortDescription, longDescription: handler.longDescription, handler: handler.handler)
    }
}

// MARK: Internal

extension Parser {
    var hasOptionalPromise: Bool {
        for spec in self.specs {
            switch spec {
            case .promise(let promise):
                if promise.isOptional {
                    return true
                }
            case .commands:
                break
            }
        }
        return false
    }

    var hasCommand: Bool {
        for spec in self.specs {
            switch spec {
            case .promise:
                break
            case .commands:
                return true
            }
        }
        return false
    }
}

private extension Parser {
    func generateUsage() -> String {
        var usage = "Usage: \(self.arguments[0])"

        func addDescription() {
            if let description = self.command?.longDescription ?? self.command?.shortDescription {
                usage += "\n\(description)\n"
            }
        }

        for option in self.optionPromises {
            usage += " [--\(option.name)]"
        }

        for spec in self.specs {
            switch spec {
            case .promise(let promise):
                if promise.isOptional {
                    usage += " [\(promise.name)]"
                }
                else {
                    usage += " <\(promise.name)>"
                }
            case .commands(let commands):
                usage += " <command>\n"
                addDescription()
                usage += "\nThe following commands are available:\n"
                let maxNameLength = commands.map({$0.name.count}).max() ?? 0
                for command in commands {
                    usage += "\n"
                    usage += "    \(command.name.padding(toLength: maxNameLength + 4, withPad: " ", startingAt: 0))"
                    if let description = command.shortDescription {
                        usage += "\(description)"
                    }
                }
                usage += "\n"
                return usage
            }
        }

        usage += "\n"
        addDescription()
        return usage
    }

    func generateUsageError() -> ParseError {
        return ParseError(description: self.generateUsage())
    }
}
