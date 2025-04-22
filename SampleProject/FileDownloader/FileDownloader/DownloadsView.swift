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
            Section {
                ForEach(viewModel.downloads) { download in
                    DownloadCell(download: download)
                        .onTapGesture {
                            startDownload(download)
                        }
                        .swipeActions {
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
            } header: {
                Button(action: startAll) {
                    Text("Download All")
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private func startDownload(_ download: Download) {
        switch download.status {
        case .none, .canceled, .failed:
            viewModel.start(download: download)
        case .success:
            // TODO: show PDF
            break
        default:
            break
        }
    }

    private func startAll() {
        for download in viewModel.downloads {
            switch download.status {
            case .success, .none:
                viewModel.start(download: download)
            default:
                break
            }
        }
    }
}

#Preview {
    DownloadsView(viewModel: .init(urls: Sample.urls))
}
