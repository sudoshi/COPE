import Foundation

struct AppConfiguration: Equatable {
    let apiBaseURL: URL

    static var current: AppConfiguration {
        if let value = Bundle.main.object(forInfoDictionaryKey: "COPEAPIBaseURL") as? String,
           let url = URL(string: value),
           !value.isEmpty {
            return AppConfiguration(apiBaseURL: url.removingTrailingSlash())
        }

        return AppConfiguration(apiBaseURL: URL(string: "http://localhost:3000")!)
    }
}

private extension URL {
    func removingTrailingSlash() -> URL {
        var value = absoluteString
        while value.count > 1, value.hasSuffix("/") {
            value.removeLast()
        }
        return URL(string: value) ?? self
    }
}
