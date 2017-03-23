//
//  Command.swift
//  command-line-parser
//
//  Created by Andrew J Wagner on 12/7/16.
//
//

class Command {
    let name: String
    let handler: (Parser) throws -> ()
    let shortDescription: String?
    let longDescription: String?

    init(name: String, shortDescription: String?, longDescription: String?, handler: @escaping (Parser) throws -> ()) {
        self.name = name
        self.handler = handler
        self.shortDescription = shortDescription
        self.longDescription = longDescription
    }
}
