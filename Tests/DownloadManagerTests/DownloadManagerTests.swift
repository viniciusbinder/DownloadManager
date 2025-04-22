import Foundation
import Testing

@testable import DownloadManager

struct DownloadManagerTests {
    private let testURLs: [URL] = [
        URL(string: "https://link.testfile.org/15MB")!,
        URL(string: "https://link.testfile.org/30MB")!,
        URL(string: "https://link.testfile.org/70MB")!
    ]
    private let largeFileURL = URL(string: "https://link.testfile.org/500MB")!
    private let fakeFileURL = URL(string: "https://nonexistent.fail/broken.pdf")!
    
    func error(_ status: DownloadStatus) -> Error {
        NSError(
            domain: "DownloadError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Unexpected download status: \(status)"]
        )
    }
    
    @Test
    func singleDownload() async throws {
        let manager: DownloadManager = .default
        let url = try #require(testURLs.first)
        await manager.startDownload(from: url)
        
        let stream = try #require(await manager.stream(for: url))
        for await status in stream {
            switch status {
            case .progress(let progress):
                #expect(progress >= 0 && progress <= 1)
            case .success(let data):
                #expect(!data.isEmpty)
            default:
                throw error(status)
            }
        }
    }
    
    @Test
    func concurrentDownloads() async throws {
        let manager: DownloadManager = .default
        
        for url in testURLs {
            await manager.startDownload(from: url)
        }
    
        try await withThrowingTaskGroup(of: Void.self) { group in
            for url in testURLs {
                group.addTask {
                    let stream = try #require(await manager.stream(for: url))
                    for await status in stream {
                        switch status {
                        case .progress(let progress):
                            #expect(progress >= 0 && progress <= 1)
                        case .success(let data):
                            #expect(!data.isEmpty)
                        default:
                            throw error(status)
                        }
                    }
                }
            }
            
            for try await _ in group {}
        }
    }
    
    @Test
    func cancelDownload() async throws {
        let manager: DownloadManager = .default
        let url = largeFileURL
        
        await manager.startDownload(from: url)
        
        Task {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            await manager.cancelDownload(for: url)
        }
        
        let stream = try #require(await manager.stream(for: url))
        for await status in stream {
            switch status {
            case .progress(let progress):
                #expect(progress >= 0 && progress <= 1)
            case .canceled:
                break
            default:
                throw error(status)
            }
        }
    }
    
    @Test
    func failedDownload() async throws {
        let manager: DownloadManager = .default
        let url = fakeFileURL
        await manager.startDownload(from: url)
        
        let stream = try #require(await manager.stream(for: url))
        for await status in stream {
            switch status {
            case .progress(let progress):
                #expect(progress >= 0 && progress <= 1)
            case .failed:
                break
            default:
                throw error(status)
            }
        }
    }
    
    @Test
    func duplicateDownloads() async throws {
        let manager: DownloadManager = .default
        let url = try #require(testURLs.first)
        
        await manager.startDownload(from: url)
        
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            await manager.startDownload(from: url)
        }
        
        var lastProgress = 0.0
        let stream = try #require(await manager.stream(for: url))
        for await status in stream {
            switch status {
            case .progress(let progress):
                #expect(progress >= 0 && progress <= 1)
                #expect(progress >= lastProgress)
                lastProgress = progress
            case .success(let data):
                #expect(!data.isEmpty)
            default:
                throw error(status)
            }
        }
    }
}
