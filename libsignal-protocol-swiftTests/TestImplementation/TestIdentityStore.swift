//
//  TestIdentityStore.swift
//  libsignal-protocol-swiftTests
//
//  Created by User on 16.02.18.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import SignalProtocol

class TestIdentityStore: IdentityKeyStore {

    var keys = [SignalAddress : Data]()

    var identity: KeyPair?

    var registrationId: UInt32?

    func identityKeyPair() -> KeyPair? {
        return identity
    }

    func localRegistrationId() -> UInt32? {
        return registrationId
    }

    func save(identity: Data?, for address: SignalAddress) -> Bool {
        print("Saving idneitty for \(address.name)")
        keys[address] = identity
        return true
    }

    func isTrusted(identity: Data, for address: SignalAddress) -> Bool? {
        print("Checking Identity for: \(address.name)")
        guard let savedIdentity = keys[address] else {
            return true
        }
        return savedIdentity == identity
    }
}
