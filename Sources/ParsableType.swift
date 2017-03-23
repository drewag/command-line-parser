//
//  ParsableType.swift
//  command-line-parser
//
//  Created by Andrew J Wagner on 12/6/16.
//
//

import Foundation

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

extension URL: ParsableType {
    public init?(parse: String) {
        self.init(string: parse)
    }
}
