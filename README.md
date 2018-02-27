# Overview

This is a wrapper framework to use [libsignal-protocol-c](https://github.com/signalapp/libsignal-protocol-c) in Swift projects,
which is a ratcheting forward secrecy protocol that works in synchronous and asynchronous messaging
environments.

## Installation

So far, integration of the framework into other projects is not working through Cocoapods. I'm working on some unresolved errors regarding missing modules.

It should be possible to download the framework and add it to an existing Xcode workspace.

## Library initialization

In contrast to `libsignal-protocol-c` there is no need to initialize a global
context or do any other setup before usage. `libsignal-protocol-swift` uses
the built-in `CommonCrypto` library for cryptographic functions. Simply:

````swift
import SignalProtocol
````

## Client install time

At install time, a `libsignal-protocol-swift` client needs to generate its identity keys,
registration id, and prekeys.

```swift
let identityKeyPair = Signal.generateIdentityKeyPair()
let registrationId = Signal.generateRegistrationId()
let preKeys = Signal.generatePreKeys(start: 1, count: 10)
let signedPreKey = Signal.generate(signedPreKey: 1, identity: identityKeyPair, timestamp: 0)

/* Store identityKeyPair somewhere durable and safe. */
/* Store registrationId somewhere durable and safe. */

/* Store pre keys in the pre key store, and */
/* Store signed pre key in the signed pre key store. */

/* Upload public identity key, public pre keys and public signed pre key to the server */
```

The above example is simplified for the sake of clarity.

## Building sessions and encrypting/decrypting messages

A `libsignal-protocol-swift` client needs to implement four data store delegates:
`IdentityKeyStore`, `PreKeyStore`,
`SignedPreKeyStore`, and `SessionStore`.
These will manage loading and storing of identity, prekeys, signed prekeys,
and session state.

The optional `SenderKeyStore` can be implemented for group messaging (necessary for `GroupSessionBuilder` and `GroupCipher`).

These callback interfaces are designed such that implementations should treat
all data flowing through them as opaque binary blobs. Anything necessary for
referencing that data will be provided as separate function arguments to those
callbacks.

Once the callbacks for these data stores are implemented, building a session
is fairly straightforward:

```swift
/* Create the store, and add all the delegates to it */
let store = SignalStore(
    identityStore: myIdentityStore,
    preKeyStore: myPreKeyStore,
    sessionStore: mySessionStore,
    signedPreKeyStore: mySignedPrekeyStore,
    senderKeyStore: myOptionalSenderKeyStore)
```

### Building a session with a downloaded pre key bundle

```swift
/* Instantiate a session_builder for a recipient address. */
let address = SignalAddress(name: "+14159998888", deviceId: 1)

/* Build a session with a pre key retrieved from the server. */
try SessionBuilder(for: address, in: store).process(preKeyBundle: retrievedBundle)

/* Create the session cipher and encrypt the message */
let cipher = SessionCipher(for: address, in: store)

let encryptedMessage = try cipher.encrypt(message)

/* Get the serialized content and deliver it */
deliver(encryptedMessage.data)
```

The above example is simplified for the sake of clarity. Most of these functions return errors
on failure, and those errors should be checked for in real usage.

### Building a session with a received pre key message

The other party can then build a session from the received message and decrypt the message content.

```swift
/* Create the session cipher and decrypt the serialized message */
let cipher = SessionCipher(for: address, in: store)
let decryptedMessage = try cipher.decrypt(preKeySignalMessage: receivedMessage)
```

### Encrypting in an established session

```swift
/* Create the session cipher and encrypt the message */
let cipher = SessionCipher(for: address, in: store)
let encryptedMessage = try cipher.encrypt(message)
```

### Decrypting in an established session

```swift
/* Create the session cipher and decrypt the serialized message */
let cipher = SessionCipher(for: address, in: store)
let decryptedMessage = try cipher.decrypt(signalMessage: receivedMessage)
```

## Group sessions

`libsignal-protocol-swift` provides the ability to create unidirectional messages
for a group identifier. This can be used for some group creator to update and
establish groups, where the administrator can provide group updates and other clients
can receive these messages.

### Building a group session

```swift
let groupSender = SignalSenderKeyName(groupId: "my group name",
                                      sender: SignalAddress(name: "+14150001111", deviceId: 1))

/* Create the session builder */
let builder = GroupSessionBuilder(in: myStore)

/* Create a sender key distribution message */
let distributionMessage = try builder.createSession(for: groupSender)

/* Transmit the message to the receiver */
deliver(distributionMessage.data)
```

### Building a group session from a received message

```swift
/* Create the session builder */
let builder = GroupSessionBuilder(in: myStore)

/* Process the received message */
try bobBuilder.process(senderKeyDistributionMessage: distributionMessage, from: groupSender)
```

### Encrypting in an established group session

```swift
/* Create the session cipher */
let cipher = GroupCipher(for: address, in: myStore)

/* Encrypt the message */
let encryptedMessage = try cipher.encrypt(message)
```

### Decrypting in an established group session

```swift
/* Create the session cipher */
let cipher = GroupCipher(for: address, in: myStore)

/* Decrypt the message */
let decryptedMessage = try cipher.decrypt(message)
```

## Fingerprints

It can be beneficial to compare identity fingerprints to protect against man-in-the-middle attacks.

```swift
/* Create fingerprint */
let fingerprint = try Fingerprint(iterations: 1024,
            localIdentifier: aliceAddress, localIdentity: alicePublicKey,
            remoteIdentifier: bobAddress, remoteIdentity: bobPublicKey)

/* Obtain scanned data from other device */
/* Show fingerprint.displayable */

/* Compare scanned fingerprint */
let equal = try fingerprint.matches(scannable: receivedFingerprint)
```

It's also possible to create fingerprints from several local and remote identities, e.g. in a group conversation setting.

# Legal things
## Cryptography Notice

This distribution includes cryptographic software. The country in which you currently reside may have restrictions on the import, possession, use, and/or re-export to another country, of encryption software.
BEFORE using any encryption software, please check your country's laws, regulations and policies concerning the import, possession, or use, and re-export of encryption software, to see if this is permitted.
See <http://www.wassenaar.org/> for more information.

## License
`libsignal-protocol-swift` is under the GPLv3: http://www.gnu.org/licenses/gpl-3.0.html

`libsignal-protocol-c` is copyright (2015-2016) of Open Whisper Systems, and licensed under the GPLv3.
