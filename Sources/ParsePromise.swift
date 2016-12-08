//
//  File.swift
//  command-line-parser
//
//  Created by Andrew J Wagner on 12/6/16.
//
//

public class ParsePromise<Value: ParsableType> {
    let isOptional = false

    public var parsedValue: Value {
        fatalError()
    }
}

public class OptionalParsePromise<Value: ParsableType> {
    let isOptional = true

    public var parsedValue: Value? {
        fatalError()
    }
}

protocol InternalParsePromise {
    var name: String {get}
    func parse(string: String) -> Bool
    var isOptional: Bool {get}
}

class ConcreteParsePromise<Value: ParsableType>: ParsePromise<Value>, InternalParsePromise {
    let name: String
    fileprivate var value: Value? = nil

    init(name: String) {
        self.name = name
    }

    func parse(string: String) -> Bool {
        self.value = Value(parse: string)
        return self.value != nil
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

    func parse(string: String) -> Bool {
        self.value = Value(parse: string)
        return self.value != nil
    }

    override var parsedValue: Value? {
        return value
    }
}
