//
//  LineReader.swift
//  LangKit
//
//  Created by Richard Wei on 4/27/16.
//
//

import Foundation

public final class LineReader {

    // Chunk size constant
    private let chunkSize = 4096

    private let path: String
    private let encoding: NSStringEncoding
    private let lineSeparator: String
    private let fileHandle: NSFileHandle
    private let buffer: NSMutableData
    private let delimiterData: NSData

    // EOF state
    private var eof: Bool = false

    /// Initialize a LineReader with configurations
    ///
    /// - parameter fromFile:          File path
    /// - parameter lineSeparator:     Line separator (default: "\n")
    /// - parameter encoding:          File encoding (default: UTF-8)
    public required init?(fromFile path: String, lineSeparator: String = "\n",
                          encoding: NSStringEncoding = NSUTF8StringEncoding) {
        guard let handle = NSFileHandle(forReadingAtPath: path),
                  delimiterData = lineSeparator.data(using: encoding),
                  buffer = NSMutableData(capacity: chunkSize) else {
            return nil
        }
        self.path = path
        self.encoding = encoding
        self.lineSeparator = lineSeparator
        self.fileHandle = handle
        self.buffer = buffer
        self.delimiterData = delimiterData
    }

    deinit {
        self.close()
    }

    /// Close file
    func close() {
        fileHandle.closeFile()
    }

    /// Go to the beginning of the file
    public func rewind() {
        fileHandle.seek(toFileOffset: 0)
        buffer.length = 0
        eof = false
    }

}

extension LineReader : IteratorProtocol {

    public typealias Element = String

    /// Next line
    ///
    /// - returns: Line
    public func next() -> Element? {
        if eof {
            return nil
        }

        var range = buffer.range(of: delimiterData, options: [], in: NSMakeRange(0, buffer.length))

        while range.location == NSNotFound {
            let data = fileHandle.readData(ofLength: chunkSize)
            guard data.length > 0 else {
                eof = true
                return nil
            }
            buffer.append(data)
            range = buffer.range(of: delimiterData, options: [], in: NSMakeRange(0, buffer.length))
        }

        let line = String(data: buffer.subdata(with: NSMakeRange(0, range.location)), encoding: encoding)
        buffer.replaceBytes(in: NSMakeRange(0, range.location + range.length), withBytes: nil, length: 0)

        return line
    }

}

extension LineReader : Sequence {

    public typealias Iterator = LineReader

    /// Make line iterator
    ///
    /// - returns: Iterator
    public func makeIterator() -> Iterator {
        self.rewind()
        return self
    }
    
}