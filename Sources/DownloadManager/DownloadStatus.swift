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

    public var isFinished: Bool {
        switch self {
        case .success, .failed, .canceled:
            true
        default:
            false
        }
    }
}

extension DownloadStatus: Equatable {
    public static func == (lhs: DownloadStatus, rhs: DownloadStatus) -> Bool {
        switch (lhs, rhs) {
        case (.requested, .requested):
            true
        case (.progress(let lhsProgress), .progress(let rhsProgress)):
            lhsProgress == rhsProgress
        case (.success, .success):
            true
        case (.failed(let lhsError), .failed(let rhsError)):
            lhsError?.localizedDescription == rhsError?.localizedDescription
        case (.canceled, .canceled):
            true
        default:
            false
        }
    }
}
