import Foundation
import Testing

@testable import DownloadManager

struct DownloadManagerTests {
    private let testURLs: [URL] = [
        URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")!,
        URL(string: "https://file-examples.com/wp-content/uploads/2017/02/file_example_XLS_10.xls")!,
        URL(string: "https://file-examples.com/wp-content/uploads/2017/10/file-sample_150kB.pdf")!
    ]
    private let largeFileURL = URL(string: "https://speed.hetzner.de/100MB.bin")!
    private let nonExistentFileURL = URL(string: "https://nonexistent.fail/broken.pdf")!
    
    @Test
    func singleDownload() async throws {
        let manager: DownloadManager = .default
        let url = try #require(testURLs.first)
        await manager.startDownload(from: url)
        
        let stream = try #require(await manager.stream(for: url))
        for await status in stream {
            if case .success(let data) = status {
                #expect(!data.isEmpty)
                break
            } else if case .failed(let error) = status {
                #expect(Bool(false), "Download failed: \(error)")
                break
            }
        }
    }
    
    @Test
    func concurrentDownloads() async throws {
        let manager: DownloadManager = .default
        
        await withTaskGroup { group in
            for url in testURLs {
                group.addTask {
                    await manager.startDownload(from: url)
                }
            }
        }
    
        for url in testURLs {
            let stream = try #require(await manager.stream(for: url))
            for await status in stream {
                if case .success(let data) = status {
                    #expect(!data.isEmpty)
                    break
                } else if case .failed(let error) = status {
                    #expect(Bool(false), "Download failed: \(error)")
                    break
                }
            }
        }
    }
    
    @Test
    func progressUpdates() async throws {
        let manager: DownloadManager = .default
        let url = try #require(testURLs.first)
        await manager.startDownload(from: url)
        
        var updates: [DownloadStatus] = []
        let stream = try #require(await manager.stream(for: url))
        for await status in stream {
            updates.append(status)
            if status.didEnd {
                break
            }
        }
        
        #expect(updates.last?.didSucceed ?? false)
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
            if case .success(let data) = status {
                #expect(!data.isEmpty)
                break
            } else if case .failed(let error) = status {
                #expect(Bool(false), "Download failed: \(error)")
                break
            }
        }
    }
    
    @Test
    func failedDownload() async throws {
        let manager: DownloadManager = .default
        let url = nonExistentFileURL
        await manager.startDownload(from: url)
        
        let stream = try #require(await manager.stream(for: url))
        for await status in stream {
            if case .failed(let error) = status {
                #expect(Bool(true), "Download failed: \(error)")
                break
            }
        }
    }
}
