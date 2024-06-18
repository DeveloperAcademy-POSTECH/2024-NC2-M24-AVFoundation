//
//  AsynceSequence.swift
//  LiveFourCut
//
//  Created by Developer on 6/18/24.
//

import Foundation
extension Sequence{
    func asyncMap<T>(_ transform:(Element) async throws -> T) async rethrows ->[T]{
        var values = [T]()
        for element in self{
            try await values.append(transform(element))
        }
        return values
    }
}
