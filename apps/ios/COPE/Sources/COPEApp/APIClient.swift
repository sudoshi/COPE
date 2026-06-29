import Foundation

struct HealthResponse: Decodable, Equatable {
    let status: String
}

final class APIClient {
    private let baseURL: URL
    private let session: URLSession

    init(
        baseURL: URL = APIClient.defaultBaseURL(),
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func health() async throws -> HealthResponse {
        let url = baseURL.appending(path: "health")
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw APIClientError.unexpectedStatus
        }

        return try JSONDecoder().decode(HealthResponse.self, from: data)
    }

    private static func defaultBaseURL() -> URL {
        if let value = Bundle.main.object(forInfoDictionaryKey: "COPEAPIBaseURL") as? String,
           let url = URL(string: value) {
            return url
        }
        return URL(string: "http://localhost:3000")!
    }
}

enum APIClientError: Error, Equatable {
    case unexpectedStatus
}
