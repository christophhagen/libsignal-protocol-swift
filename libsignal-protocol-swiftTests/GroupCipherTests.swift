//
//  GroupCipherTests.swift
//  libsignal-protocol-swiftTests
//
//  Created by User on 19.02.18.
//  Copyright © 2018 User. All rights reserved.
//

import XCTest
import SignalProtocol

private let groupSender = SignalSenderKeyName(groupId: "nihilist history reading group",
                                              sender: SignalAddress(name: "+14150001111", deviceId: 1))

class GroupCipherTests: XCTestCase {

    func testExample() {

        guard let aliceStore = setupStore(makeKeys: false),
            let bobStore = setupStore(makeKeys: false) else {
            XCTFail("Could not create store")
            return
        }

        let aliceBuilder = GroupSessionBuilder(in: aliceStore)
        let bobBuilder = GroupSessionBuilder(in: bobStore)

        let aliceCipher = GroupCipher(for: groupSender, in: aliceStore)
        let bobCipher = GroupCipher(for: groupSender, in: bobStore)

        let distributionMessage: CiphertextMessage
        do {
            distributionMessage = try aliceBuilder.createSession(for: groupSender)
        } catch {
            XCTFail("Could not create distribution message")
            return
        }

        do {
            try bobBuilder.process(senderKeyDistributionMessage: distributionMessage, from: groupSender)
        } catch {
            XCTFail("Could not process distribution message \(error)")
            return
        }

        let message = "smert ze smert".data(using: .utf8)!
        let encryptedMessage: CiphertextMessage
        do {
            encryptedMessage = try aliceCipher.encrypt(message)
        } catch {
            XCTFail("Could no encrypt message \(error)")
            return
        }

        let decryptedMessage: Data
        do {
            decryptedMessage = try bobCipher.decrypt(encryptedMessage)
        } catch {
            XCTFail("Could no decrypt message")
            return
        }

        XCTAssert(decryptedMessage == message, "Messages not equal")
    }
}
