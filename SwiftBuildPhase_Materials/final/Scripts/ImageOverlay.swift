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

import AppKit

func addOverlay(imagePath: URL, text: String) {
  guard let image = NSImage(contentsOf: imagePath) else {
    return
  }

  var multiplier: CGFloat = 1
  if imagePath.path.contains("@2x") {
    multiplier = 2
  } else if imagePath.path.contains("@3x") {
    multiplier = 3
  }

  // If you are using multiple screens and the main screen is an external one
  let maxScale = NSScreen.screens.map { $0.backingScaleFactor }.max()
  multiplier /= maxScale ?? 1

  let imageSize = CGSize(width: image.size.width * multiplier, height: image.size.height * multiplier)
  let newView = NSView(frame: CGRect(origin: .zero, size: imageSize))
  let imageView = NSImageView(image: image)
  imageView.imageScaling = .scaleProportionallyUpOrDown
  imageView.frame = CGRect(origin: .zero, size: imageSize)
  newView.addSubview(imageView)
  let overlayFrame = CGRect(
    x: 0,
    y: 0,
    width: imageSize.width / 2,
    height: imageSize.height / 2)
  let overlayLabel = OverlayLabel(frame: overlayFrame)
  overlayLabel.stringValue = text
  newView.addSubview(overlayLabel)
  if let data = makePNGDataFrom(view: newView) {
    try? data.write(to: imagePath)
  }
}

func makePNGDataFrom(view: NSView) -> Data? {
  guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else {
    return nil
  }
  view.cacheDisplay(in: view.bounds, to: rep)
  guard let data = rep.representation(
    using: NSBitmapImageRep.FileType.png,
    properties: [:])
  else {
    return nil
  }
  return data
}
