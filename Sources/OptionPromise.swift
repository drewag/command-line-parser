//
//  OptionPromise.swift
//  web
//
//  Created by Andrew J Wagner on 4/8/17.
//
//

public class OptionPromise {
    let name: String
    let abbreviation: Character?

    public internal(set) var wasPresent: Bool = false

    init(name: String, abbreviation: Character?) {
        self.name = name
        self.abbreviation = abbreviation
    }
}
