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
//        XCTFail("AHHHHHHHHHHHHH")

        // setup RECP stores
        guard let ownStore = setupStore(makeKeys: true) else {
            XCTFail("Could not create store")
            return
        }

        // setup RECP address
        let ownAddress = SignalAddress(name: "Alice@Alice.AliceAliceAliceAeelice", deviceId: 0)

        // create **RECP PREKEY BUNDLE**
        let bundle: SessionPreKeyBundle
        do {
            // Use prekey "1" for some reason?
//            let preKeyData = ownStore.preKeyStore.load(preKey: 1)!
            let preKeyData = ownStore.preKeyStore.load(preKey: 3)!
            let preKey = try SessionPreKey(from: preKeyData)
            // Use signed prekey "1" also for some reason?
            let signedPreKey = try SessionSignedPreKey(from: ownStore.signedPreKeyStore.load(signedPreKey: 1)!)
//            let signedPreKey = try SessionSignedPreKey(from: ownStore.signedPreKeyStore.load(signedPreKey: 6)!)

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

        // setup SENDER stores
        guard let remoteStore = setupStore(makeKeys: false) else {
            XCTFail("Could not create remote store")
            return
        }

        print("Processing bundle...")
        
        print("Contains session for address PrePKB: \(remoteStore.sessionStore.containsSession(for: ownAddress))")

        do {
            // MOCK SENDER INITIALIZES SESSION WITH RECP PREKEY BUNDLE
            print("Buidling session for \(ownAddress.name)")
            try SessionBuilder(for: ownAddress, in: remoteStore).process(preKeyBundle: bundle)
            print("Done building session")
        } catch {
            XCTFail("Could not process pre key bundle")
            return
        }
        print("Contains session for address PostPKB: \(remoteStore.sessionStore.containsSession(for: ownAddress))")
        
        print("Create cipher...")

        // SENDER creates a cipher for sender w/ their stores
        let remoteSessionCipher = SessionCipher(for: ownAddress, in: remoteStore)

        let message = "Some text".data(using: .utf8)!


        print("Encrypting message1")

        // sender encrypts message
        let encryptedMessage: CiphertextMessage
        do {
            encryptedMessage = try remoteSessionCipher.encrypt(message)
        } catch {
            print("M1 Encrypt Err: \(error)")
            XCTFail("Could not encrypt message")
            return
        }
        print("Encrypted: \(encryptedMessage.data.base64EncodedString())")
        
        // Create Address for Sender
        let remoteAddress = SignalAddress(name: "+1415246480@asdfasdfa.eeeeeeef", deviceId: 0)
        // RECP creates a session cipher for SENDER with RECP stores
        let ownSessionCipher = SessionCipher(for: remoteAddress, in: ownStore)

        
        print("Decrypting message 1")
        let decryptedMessage: Data
        do {
            decryptedMessage = try ownSessionCipher.decrypt(message: encryptedMessage)
        } catch {
            XCTFail("Could not decrypt message: \(error)")
            return
        }
        print("Encrypting message2")
        let m2 = "Message2".data(using: .utf8)!
        
        let encryptedM2 : CiphertextMessage
        do {
            encryptedM2 = try remoteSessionCipher.encrypt(m2)
        } catch {
            XCTFail("Could not encrypt message")
            return
        }

        print("Decrypting message 2")

        let decrypted2 : Data
        do {
            decrypted2 = try ownSessionCipher.decrypt(message: encryptedM2)
        } catch {
            XCTFail("Could not decrypt message: \(error)")
            return
        }
  
        
        print("Encrypign message 3")
        let m3 = "Recp Sending".data(using: .utf8)!
        let encrypt3 : CiphertextMessage
        do {
            encrypt3 = try ownSessionCipher.encrypt(m3)
        } catch {
            XCTFail("Could not encrypt message")
            return
        }
        
        print("Decrypting messgae 3")
        let decrypt3 : Data
        do {
            decrypt3 = try remoteSessionCipher.decrypt(message: encrypt3)
        } catch {
            XCTFail("Could not encrypt message")
            return
        }
        
   
        print("M1 Type: \(encryptedMessage.type)")
        print("M2 Type: \(encryptedM2.type)")
        print("M3 Type: \(encrypt3.type)")
        
        print("DecM1: \(String(data: decryptedMessage, encoding: .utf8)!)")
        print("DecM2: \(String(data: decrypted2, encoding: .utf8)!)")
        print("DecM3: \(String(data: decrypt3, encoding: .utf8)!)")

        XCTAssert(decryptedMessage == message, "Invalid decrypted text")
        XCTAssert(decrypted2 == m2, "Invalid decrypted text for m2")
        XCTAssert(decrypt3 == m3, "Invalid decrypted text for m3")

    }
    
    func testAddresses () {
        guard let ownStore = setupStore(makeKeys: true) else {
            XCTFail("Could not create store")
            return
        }
        
        guard let remoteStore = setupStore(makeKeys: false) else {
            XCTFail("Could not create remote store")
            return
        }
        
        let testNames = [ "sessions:1", "1"]
        for testName in testNames {
            let address = SignalAddress(name: testName, deviceId: 0)

            let bundle: SessionPreKeyBundle
            do {
                let preKeyData = ownStore.preKeyStore.load(preKey: 1)!
                let preKey = try SessionPreKey(from: preKeyData)
                let signedPreKey = try SessionSignedPreKey(from: ownStore.signedPreKeyStore.load(signedPreKey: 1)!)

                bundle = SessionPreKeyBundle(
                    registrationId: ownStore.identityKeyStore.localRegistrationId()!,
                    deviceId: address.deviceId,
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


            print("Processing bundle for odd address...")

            do {
                try SessionBuilder(for: address, in: remoteStore).process(preKeyBundle: bundle)
            } catch {
                XCTFail("Could not process pre key bundle")
                return
            }

            XCTAssert(remoteStore.sessionStore.containsSession(for: address), "Odd address for processed pre key bundle not in session store")
        }
    }
}
