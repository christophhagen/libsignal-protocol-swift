//
//  TestSessionStore.swift
//  libsignal-protocol-swiftTests
//
//  Created by User on 16.02.18.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import SignalProtocol

final class TestSessionStore: SessionStore {

    private var sessions = [SignalAddress : Data]()

    private var records = [SignalAddress : Data]()

    func loadSession(for address: SignalAddress) -> (session: Data, userRecord: Data?)? {
        guard let session = sessions[address] else {
            return nil
        }
        return (session, records[address])
    }

    func subDeviceSessions(for name: String) -> [Int32]? {
        return sessions.keys.filter({ $0.name == name }).map { $0.deviceId }
    }

    func store(session: Data, for address: SignalAddress, userRecord: Data?) -> Bool {
        sessions[address] = session
        records[address] = userRecord
        return true
    }

    func containsSession(for address: SignalAddress) -> Bool {
        return sessions[address] != nil
    }

    func deleteSession(for address: SignalAddress) -> Bool? {
        sessions[address] = nil
        records[address] = nil
        return true
    }

    func deleteAllSessions(for name: String) -> Int? {
        let matches = sessions.keys.filter({ $0.name == name })
        for item in matches {
            sessions[item] = nil
        }
        return matches.count
    }
}
