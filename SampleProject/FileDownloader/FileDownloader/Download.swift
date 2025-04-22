//
//  Download.swift
//  FileDownloader
//
//  Created by Vinícius on 22/04/25.
//

import DownloadManager
import Foundation

struct Download: Identifiable {
    let url: URL
    var status: DownloadStatus?

    init(url: URL, status: DownloadStatus) {
        self.url = url
        self.status = status
    }

    init(url: URL) {
        self.url = url
        self.status = nil
    }

    var id: String { url.absoluteString }

    var name: String {
        url.lastPathComponent.isEmpty
            ? url.absoluteString
            : url.lastPathComponent
    }
}

internal enum Sample {
    static let urls: [URL] = [
        URL(string: "https://sample-files.com/downloads/documents/pdf/basic-text.pdf")!,
        URL(string: "https://sample-files.com/downloads/documents/pdf/sample-report.pdf")!,
        URL(string: "https://sample-files.com/downloads/documents/pdf/image-doc.pdf")!,
        URL(string: "https://sample-files.com/downloads/documents/pdf/large-doc.pdf")!,
        URL(string: "https://sample-files.com/downloads/documents/pdf/fake-doc.pdf")!
    ]

    static func download(status: DownloadStatus) -> Download {
        Download(url: urls.first!, status: status)
    }
}
