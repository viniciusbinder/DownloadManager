//
//  DownloadCell.swift
//  FileDownloader
//
//  Created by Vinícius on 22/04/25.
//

import SwiftUI

struct DownloadCell: View {
    let download: Download

    var body: some View {
        VStack {
            HStack {
                Text(download.name)
                    .fontWeight(.medium)
                Spacer()
                status
                    .frame(width: 24, height: 24)
                    .transition(.scale)
                    .padding(.horizontal)
            }

            error
        }
        .padding(.vertical)
    }

    @ViewBuilder
    var status: some View {
        if let status = download.status {
            switch status {
            case .requested:
                ProgressView()
                    .progressViewStyle(.circular)
            case .progress(let progress):
                indicator(progress)
            case .success:
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(.green)
            case .canceled:
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .foregroundColor(.yellow)
            case .failed:
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .foregroundColor(.red)
            }
        } else {
            Image(systemName: "arrow.down.circle")
                .resizable()
                .foregroundColor(.blue)
        }
    }

    @ViewBuilder
    func indicator(_ progress: Double) -> some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 3)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, lineWidth: 3)
                .rotationEffect(.degrees(-90))
        }
    }

    @ViewBuilder
    var error: some View {
        if case .failed(let error) = download.status {
            Text(error?.localizedDescription ?? "An error occurred.")
                .font(.body.bold())
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red)
                }
                .offset(y: 8)
        }
    }
}

#Preview {
    List {
        DownloadCell(download: Sample.download(status: .requested))
        DownloadCell(download: Sample.download(status: .progress(0.5)))
        DownloadCell(download: Sample.download(status: .success(.init())))
        DownloadCell(download: Sample.download(status: .canceled))
        DownloadCell(download: Sample.download(status: .failed(nil)))
    }
}
