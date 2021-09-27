//
//  SwiftASTCLI.swift
//  SwiftASTCLI
//
//  Created by Joseph Hinkle on 9/27/21.
//  Copyright © 2021 App Maker Software LLC
//

import ArgumentParser
import Foundation
import BinarySwiftAST
import BinarySwiftASTConstructor

@main
struct SwiftAST: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Parses Swift 5.5 source code into binary ast data",
        discussion: """
            Binary AST format defined by https://github.com/App-Maker-Software/BinarySwiftAST
            """)
    
    @Flag(help: "Input source code as base64 instead of text")
    var base64In = false
    
    @Flag(help: "Output base64 instead of binary")
    var base64Out = false
    
    @Flag(name: .shortAndLong, help: "Output packed ast binary format")
    var packed = false
    
    @Argument(help: "Swift source code to parse")
    var sourceCode: String
    
    func buildASTDate() throws -> Data {
        if base64In {
            let sourceCodeText = String(data: Data(base64Encoded: sourceCode)!, encoding: .utf8)!
            let data = try BinarySwiftASTConstructor.constructAST(from: sourceCodeText)
            return data
        } else {
            let data = try BinarySwiftASTConstructor.constructAST(from: sourceCode)
            return data
        }
    }

    mutating func run() throws {
        var data = try buildASTDate()
        if packed {
            data = .init(pack(.init(data))!)
        }
        if base64Out {
            print(data.base64EncodedString())
        } else {
            FileHandle.standardOutput.write(data)
        }
    }
}
