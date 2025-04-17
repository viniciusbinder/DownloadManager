//
//  DownloadStatus.swift
//  DownloadManager
//
//  Created by Vinícius on 17/04/25.
//

import Foundation

enum DownloadStatus {
    case progress(Double)
    case success(Data)
    case failed(URLError)
}

extension DownloadStatus {
    var didSucceed: Bool {
        if case .success = self { true } else { false }
    }

    var didFail: Bool {
        if case .failed = self { true } else { false }
    }

    var didCancel: Bool {
        if case .failed(let error) = self, error.code == .cancelled {
            true
        } else {
            false
        }
    }

    var didEnd: Bool {
        switch self {
        case .success, .failed:
            true
        case .progress:
            false
        }
    }
}
