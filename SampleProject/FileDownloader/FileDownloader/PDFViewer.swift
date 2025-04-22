//
//  PDFViewer.swift
//  FileDownloader
//
//  Created by Vinícius on 22/04/25.
//

import PDFKit
import SwiftUI

struct PDFViewer: View {
    @Environment(\.dismiss) private var dismiss
    private let document: PDFDocument?

    init(data: Data) {
        self.document = PDFDocument(data: data)
    }

    var body: some View {
        Group {
            if let document {
                PDFKitView(document: document)
                    .ignoresSafeArea()
            } else {
                error
            }
        }
        .overlay(alignment: .topTrailing) {
            dismissButton
        }
    }

    @ViewBuilder
    var dismissButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.headline.bold())
                .foregroundStyle(.white)
                .padding(8)
                .background(.gray.opacity(0.3), in: Circle())
                .background(.thinMaterial, in: Circle())
        }
        .padding()
    }

    @ViewBuilder
    var error: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(height: 60)
                .foregroundColor(.red)
            Text("Failed to show PDF")
                .foregroundColor(.red)
                .font(.title3)
        }
        .fontWeight(.semibold)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.thinMaterial)
    }
}

private extension PDFViewer {
    init(url: URL) {
        self.document = PDFDocument(url: url)
    }
}

private struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    init(document: PDFDocument) {
        self.document = document
    }

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = document
        view.autoScales = true
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // PDF will not be changed
    }
}

#Preview {
    PDFViewer(url: Sample.urls.first!)
}

#Preview("Invalid PDF") {
    PDFViewer(url: Sample.urls.last!)
}
