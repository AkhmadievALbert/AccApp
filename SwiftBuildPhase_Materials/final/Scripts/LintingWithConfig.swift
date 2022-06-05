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
import Combine

@main
enum LintingWithConfig {
  static func main() {
    var cancelHandler: AnyCancellable?
    let group = DispatchGroup()
    // 1
    guard let projectDir = ProcessInfo.processInfo.environment["SRCROOT"] else {
      return
    }

    let configURL = URL(fileURLWithPath: "\(projectDir)/AllowedWarnings.json")
    // 2
    let publisher = URLSession.shared.dataTaskPublisher(for: configURL)
    let configPublisher = publisher
      .map(\.data)
      .decode(type: LintConfig.self, decoder: JSONDecoder())
      .eraseToAnyPublisher()
    // 3
    group.enter()
    cancelHandler = configPublisher.sink { completion in
      // 4
      switch completion {
      case .failure(let error):
        print("\(error)")
        group.leave()
        exit(1)
      case .finished:
        print("Linting Config Loaded")
      }
    } receiveValue: { value in
      // 5
      startLinting(allowedWarnings: value.allowedWarnings)
    }
    // 6
    group.wait()
    cancelHandler?.cancel()
  }

  static func startLinting(allowedWarnings: Int = 0) {
    let lintResult = shell("swiftlint --config com.raywenderlich.swiftlint.yml")
    print(lintResult)
    var logResult = lintResult.components(separatedBy: "Done linting!").last ?? "Found 0"
    logResult = logResult.trimmingCharacters(in: CharacterSet(charactersIn: " "))
      .components(separatedBy: " ")[1]
    let foundViolations = Int(logResult) ?? 0

    if foundViolations > allowedWarnings {
      print("Error: Violations allowed exceed limit. Limit is \(allowedWarnings) violations, Found \(foundViolations)!")
      exit(1)
    }

    exit(0)
  }
}

struct LintConfig: Codable {
  let allowedWarnings: Int
}
