//
//  File.swift
//  command-line-parser
//
//  Created by Andrew J Wagner on 12/6/16.
//
//

public class ParsePromise<Value: ParsableType> {
    let isOptional = false
    var validate: ((Value) -> String?)?

    public var parsedValue: Value {
        fatalError()
    }
}

public class OptionalParsePromise<Value: ParsableType> {
    let isOptional = true
    var validate: ((Value) -> String?)?

    public var parsedValue: Value? {
        fatalError()
    }
}

protocol InternalParsePromise {
    var name: String {get}
    func parse(string: String) -> String?
    var isOptional: Bool {get}
}

class ConcreteParsePromise<Value: ParsableType>: ParsePromise<Value>, InternalParsePromise {
    let name: String
    fileprivate var value: Value? = nil

    init(name: String) {
        self.name = name
    }

    func parse(string: String) -> String? {
        self.value = Value(parse: string)
        guard let value = self.value else {
            return "it is invalid"
        }
        return self.validate?(value)
    }

    override var parsedValue: Value {
        guard let value = self.value else {
            fatalError("Run parse on parser first")
        }

        return value
    }
}

class ConcreteOptionalParsePromise<Value: ParsableType>: OptionalParsePromise<Value>, InternalParsePromise {
    let name: String
    fileprivate var value: Value? = nil

    init(name: String) {
        self.name = name
    }

    func parse(string: String) -> String? {
        self.value = Value(parse: string)
        guard let value = self.value else {
            return "it is invalid"
        }
        return self.validate?(value)
    }

    override var parsedValue: Value? {
        return value
    }
}
