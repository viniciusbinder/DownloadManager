//
//  DownloadHandler.swift
//  DownloadManager
//
//  Created by Vinícius on 21/04/25.
//

import Foundation

final class DownloadHandler: NSObject, URLSessionDownloadDelegate {
    private let onUpdate: @Sendable (DownloadStatus) -> Void
    
    init(onUpdate: @escaping @Sendable (DownloadStatus) -> Void) {
        self.onUpdate = onUpdate
    }
    
    func urlSession(
        _ session: URLSession, downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard totalBytesExpectedToWrite > 0 else {
            onUpdate(.failed(.some(NSError(
                domain: "DownloadError",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid total bytes expected to write"]
            ))))
            return
        }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        onUpdate(.progress(progress))
    }
    
    func urlSession(
        _ session: URLSession, downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        do {
            let data = try Data(contentsOf: location)
            onUpdate(.success(data))
        } catch {
            onUpdate(.failed(error))
        }
    }
    
    func urlSession(
        _ session: URLSession, task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error {
            onUpdate(.failed(error))
        } else {
            onUpdate(.canceled)
        }
    }
}
