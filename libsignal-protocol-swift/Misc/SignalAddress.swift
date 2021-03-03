//
//  SignalAddress.swift
//  libsignal-protocol-swift iOS
//
//  Created by User on 15.02.18.
//  Copyright © 2018 User. All rights reserved.
//

import Foundation
import SignalModule

/**
 A SignalAddress identifies the device of a user.
 */
public final class SignalAddress {

    /// The name or identifier of the user
    public let name: String

    /// The id of the user's device
    public let deviceId: Int32

    /// Internal pointer to the C name
    private let namePointer: UnsafeMutablePointer<Int8>

    /// Internal pointer to the C struct
    private let address: UnsafeMutablePointer<signal_protocol_address>

    var signalAddress: UnsafePointer<signal_protocol_address> {
        return UnsafePointer(address)
    }

    /**
     Create a signal address.
     - parameter name: The name/id of the user
     - parameter deviceId: The id of the device
     */
    public init(name: String, deviceId: Int32) {
        self.name = name
        self.deviceId = deviceId
        let count = name.utf8.count
        // From: https://github.com/christophhagen/libsignal-protocol-swift/issues/2
        self.namePointer = UnsafeMutablePointer<Int8>(mutating: (name as NSString).utf8String!)
        self.address = UnsafeMutablePointer<signal_protocol_address>.allocate(capacity: 1)
        address.pointee = signal_protocol_address(name: namePointer, name_len: count, device_id: deviceId)
    }

    convenience init?(from address: UnsafePointer<signal_protocol_address>?) {
        guard let add = address?.pointee else {
            return nil
        }
        self.init(from: add)
    }

    convenience init?(from address: signal_protocol_address) {
        guard let namePtr = address.name else {
            return nil
        }
        self.init(name: String(cString: namePtr), deviceId: address.device_id)
    }

    deinit {
        signalAddress.deallocate()
    }
}

extension SignalAddress: Equatable {

    /**
     Compare two signal addresses for equality
     - parameter lhs: The first address
     - parameter rhs: The second address
     - returns: `true` if the addresses match
     */
    public static func == (lhs: SignalAddress, rhs: SignalAddress) -> Bool {
        return lhs.name == rhs.name && lhs.deviceId == rhs.deviceId
    }
}

extension SignalAddress: Hashable {

    /// A hash of the address
    public var hashValue: Int {
        return name.hashValue &+ deviceId.hashValue
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(deviceId)
    }
}

