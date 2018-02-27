//
//  TestHelper.swift
//  libsignal-protocol-swiftTests
//
//  Created by User on 19.02.18.
//  Copyright © 2018 User. All rights reserved.
//

import SignalProtocol

func setupStore(makeKeys: Bool) -> SignalStore? {

    let store: SignalStore
    do {
        store = try SignalStore(
            identityKeyStore: TestIdentityStore(),
            preKeyStore: TestPreKeyStore(),
            sessionStore: TestSessionStore(),
            signedPreKeyStore: TestSignedPrekeyStore(),
            senderKeyStore: TestSenderKeyStore())
    } catch {
        print("Failed to create store: \(error)")
        return nil
    }

    let identity: KeyPair
    do { identity = try Signal.generateIdentityKeyPair()
    } catch {
        print("Could not create identity key: \(error)")
        return nil
    }

    let registrationId: UInt32
    do {
        registrationId = try Signal.generateRegistrationId()
    } catch {
        print("Could not create registration id: \(error)")
        return nil
    }

    // Store identity key pair and registration id
    (store.identityKeyStore as! TestIdentityStore).identity = identity
    (store.identityKeyStore as! TestIdentityStore).registrationId = registrationId

    if makeKeys {
        let preKeys: [SessionPreKey]
        do {
            preKeys = try Signal.generatePreKeys(start: 1, count: 100)
        } catch {
            print("Could not create pre keys: \(error)")
            return nil
        }

        // Store keys
        for key in preKeys {
            do {
                let stored = store.preKeyStore.store(preKey: try key.data(), for: key.id)
                guard stored else {
                    print("Could not store pre key")
                    return nil
                }
            } catch {
                print("Could not serialize pre key: \(error)")
                return nil
            }
        }

        let signedPreKey: SessionSignedPreKey
        do {
            signedPreKey = try Signal.generate(signedPreKey: 1, identity: identity, timestamp: 0)
        } catch {
            print("Could not create signed pre key: \(error)")
            return nil
        }

        // Store signed pre key
        do {
            (store.signedPreKeyStore as! TestSignedPrekeyStore).keys[signedPreKey.id] = try signedPreKey.data()
        } catch {
            print("Could not serialize signed pre key: \(error)")
        }
    }
    /// Setup finished
    return store
}
