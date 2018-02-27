//
//  libsignal_protocol_swiftTests.swift
//  libsignal-protocol-swiftTests
//
//  Created by User on 14.02.18.
//  Copyright © 2018 User. All rights reserved.
//

import XCTest
import SignalProtocol

class libsignal_protocol_swiftTests: XCTestCase {

    func testSetup() {

        guard let ownStore = setupStore(makeKeys: true) else {
            XCTFail("Could not create store")
            return
        }

        let ownAddress = SignalAddress(name: "Alice", deviceId: 0)

        let bundle: SessionPreKeyBundle
        do {
            let preKeyData = ownStore.preKeyStore.load(preKey: 1)!
            let preKey = try SessionPreKey(from: preKeyData)
            let signedPreKey = try SessionSignedPreKey(from: ownStore.signedPreKeyStore.load(signedPreKey: 1)!)

            bundle = SessionPreKeyBundle(
                registrationId: ownStore.identityKeyStore.localRegistrationId()!,
                deviceId: ownAddress.deviceId,
                preKeyId: preKey.id,
                preKey: preKey.keyPair.publicKey,
                signedPreKeyId: signedPreKey.id,
                signedPreKey: signedPreKey.keyPair.publicKey,
                signature: signedPreKey.signature,
                identityKey: ownStore.identityKeyStore.identityKeyPair()!.publicKey)
        } catch {
            XCTFail("Could not create pre key bundle: \(error)")
            return
        }

        guard let remoteStore = setupStore(makeKeys: false) else {
            XCTFail("Could not create remote store")
            return
        }

        print("Processing bundle...")

        do {
            try SessionBuilder(for: ownAddress, in: remoteStore).process(preKeyBundle: bundle)
        } catch {
            XCTFail("Could not process pre key bundle")
            return
        }

        let message = "Some text".data(using: .utf8)!

        print("Create cipher...")

        let remoteSessionCipher = SessionCipher(for: ownAddress, in: remoteStore)

        print("Encrypting message...")

        let encryptedMessage: CiphertextMessage
        do {
            encryptedMessage = try remoteSessionCipher.encrypt(message)
        } catch {
            XCTFail("Could not encrypt message")
            return
        }

        let remoteAddress = SignalAddress(name: "Bob", deviceId: 0)
        let ownSessionCipher = SessionCipher(for: remoteAddress, in: ownStore)

        print("Decrypting message...")

        let decryptedMessage: Data
        do {
            decryptedMessage = try ownSessionCipher.decrypt(message: encryptedMessage)
        } catch {
            XCTFail("Could not decrypt message: \(error)")
            return
        }

        XCTAssert(decryptedMessage == message, "Invalid decrypted text")
    }
}
