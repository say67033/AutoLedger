import Foundation
import CoreGraphics
import Vision

struct OCRResult {
    let fullText: String
    let lines: [String]
}

enum OCRError: Error {
    case recognitionFailed
}

final class OCRService {
    func recognize(_ image: CGImage) throws -> OCRResult {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["zh-Hans", "en-US"]

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])

        let lines = request.results?.compactMap { $0.topCandidates(1).first?.string } ?? []
        guard !lines.isEmpty else {
            throw OCRError.recognitionFailed
        }
        return OCRResult(fullText: lines.joined(separator: "\n"), lines: lines)
    }
}