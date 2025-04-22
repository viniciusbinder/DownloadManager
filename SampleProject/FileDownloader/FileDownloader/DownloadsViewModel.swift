//
//  DownloadsViewModel.swift
//  FileDownloader
//
//  Created by Vinícius on 22/04/25.
//

import DownloadManager
import SwiftUI

@Observable
@MainActor
final class DownloadsViewModel {
    private(set) var downloads: [Download] = []
    private let manager: DownloadManager

    init(urls: [URL], manager: DownloadManager = .default) {
        self.downloads = urls.map(Download.init)
        self.manager = manager
    }

    func start(download: Download) {
        Task {
            await manager.startDownload(from: download.url)
            await watch(download: download)
        }
    }

    func cancel(download: Download) {
        Task {
            await manager.cancelDownload(for: download.url)
        }
    }

    func delete(download: Download) {
        Task {
            await manager.cancelDownload(for: download.url)
            downloads.removeAll { $0.id == download.id }
        }
    }

    private func watch(download: Download) async {
        guard let stream = await manager.stream(for: download.url) else {
            return
        }
        for await status in stream {
            update(download: download, status: status)
        }
    }

    private func update(download: Download, status: DownloadStatus) {
        if let index = downloads.firstIndex(where: { $0.id == download.id }) {
            withAnimation {
                downloads[index].status = status
            }
        }
    }
}
