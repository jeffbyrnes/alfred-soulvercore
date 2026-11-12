import Foundation
import SoulverCore

// SoulverCore's shared mutable currency state stays on the main thread.
@MainActor
final class CurrencyRefresher {
  private init() {
    do {
      try CurrencyList.shared.loadCurrenciesFrom(url: CurrencyDataURL)
    } catch {}
  }
  static let shared = CurrencyRefresher()

  enum Error: Swift.Error {
    case errorRefreshingCurrency
  }

  func refreshIfNeeded() async throws {
    if await PreferencesManager.shared.needsRefresh() {
      try await refresh()
    }
  }

  func refresh() async throws {
    CurrencyList.shared.defaultCurrencySet = .popular
    try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, Swift.Error>) in
      let completion = CurrencyRefreshCompletion(c)
      DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        completion.finish(success: false)
      }
      CurrencyList.shared.refreshRates { success in
        completion.finish(success: success)
      }
    }
    try FileManager.default.createDirectory(
      at: CurrencyDataURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    CurrencyList.shared.saveCurrenciesTo(url: CurrencyDataURL)
    await PreferencesManager.shared.markRefreshed()
  }
}

// A timeout and a late network callback must not resume the continuation twice.
private final class CurrencyRefreshCompletion: @unchecked Sendable {
  private let lock = NSLock()
  private var continuation: CheckedContinuation<Void, Swift.Error>?

  init(_ continuation: CheckedContinuation<Void, Swift.Error>) {
    self.continuation = continuation
  }

  func finish(success: Bool) {
    lock.lock()
    let pending = continuation
    continuation = nil
    lock.unlock()
    if success {
      pending?.resume(returning: ())
    } else {
      pending?.resume(throwing: CurrencyRefresher.Error.errorRefreshingCurrency)
    }
  }
}
