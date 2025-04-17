import Foundation

protocol DownloadManager: Sendable {
    func startDownload(from url: URL) async
    func cancelDownload(for url: URL) async
    func status(of url: URL) async -> DownloadStatus?
    func stream(for url: URL) async -> AsyncStream<DownloadStatus>?
}

extension DownloadManager where Self == DefaultDownloadManager {
    static var `default`: DefaultDownloadManager { .init() }
}

actor DefaultDownloadManager: DownloadManager {
    func startDownload(from url: URL) async {
        // TODO: Start download and store result internally
    }

    func cancelDownload(for url: URL) async {
        // TODO: Cancel ongoing download
    }

    func status(of url: URL) async -> DownloadStatus? {
        // TODO: Return current download status
        return nil
    }

    func stream(for url: URL) async -> AsyncStream<DownloadStatus>? {
        // TODO: Publish ongoing progress updates
        return nil
    }
}
