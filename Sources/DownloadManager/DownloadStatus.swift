//
//  DownloadStatus.swift
//  DownloadManager
//
//  Created by Vinícius on 17/04/25.
//

import Foundation

public enum DownloadStatus: Sendable {
    case requested
    case progress(Double)
    case success(Data)
    case failed(Error?)
    case canceled

    var isFinished: Bool {
        switch self {
        case .success, .failed, .canceled:
            true
        default:
            false
        }
    }
}
