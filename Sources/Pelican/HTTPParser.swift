import Foundation

public enum HTTPParserError: Error, Equatable {
    case malformedRequestLine
    case unsupportedMethod(String)
    case malformedHeader
    case missingHeaderTerminator
    case bodyTooLarge(limit: Int)
}

public enum HTTPParseResult {
    case needMoreData
    case complete(HTTPRequest, consumed: Int)
}

public enum HTTPParser {
    public static let defaultBodyLimit = 10 * 1024 * 1024  // 10 MB

    public static func parse(buffer: Data, bodyLimit: Int = defaultBodyLimit) throws -> HTTPParseResult {
        guard let headerEndRange = buffer.range(of: Data("\r\n\r\n".utf8)) else {
            return .needMoreData
        }

        let headerData = buffer.subdata(in: 0..<headerEndRange.lowerBound)
        guard let headerString = String(data: headerData, encoding: .utf8) else {
            throw HTTPParserError.malformedHeader
        }

        let lines = headerString.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            throw HTTPParserError.malformedRequestLine
        }

        let requestParts = requestLine.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: false).map(String.init)
        guard requestParts.count == 3 else {
            throw HTTPParserError.malformedRequestLine
        }

        guard let method = HTTPMethod(rawToken: requestParts[0]) else {
            throw HTTPParserError.unsupportedMethod(requestParts[0])
        }

        let target = requestParts[1]
        let (path, query) = splitTarget(target)

        var headers = HTTPHeaders()
        for line in lines.dropFirst() where !line.isEmpty {
            guard let colonIndex = line.firstIndex(of: ":") else {
                throw HTTPParserError.malformedHeader
            }
            let name = String(line[..<colonIndex])
            let valueStart = line.index(after: colonIndex)
            let value = String(line[valueStart...]).trimmingCharacters(in: .whitespaces)
            headers.add(name: name, value: value)
        }

        let bodyStart = headerEndRange.upperBound
        let contentLength = Int(headers.first(name: "Content-Length") ?? "0") ?? 0

        if contentLength > bodyLimit {
            throw HTTPParserError.bodyTooLarge(limit: bodyLimit)
        }

        let available = buffer.count - bodyStart
        if available < contentLength {
            return .needMoreData
        }

        let body = contentLength > 0
            ? buffer.subdata(in: bodyStart..<(bodyStart + contentLength))
            : Data()

        let request = HTTPRequest(
            method: method,
            path: path,
            query: query,
            headers: headers,
            body: body
        )

        return .complete(request, consumed: bodyStart + contentLength)
    }

    private static func splitTarget(_ target: String) -> (path: String, query: [String: String]) {
        guard let questionMark = target.firstIndex(of: "?") else {
            return (percentDecode(target), [:])
        }
        let path = String(target[..<questionMark])
        let queryString = String(target[target.index(after: questionMark)...])
        var query: [String: String] = [:]
        for pair in queryString.split(separator: "&") {
            let parts = pair.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            if parts.count == 2 {
                query[percentDecode(String(parts[0]))] = percentDecode(String(parts[1]))
            } else if parts.count == 1 {
                query[percentDecode(String(parts[0]))] = ""
            }
        }
        return (percentDecode(path), query)
    }

    private static func percentDecode(_ s: String) -> String {
        s.removingPercentEncoding ?? s
    }
}
