//
//  TestSenderKeyStore.swift
//  libsignal-protocol-swiftTests
//
//  Created by User on 16.02.18.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import SignalProtocol

final class TestSenderKeyStore: SenderKeyStore {

    var keys = [SignalSenderKeyName: Data]()

    var records = [SignalSenderKeyName: Data]()

    func store(senderKey: Data, for address: SignalSenderKeyName, userRecord: Data?) -> Bool {
        keys[address] = senderKey
        records[address] = userRecord
        return true
    }

    func loadSenderKey(for address: SignalSenderKeyName) -> (senderKey: Data, userRecord: Data?)? {
        guard let key = keys[address] else {
            return nil
        }
        return (key, records[address])
    }
}
