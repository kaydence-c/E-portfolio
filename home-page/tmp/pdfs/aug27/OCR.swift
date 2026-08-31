import Foundation
import Vision
import AppKit

for arg in CommandLine.arguments.dropFirst() {
    let url = URL(fileURLWithPath: arg)
    guard let image = NSImage(contentsOf: url),
          let data = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: data),
          let cg = rep.cgImage else { continue }
    let req = VNRecognizeTextRequest()
    req.recognitionLevel = .accurate
    req.usesLanguageCorrection = true
    let handler = VNImageRequestHandler(cgImage: cg)
    try handler.perform([req])
    print("===== \(url.lastPathComponent) =====")
    let observations = (req.results ?? []).sorted {
        let dy = $0.boundingBox.midY - $1.boundingBox.midY
        return abs(dy) > 0.005 ? dy > 0 : $0.boundingBox.minX < $1.boundingBox.minX
    }
    for o in observations {
        if let c = o.topCandidates(1).first { print(c.string) }
    }
}
