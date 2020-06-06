// Src: https://github.com/zssz/BerkananFoundation
//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation

/// A type that can convert itself into and out of a little endian byte buffer.
public protocol DataRepresentable {

  /// Initialize an instance from a little endian byte buffer.
  ///
  /// - Parameter dataRepresentation: A little endian byte buffer.
  init<D>(dataRepresentation: D) throws where D: ContiguousBytes

  /// Returns a little endian byte buffer.
  var dataRepresentation: Data { get }
}

extension DataRepresentable {

  public init<D>(dataRepresentation: D) throws where D: ContiguousBytes {
    self = try dataRepresentation.withUnsafeBytes {
      guard $0.count == MemoryLayout<Self>.size,
        let baseAddress = $0.baseAddress else {
          throw CocoaError(.coderInvalidValue)
      }
      return baseAddress.bindMemory(to: Self.self, capacity: 1).pointee
    }
  }

  public var dataRepresentation: Data {
    var value = self
    return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
  }
}
