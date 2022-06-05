/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

@main
enum IncBuildNumber {
  static func main() {
    // 1
    guard let infoFile = ProcessInfo.processInfo.environment["INFOPLIST_FILE"] else {
      return
    }
    guard let projectDir = ProcessInfo.processInfo.environment["SRCROOT"] else {
      return
    }
    // 2
    if var dict = NSDictionary(contentsOfFile: projectDir + "/" + infoFile) as? [String: Any] {
      guard
        let currentVersionString = dict["CFBundleShortVersionString"] as? String,
        let currentBuildNumberString = dict["CFBundleVersion"] as? String,
        let currentBuildNumber = Int(currentBuildNumberString)
      else {
        return
        }

      // 3
      dict["CFBundleVersion"] = "\(currentBuildNumber + 1)"

      // 4
      if ProcessInfo.processInfo.environment["CONFIGURATION"] == "Release" {
        // 5
        var versionComponents = currentVersionString.components(separatedBy: ".")
        let lastComponent = (Int(versionComponents.last ?? "1") ?? 1)
        versionComponents[versionComponents.endIndex - 1] = "\(lastComponent + 1)"
        dict["CFBundleShortVersionString"] = versionComponents.joined(separator: ".")
      }
      // 6
      (dict as NSDictionary).write(toFile: projectDir + "/" + infoFile, atomically: true)
    }
  }
}
