Command Line Parser
====================

Usage
-----

### Simple

Arguments are strongly typed. After specifying all of the arguments call parse on the parser. If there is a usage problem, an
error will be thrown that describes the correct usage. If an error is not thrown, you can access the values from the arguments
with the `parsedValue` property.

    import Foundation
    import CommandLineParser

    let parser = Parser(arguments: CommandLine.arguments)

    let arg1 = parser.string(named: "some_string")
    let arg2 = parser.int(named: "some_int")

    do {
        try parser.parse()

        let someString = arg1.parsedValue
        let someInt = arg2.parsedValue

        // Use someString and someInt
    }
    catch let error {
        print(usage) // "Usage: ./binary <some_string> <some_int>"
    }

### Optional Arguments

You can specify optional arguments at the end. The `parsedValue` of these arguments are optionals.

    import Foundation
    import CommandLineParser

    let parser = Parser(arguments: CommandLine.arguments)

    let arg1 = parser.string(named: "some_string")
    let arg2 = parser.optionalString(named: "optional_string")

    do {
        try parser.parse()

        let someString = arg1.parsedValue
        let optionalString = arg2.parsedValue

        // Use someString and optionalString
    }
    catch let error {
        print(usage) // "Usage: ./binary <some_string> [optional_string]"
    }

### Sub commands

You can also specify subcommands. If the subcommand is matched it will run the provided handler
with a parser just for that command. If no command is matched, it will print out a usage describing
the possible commands.

    import Foundation
    import CommandLineParser

    let parser = Parser(arguments: CommandLine.arguments)

    parser.command(named: "with_int") { parser in
        let arg1 = parser.string(named: "some_string")
        let arg2 = parser.int(named: "some_int")

        try parser.parse()

        let someString = arg1.parsedValue
        let someInt = arg2.parsedValue

        // Use someString and someInt
    }

    parser.command(named: "with_optional_string") { parser in
        let arg1 = parser.string(named: "some_string")
        let arg2 = parser.optionalString(named: "optional_string")

        try parser.parse()

        let someString = arg1.parsedValue
        let optionalString = arg2.parsedValue

        // Use someString and optionalString
    }

    do {
        try parser.parse()
    }
    catch let error {
        print(usage) // "Usage: ./binary with_int|with_optional_string"
        print(usage) // "Usage: ./binary with_int <some_string> <some_int>"
        print(usage) // "Usage: ./binary with_optional_string <some_string> [optional_string]"
    }

Integration
------------

Currently only [Swift Package Manager](https://swift.org/package-manager/) is supported:

    import PackageDescription

    let package = Package(
        name: "hello",
        dependencies: [
            .Package(url: "https://github.com/drewag/command-line-parser.git", majorVersion: 1),
        ]
    )


Future Hopes/Plans
------------------

- Add support for switches

License
-------

CommandLineParser is released under the MIT license. See [LICENSE](https://raw.githubusercontent.com/drewag/text-transformers/master/License.txt) for details.
