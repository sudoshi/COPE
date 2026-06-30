import Foundation

/// Presentation model for the You / Profile tab (build bible §6.11).
public struct ProfileModel: Sendable, Equatable {
    public var name: String
    public var org: String
    public var privacyBody: String
    public var faceIDEnabled: Bool
    public var versionFooter: String

    public init(name: String, org: String, privacyBody: String, faceIDEnabled: Bool, versionFooter: String) {
        self.name = name
        self.org = org
        self.privacyBody = privacyBody
        self.faceIDEnabled = faceIDEnabled
        self.versionFooter = versionFooter
    }

    public var avatarInitial: String { String(name.first ?? "·") }
}

public extension ProfileModel {
    static let sample = ProfileModel(
        name: "Maya Thompson",
        org: "Bayview Behavioral Health",
        privacyBody: "Your journals and messages are encrypted. We never sell or advertise on your data — ever.",
        faceIDEnabled: true,
        versionFooter: "COPE v1.1 · 988 Suicide & Crisis Lifeline built in"
    )
}
