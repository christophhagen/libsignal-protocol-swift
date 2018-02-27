//
//  TestPreKeyStore.swift
//  libsignal-protocol-swiftTests
//
//  Created by User on 16.02.18.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import SignalProtocol

class TestPreKeyStore: PreKeyStore {

    var keys = [UInt32 : Data]()

    func load(preKey: UInt32) -> Data? {
        return keys[preKey]
    }

    func store(preKey: Data, for id: UInt32) -> Bool {
        keys[id] = preKey
        return true
    }

    func contains(preKey: UInt32) -> Bool {
        return keys[preKey] != nil
    }

    func remove(preKey: UInt32) -> Bool {
        keys[preKey] = nil
        return true
    }
}
