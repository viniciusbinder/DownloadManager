//
//  DownloadManager.swift
//  DownloadManager
//
//  Created by Vinícius on 17/04/25.
//

import Foundation

public protocol DownloadManager: Sendable {
    func startDownload(from url: URL) async
    func cancelDownload(for url: URL) async
    func status(of url: URL) async -> DownloadStatus?
    func stream(for url: URL) async -> AsyncStream<DownloadStatus>?
}

public extension DownloadManager where Self == DefaultDownloadManager {
    static var `default`: DefaultDownloadManager { .init() }
}

public actor DefaultDownloadManager: DownloadManager {
    private var tasks: [URL: URLSessionDownloadTask] = [:]
    private var latestStatus: [URL: DownloadStatus] = [:]
    private var continuations: [URL: [AsyncStream<DownloadStatus>.Continuation]] = [:]
    
    private let delegateQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        return queue
    }()
    
    public func startDownload(from url: URL) async {
        guard tasks[url] == nil else { return }
        
        let handler = DownloadHandler { [weak self] status in
            guard let self else { return }
            Task {
                switch status {
                case .progress(let progress):
                    await broadcast(.progress(progress), for: url)
                case .success(let data):
                    await broadcast(.success(data), for: url)
                    await clear(url)
                case .failed(let error):
                    await broadcast(.failed(error), for: url)
                    await clear(url)
                default:
                    break
                }
            }
        }
                
        let session = URLSession(configuration: .default, delegate: handler, delegateQueue: delegateQueue)
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
        
        tasks[url] = downloadTask
        latestStatus[url] = .requested
        
        session.finishTasksAndInvalidate()
    }
    
    public func cancelDownload(for url: URL) async {
        broadcast(.canceled, for: url)
        tasks[url]?.cancel()
        tasks[url] = nil
    }
    
    public func status(of url: URL) async -> DownloadStatus? {
        latestStatus[url]
    }
    
    public func stream(for url: URL) async -> AsyncStream<DownloadStatus>? {
        guard tasks[url] != nil else { return nil }
        
        return AsyncStream { continuation in
            continuations[url, default: []].append(continuation)
            
            if let current = latestStatus[url] {
                continuation.yield(current)
            }
            
            continuation.onTermination = { [weak self] _ in
                Task { await self?.remove(url) }
            }
        }
    }
    
    private func broadcast(_ status: DownloadStatus, for url: URL) {
        latestStatus[url] = status
        
        for continuation in continuations[url] ?? [] {
            continuation.yield(status)
        }
        
        if status.isFinished {
            for continuation in continuations[url] ?? [] {
                continuation.finish()
            }
            continuations[url] = nil
        }
    }
    
    private func remove(_ url: URL) {
        continuations[url] = nil
    }
    
    private func clear(_ url: URL) {
        tasks[url] = nil
    }
}
