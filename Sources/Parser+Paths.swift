//
//  Parser+Complex.swift
//  CommandLineParser
//
//  Created by Andrew Wagner on 5/24/19.
//

import Foundation

extension Parser {
    public func existingFile(named: String) -> ParsePromise<String> {
        let promise = self.string(named: named)
        promise.validate = { value in
            var isDirectory = ObjCBool(false)
            guard FileManager.default.fileExists(atPath: value, isDirectory: &isDirectory) else {
                return "the file doesn't exist"
            }
            guard !isDirectory.boolValue else {
                return "that is a directory not a file"
            }
            return nil
        }
        return promise
    }

    public func optionalExistingFile(named: String) -> OptionalParsePromise<String> {
        let promise = self.optionalString(named: named)
        promise.validate = { value in
            var isDirectory = ObjCBool(false)
            guard FileManager.default.fileExists(atPath: value, isDirectory: &isDirectory) else {
                return "the file doesn't exist"
            }
            guard !isDirectory.boolValue else {
                return "that is a directory not a file"
            }
            return nil
        }
        return promise
    }

    public func existingDirectory(named: String) -> ParsePromise<String> {
        let promise = self.string(named: named)
        promise.validate = { value in
            var isDirectory = ObjCBool(false)
            guard FileManager.default.fileExists(atPath: value, isDirectory: &isDirectory) else {
                return "the directory doesn't exist"
            }
            guard isDirectory.boolValue else {
                return "that is a file not a directory"
            }
            return nil
        }
        return promise
    }

    public func optionalExistingDirectory(named: String) -> OptionalParsePromise<String> {
        let promise = self.optionalString(named: named)
        promise.validate = { value in
            var isDirectory = ObjCBool(false)
            guard FileManager.default.fileExists(atPath: value, isDirectory: &isDirectory) else {
                return "the directory doesn't exist"
            }
            guard isDirectory.boolValue else {
                return "that is a file not a directory"
            }
            return nil
        }
        return promise
    }
}
