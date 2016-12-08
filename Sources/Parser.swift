//
//  Parser.swift
//  command-line-parser
//
//  Created by Andrew J Wagner on 12/6/16.
//
//

public struct ParseError: Error, CustomStringConvertible {
    public let description: String
}

public class Parser {
    enum Spec {
        case promise(InternalParsePromise)
        case commands([Command])
    }

    let arguments: [String]

    var specs = [Spec]()

    public init(arguments: [String]) {
        self.arguments = arguments
    }

    public func parse() throws {
        for (index, spec) in self.specs.enumerated() {
            switch spec {
            case .promise(let promise):
                guard index + 1 < arguments.count else {
                    guard !promise.isOptional else {
                        return
                    }
                    throw self.generateUsage()
                }

                promise.parse(string: self.arguments[index + 1])
            case .commands(let commands):
                guard index + 1 < arguments.count else {
                    throw self.generateUsage()
                }

                for command in commands {
                    if command.name == self.arguments[index + 1] {
                        let commandCall = self.arguments[0 ... index + 1].joined(separator: " ")
                        let remainingArguments = self.arguments[index + 1 ..< self.arguments.count]

                        let parser = Parser(arguments: [commandCall] + remainingArguments)
                        try command.handler(parser)

                        return
                    }
                }
                throw self.generateUsage()
            }
        }
    }

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

    public func optionalString(named: String) -> OptionalParsePromise<String> {
        guard !self.hasCommand else {
            fatalError("Cannot specify argument after command. Instead add them to command parser.")
        }

        let promise = ConcreteOptionalParsePromise<String>(name: named)

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

    public func command(named: String, handler: @escaping (Parser) throws -> ()) {
        let command = Command(name: named, handler: handler)

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
}

private extension Parser {
    func generateUsage() -> ParseError {
        var usage = "Usage: \(self.arguments[0])"
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
                usage += " " + commands.map({$0.name}).joined(separator: "|")
            }
        }
        return ParseError(description: usage)
    }

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
