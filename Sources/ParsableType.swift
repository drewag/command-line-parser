//
//  ParsableType.swift
//  command-line-parser
//
//  Created by Andrew J Wagner on 12/6/16.
//
//

public protocol ParsableType {
    init?(parse: String)
}

extension String: ParsableType {
    public init?(parse: String) {
        self = parse
    }
}

extension Int: ParsableType {
    public init?(parse: String) {
        self.init(parse)
    }
}
