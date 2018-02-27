//
//  FingerprintTests.swift
//  libsignal-protocol-swiftTests
//
//  Created by User on 19.02.18.
//  Copyright © 2018 User. All rights reserved.
//

import XCTest
import SignalProtocol

class FingerprintTests: XCTestCase {

    func testFingerprint() {

        let alice = try! Signal.generateIdentityKeyPair().publicKey
        let bob = try! Signal.generateIdentityKeyPair().publicKey

        let aliceAddress = "+14152222222"
        let bobAddress = "+14153333333"

        let iterations = 1024

        let aliceFingerprint: Fingerprint
        do {
            aliceFingerprint = try Fingerprint(
            iterations: iterations,
            localIdentifier: aliceAddress, localIdentity: alice,
            remoteIdentifier: bobAddress, remoteIdentity: bob)
        } catch {
            XCTFail("Could not create fingerprint for alice: \(error)")
            return
        }

        let bobFingerprint: Fingerprint
        do {
            bobFingerprint = try Fingerprint(
                iterations: iterations,
                localIdentifier: bobAddress, localIdentity: bob,
                remoteIdentifier: aliceAddress, remoteIdentity: alice)
        } catch {
            XCTFail("Could not create fingerprint for bob: \(error)")
            return
        }

        do {
            let equal = try aliceFingerprint.matches(scannable: bobFingerprint)
            XCTAssert(equal, "Fingerprints don't match")
        } catch {
            XCTFail("Could not match fingerprints: \(error)")
            return
        }
    }

    func testFingerprintLists() {
        let aliceKeys = [try! Signal.generateIdentityKeyPair().publicKey,
                         try! Signal.generateIdentityKeyPair().publicKey,
                         try! Signal.generateIdentityKeyPair().publicKey]

        let bobKeys = [try! Signal.generateIdentityKeyPair().publicKey,
                       try! Signal.generateIdentityKeyPair().publicKey,
                       try! Signal.generateIdentityKeyPair().publicKey]

        let aliceAddress = "+14152222222"
        let bobAddress = "+14153333333"

        let iterations = 1024

        let aliceFingerprint: Fingerprint
        do {
            aliceFingerprint = try Fingerprint(
                iterations: iterations,
                localIdentifier: aliceAddress, localIdentityList: aliceKeys,
                remoteIdentifier: bobAddress, remoteIdentityList: bobKeys)
        } catch {
            XCTFail("Could not create fingerprint for alice: \(error)")
            return
        }

        let bobFingerprint: Fingerprint
        do {
            bobFingerprint = try Fingerprint(
                iterations: iterations,
                localIdentifier: bobAddress, localIdentityList: bobKeys,
                remoteIdentifier: aliceAddress, remoteIdentityList: aliceKeys)
        } catch {
            XCTFail("Could not create fingerprint for bob: \(error)")
            return
        }

        do {
            let equal = try aliceFingerprint.matches(scannable: bobFingerprint)
            XCTAssert(equal, "Fingerprints don't match")
            let equal2 = try bobFingerprint.matches(scannable: aliceFingerprint)
            XCTAssert(equal2, "Fingerprints don't match")
        } catch {
            XCTFail("Could not match fingerprints: \(error)")
            return
        }
    }
}
