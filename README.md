## Exploring Swift Concurrency: DownloadManager

This project is an exercise in making use of **Swift Concurrency** features to solve **race condition problems** that happen when downloading multiple files simultaneously.

Since Swift's `actor` serializes all access (reading and writing), half-updated or conflicting data will never be served.

DownloadManager was designed as an `actor` to safely manage multiple file downloads in parallel, while allowing for download cancelation and real-time progress tracking. It also safely handles duplicate download attempts.

Use cases for this range from a browser-like download screen to a media app that downloads content on demand.

Implementation details worth mentioning is the **Protocol-Oriented Design** and the use of `AsyncStream` to send out progress updates.
