//
//  AVAssetExtention.swift
//  VideoDownloader
//
//  Created by Mohit Kanpara on 23/04/26.
//

import AVFoundation
import CoreImage

extension AVAsset {
    func setFilter(_ filter: CIFilter) -> AVVideoComposition {
        let composition = AVVideoComposition(asset: self, applyingCIFiltersWithHandler: { request in
            filter.setValue(request.sourceImage, forKey: kCIInputImageKey)
            guard let output = filter.outputImage else { return }
            request.finish(with: output, context: nil)
        })
        return composition
    }
    func setVideoComposition(transform: CGAffineTransform, renderSize: CGSize) -> AVVideoComposition {
        let composition = AVMutableVideoComposition(asset: self) { request in
            let transformedImage = request.sourceImage.transformed(by: transform)
            request.finish(with: transformedImage, context: nil)
        }
        composition.renderSize = renderSize
        composition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        return composition
    }
}
