import XCTest
import CommandLineParser

class command_line_parserTests: XCTestCase {
    func testSimpleArguments() throws {
        let parser = Parser(arguments: ["command", "value1", "2"])

        let arg1 = parser.string(named: "argument 1")
        let arg2 = parser.int(named: "argument 2")

        try parser.parse()

        XCTAssertEqual(arg1.parsedValue, "value1")
        XCTAssertEqual(arg2.parsedValue, 2)
    }

    func testUsageGeneration() {
        let parser = Parser(arguments: ["command", "value1"])

        var usage = ""

        let _ = parser.string(named: "argument 1")
        let _ = parser.string(named: "argument 2")
        let _ = parser.optionalString(named: "argument 3")

        do {
            try parser.parse()
        }
        catch let error {
            usage = "\(error)"
        }

        XCTAssertEqual(usage, "Usage: command <argument 1> <argument 2> [argument 3]\n")
    }

    func testCommandUsageGeneration() {
        let parser = Parser(arguments: ["command"])

        var usage = ""

        parser.command(named: "command1") { parser in
            let _ = parser.string(named: "argument 1")
            let _ = parser.string(named: "argument 2")
            let _ = parser.optionalString(named: "argument 3")

            try parser.parse()
        }
        parser.command(named: "command2") { parser in
            let _ = parser.string(named: "argument 3")
            let _ = parser.string(named: "argument 4")
            let _ = parser.optionalString(named: "argument 5")

            try parser.parse()
        }
        do {
            try parser.parse()
        }
        catch let error {
            usage = "\(error)"
        }

        XCTAssertEqual(usage, "Usage: command <command>\n\nThe following commands are available:\n\n    command1    \n    command2    \n")
    }

    func testSpecificCommandUsageGeneration() {
        let parser = Parser(arguments: ["command", "command1"])

        var usage = ""

        parser.command(named: "command1") { parser in
            let _ = parser.string(named: "argument 1")
            let _ = parser.string(named: "argument 2")
            let _ = parser.optionalString(named: "argument 3")

            try parser.parse()
        }
        parser.command(named: "command2") { parser in
            let _ = parser.string(named: "argument 3")
            let _ = parser.string(named: "argument 4")
            let _ = parser.optionalString(named: "argument 5")

            try parser.parse()
        }
        do {
            try parser.parse()
        }
        catch let error {
            usage = "\(error)"
        }

        XCTAssertEqual(usage, "Usage: command command1 <argument 1> <argument 2> [argument 3]\n")
    }

    func testUsedOptionalArgument() throws {
        let parser = Parser(arguments: ["command", "value1", "value2", "3"])

        let arg1 = parser.string(named: "argument 1")
        let arg2 = parser.optionalString(named: "argument 2")
        let arg3 = parser.optionalInt(named: "argument 3")


        try parser.parse()

        XCTAssertEqual(arg1.parsedValue, "value1")
        XCTAssertEqual(arg2.parsedValue, "value2")
        XCTAssertEqual(arg3.parsedValue, 3)
    }

    func testUnusedOptionalArgument() throws {
        let parser = Parser(arguments: ["command", "value1"])

        let arg1 = parser.string(named: "argument 1")
        let arg2 = parser.optionalString(named: "argument 2")
        let arg3 = parser.optionalInt(named: "argument 3")

        try parser.parse()

        XCTAssertEqual(arg1.parsedValue, "value1")
        XCTAssertNil(arg2.parsedValue)
        XCTAssertNil(arg3.parsedValue)
    }

    static var allTests : [(String, (command_line_parserTests) -> () throws -> Void)] {
        return [
            ("testSimpleArguments", testSimpleArguments),
            ("testUsageGeneration", testUsageGeneration),
            ("testUsedOptionalArgument", testUsedOptionalArgument),
        ]
    }
}
