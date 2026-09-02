import Foundation
import Photos
import UIKit
import CoreGraphics

enum ScreenshotLoaderError: Error {
    case notAuthorized
    case noScreenshot
    case loadFailed
}

enum ScreenshotLoader {
    static func fetchLatestScreenshotCGImage() async throws -> CGImage {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        guard status == .authorized || status == .limited else {
            throw ScreenshotLoaderError.notAuthorized
        }

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaSubtype == %d", PHAssetMediaSubtype.photoScreenshot.rawValue)
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        guard let asset = assets.firstObject else {
            throw ScreenshotLoaderError.noScreenshot
        }

        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isNetworkAccessAllowed = false

        var cgImage: CGImage?
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: requestOptions
        ) { image, _ in
            cgImage = image?.cgImage
        }
        guard let cgImage else {
            throw ScreenshotLoaderError.loadFailed
        }
        return cgImage
    }
}