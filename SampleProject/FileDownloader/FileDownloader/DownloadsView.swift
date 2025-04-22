//
//  DownloadsView.swift
//  FileDownloader
//
//  Created by Vinícius on 22/04/25.
//

import SwiftUI

struct DownloadsView: View {
    typealias ViewModel = DownloadsViewModel

    @State private var viewModel: ViewModel

    init(viewModel: @autoclosure @escaping () -> ViewModel) {
        self._viewModel = State(wrappedValue: viewModel())
    }

    var body: some View {
        List {
            downloads
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Download All") {
                    viewModel.startAllDownloads()
                }
            }
        }
        .fullScreenCover(item: $viewModel.presentedDownload) {
            if case .success(let data) = $0.status {
                PDFViewer(data: data)
            }
        }
    }

    @ViewBuilder
    var downloads: some View {
        ForEach(viewModel.downloads) { download in
            DownloadCell(download: download)
                .onTapGesture {
                    if case .success = download.status {
                        viewModel.present(download: download)
                    } else {
                        viewModel.start(download: download)
                    }
                }
                .swipeActions {
                    actions(for: download)
                }
        }
    }

    @ViewBuilder
    func actions(for download: Download) -> some View {
        let status = download.status

        if status?.isFinished == false {
            Button(role: .cancel) {
                viewModel.cancel(download: download)
            } label: {
                Label("Cancel", systemImage: "xmark")
            }
        }

        if status == nil || status?.isFinished == true {
            Button(role: .destructive) {
                viewModel.delete(download: download)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    DownloadsView(viewModel: .init(urls: Sample.urls))
}
