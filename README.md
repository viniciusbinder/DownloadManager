## Exploring Swift Concurrency: DownloadManager

**DownloadManager** was designed as an `actor` to safely manage multiple file downloads in parallel. It allows for download cancelation and real-time progress tracking, and safely handles duplicate download attempts. Use cases range from a browser-like download screen to a media app that downloads content on demand.

This project is an exercise in learning to make use of **Swift Concurrency** features to solve **race condition problems** that happen when downloading multiple files simultaneously. Since Swift's `actor` serializes all access (reading and writing), half-updated or conflicting data will never be served.

Implementation details worth mentioning is the **Protocol-Oriented Design**, **Test-Drive Development** and the use of `AsyncStream` to send out progress updates. There's a single-screen `/SampleProject` attached that demonstrates its use in a concurrent user downloads list.
