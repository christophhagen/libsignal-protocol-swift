//
//  TestSignedPrekeyStore.swift
//  libsignal-protocol-swiftTests
//
//  Created by User on 16.02.18.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import SignalProtocol

final class TestSignedPrekeyStore: SignedPreKeyStore {

    var keys = [UInt32 : Data]()

    func load(signedPreKey: UInt32) -> Data? {
        return keys[signedPreKey]
    }

    func store(signedPreKey: Data, for id: UInt32) -> Bool {
        keys[id] = signedPreKey
        return true
    }

    func contains(signedPreKey: UInt32) -> Bool {
        return keys[signedPreKey] != nil
    }

    func remove(signedPreKey: UInt32) -> Bool {
        keys[signedPreKey] = nil
        return true
    }
}
