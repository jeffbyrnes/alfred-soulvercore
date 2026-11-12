import Foundation

private func workflowFolder(environmentKey: String, fallback: FileManager.SearchPathDirectory) -> URL {
  if let path = ProcessInfo.processInfo.environment[environmentKey], !path.isEmpty {
    return URL(fileURLWithPath: path, isDirectory: true)
  }
  return FileManager.default.urls(for: fallback, in: .userDomainMask)[0]
    .appendingPathComponent("design.precioso.alfred-soulvercore", isDirectory: true)
}

let CacheFolderURL = workflowFolder(environmentKey: "alfred_workflow_cache", fallback: .cachesDirectory)
let DataFolderURL = workflowFolder(environmentKey: "alfred_workflow_data", fallback: .applicationSupportDirectory)

let PreferencesDataURL = DataFolderURL.appendingPathComponent("preferences.json")
let CurrencyDataURL = CacheFolderURL.appendingPathComponent("currencies.json")
