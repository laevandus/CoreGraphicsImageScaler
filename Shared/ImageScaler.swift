//
//  ImageScaler.swift
//  CoreGraphicsImageScaler
//
//  Created by Toomas Vahter on 28.11.2020.
//

import CoreGraphics

struct ImageScaler {
    static func scaleToFill(_ image: CGImage, from fromRect: CGRect = .zero, in targetSize: CGSize) -> CGImage? {
        let imageSize = CGSize(width: image.width, height: image.height)
        let rect = fromRect.isEmpty ? CGRect(origin: .zero, size: imageSize) : fromRect
        let scaledRect = rect.scaled(toFillSize: targetSize)
        return scale(image, fromRect: scaledRect, in: targetSize)
    }
    
    private static func scale(_ image: CGImage, fromRect: CGRect = .zero, in targetSize: CGSize) -> CGImage? {
        let makeCroppedCGImage: (CGImage) -> CGImage? = { cgImage in
            guard !fromRect.isEmpty else { return cgImage }
            return cgImage.cropping(to: fromRect)
        }
        guard let croppedImage = makeCroppedCGImage(image) else { return nil }
        let context = CGContext(data: nil,
                                width: Int(targetSize.width),
                                height: Int(targetSize.height),
                                bitsPerComponent: croppedImage.bitsPerComponent,
                                bytesPerRow: croppedImage.bytesPerRow,
                                space: croppedImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: croppedImage.bitmapInfo.rawValue)
        context?.interpolationQuality = .high
        context?.draw(croppedImage, in: CGRect(origin: .zero, size: targetSize))
        return context?.makeImage()
    }
}

extension CGSize {
    enum Aspect {
        case portrait, landscape, square
    }
    var aspect: Aspect {
        switch width / height {
        case 1.0:
            return .square
        case 1.0...:
            return .landscape
        default:
            return .portrait
        }
    }
    var aspectRatio: CGFloat {
        return width / height
    }
}

extension CGRect {
    func scaled(toFillSize targetSize: CGSize) -> CGRect {
        var scaledRect = self
        switch (size.aspect, targetSize.aspect) {
        case (.portrait, .portrait), (.portrait, .square):
            scaledRect.size.height = width / targetSize.aspectRatio
            scaledRect.size.width = width
            if scaledRect.height > height {
                scaledRect.size = size
            }
            scaledRect.origin.y -= (scaledRect.height - height) / 2.0
        case (.portrait, .landscape), (.square, .landscape):
            scaledRect.size.height = width / targetSize.aspectRatio
            scaledRect.size.width = width
            if scaledRect.height > height {
                scaledRect.size = size
            }
            scaledRect.origin.y -= (scaledRect.height - height) / 2.0
        case (.landscape, .portrait), (.square, .portrait):
            scaledRect.size.height = height
            scaledRect.size.width = height * targetSize.aspectRatio
            if scaledRect.width > width {
                scaledRect.size = size
            }
            scaledRect.origin.x -= (scaledRect.width - width) / 2.0
        case (.landscape, .landscape), (.landscape, .square):
            scaledRect.size.height = height
            scaledRect.size.width = height * targetSize.aspectRatio
            if scaledRect.size.width > width {
                scaledRect.size = size
            }
            scaledRect.origin.x -= (scaledRect.width - width) / 2.0
        case (.square, .square):
            return self
        }
        return scaledRect.integral
    }
}

