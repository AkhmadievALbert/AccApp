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
enum AppIconOverlay {
  static func main() {
    // 1
    guard
      let srcRoot = ProcessInfo.processInfo.environment["SRCROOT"],
      let appIconName = ProcessInfo.processInfo.environment["ASSETCATALOG_COMPILER_APPICON_NAME"],
      let targetName = ProcessInfo.processInfo.environment["TARGET_NAME"]
    else {
      return
    }
    // 2
    let appIconsPath =
      "\(srcRoot)/\(targetName)/Assets.xcassets/\(appIconName).appiconset"
    let assetsPath =
      "\(srcRoot)/\(targetName)/Assets.xcassets/"
    let sourcePath =
      "\(srcRoot)/Scripts/AppIcon.appiconset"

    // 3
    _ = shell("rm -r \(appIconsPath)")
    _ = shell("cp -r \(sourcePath) \(assetsPath)")

    // 4
    guard let images =
      try? FileManager.default.contentsOfDirectory(atPath: appIconsPath)
    else {
      return
    }
    // 5
    let config = ProcessInfo.processInfo.environment["CONFIGURATION"] ?? ""
    // 6
    for imageFile in images {
      if imageFile.hasSuffix(".png") {
        let fileURL = URL(fileURLWithPath: appIconsPath + "/" + imageFile)
        addOverlay(imagePath: fileURL, text: "\(config.prefix(1))")
      }
    }
  }
}
