//
//  VideoOverlay.swift
//  videooverlay
//
//  Created by jijo pulikkottil on 24/08/19.
//  Copyright © 2019 jijo. All rights reserved.

import Foundation
import UIKit
import AVFoundation

extension Date {
    static func getTodaysDateWithTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "YYYYMMdd_HHmmss"
        let now = formatter.string(from: date)
        return now
    }
}

enum VideoOvelayPosition {
    case bottomLeft
    case center
}

class VideoOvelay {
    
    
    
    func addOverlayText(_ text: String, fileURL: URL, destURL: URL, position: VideoOvelayPosition, completion: @escaping (Error?) -> Void) {
        
        print("destURL = \(destURL)")
        
        // Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
        let composition = AVMutableComposition()
        let vidAsset = AVURLAsset(url: fileURL, options: nil)
        
        //var error: NSError?
        
        // get video track
        let vtrack =  vidAsset.tracks(withMediaType: AVMediaType.video)
        guard let videoAssetTrack: AVAssetTrack = vtrack.first else {
            print("vtrack.first nil")
            completion(nil)
            return
        }
        
        // Video track
        //let vid_duration = videoTrack.timeRange.duration
        let vid_timerange = CMTimeRangeMake(start: CMTime.zero, duration: vidAsset.duration)
        let compositionvideoTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())!
        
        do {
            try compositionvideoTrack.insertTimeRange(vid_timerange, of: videoAssetTrack, at: CMTime.zero)
            //compositionvideoTrack.preferredTransform = videoAssetTrack.preferredTransform
        } catch {
            print("compositionvideoTrack nil")
        }
        
        // Create AVMutableVideoCompositionInstruction
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: composition.duration)
        
        
        //  Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
        let layerinstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionvideoTrack)
        
        let videoTransform = videoAssetTrack.preferredTransform
        var isVideoAssetPortrait_  = false
        if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
            isVideoAssetPortrait_ = true
            print("is portrait")
        }
        if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
            isVideoAssetPortrait_ = true
            print("is portrait")
        }
        
        layerinstruction.setTransform(videoAssetTrack.preferredTransform, at: CMTime.zero)
        layerinstruction.setOpacity(0.0, at: vidAsset.duration)
        
        let size: CGSize
        if isVideoAssetPortrait_ {
            let t1: CGAffineTransform = CGAffineTransform(translationX: videoAssetTrack.naturalSize.height, y: 0)
            let t2: CGAffineTransform = t1.rotated(by: CGFloat(Double.pi / 2))
            let finalTransform: CGAffineTransform = t2
            layerinstruction.setTransform(finalTransform, at: CMTime.zero)
            size = CGSize(width: videoAssetTrack.naturalSize.height, height: videoAssetTrack.naturalSize.width)
        } else {
            layerinstruction.setTransform(videoAssetTrack.preferredTransform, at: CMTime.zero)
            size = videoAssetTrack.naturalSize
        }
        print("\n overlay video size = \(size)")

        let imglayer = CALayer()
        if let imglogo = UIImage(named: "sample") {
            imglayer.contents = imglogo.cgImage
            let widthhImage: CGFloat = 100
            let heightImage: CGFloat = widthhImage * imglogo.size.height / imglogo.size.width
            // please make sure watermark (at bottom-right) is in-line with text cation (at bottom-left) -- meaning same distance from bottom of clip.
            imglayer.frame = CGRect(x: size.width - widthhImage - 25, y: heightImage + 10, width: widthhImage, height: heightImage)
            imglayer.opacity = 0.15
        }
        
        
        let titleLayerShadow = CATextLayer()
        //        titleLayer.shadowOpacity = 1
        //        titleLayer.shadowColor = UIColor.shadowColor().cgColor
        let fontFace = CTFontCreateWithName((("Lato-Heavy") as CFString),
                                            60.0,
                                            nil)
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[NSAttributedString.Key.font] = fontFace
        attributes[NSAttributedString.Key.foregroundColor] = UIColor.brown.cgColor
        attributes[NSAttributedString.Key.kern] = 5.0
        var caption = text
        let attrStr = NSAttributedString(string: caption,
                                         attributes: attributes)
        titleLayerShadow.string = attrStr
        
        
        let titleLayer = CATextLayer()
        //        titleLayer.shadowOpacity = 1
        //        titleLayer.shadowColor = UIColor.shadowColor().cgColor
        var attributes2: [NSAttributedString.Key: Any] = [:]
        attributes2[NSAttributedString.Key.font] = fontFace
        attributes2[NSAttributedString.Key.foregroundColor] = UIColor.white.cgColor
        attributes2[NSAttributedString.Key.kern] = 5.0
        let attrStr2 = NSAttributedString(string: caption,
                                          attributes: attributes2)
        titleLayer.string = attrStr2
        
        switch position {
            
        case .bottomLeft:
            // please make sure watermark (at bottom-right) is in-line with text cation (at bottom-left) -- meaning same distance from bottom of clip.
            titleLayerShadow.alignmentMode = CATextLayerAlignmentMode.natural
            titleLayerShadow.frame = CGRect(x: 39, y: 61, width: size.width - 135, height: 70)
            
            titleLayer.alignmentMode = CATextLayerAlignmentMode.natural
            titleLayer.frame = CGRect(x: 35, y: 65, width: size.width - 135, height: 70)
        case .center:
            titleLayerShadow.alignmentMode = CATextLayerAlignmentMode.center
            titleLayerShadow.frame = CGRect(x: 24, y: (size.height / 2 - 180 / 2) - 4, width: size.width - 40, height: 180)
            
            titleLayer.alignmentMode = CATextLayerAlignmentMode.center
            titleLayer.frame = CGRect(x: 20, y: size.height / 2 - 180 / 2, width: size.width - 40, height: 180)
            
        }
        
        titleLayerShadow.display()
        titleLayer.display()
        
        let videolayer = CALayer()
        videolayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        let parentlayer = CALayer()
        parentlayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        parentlayer.addSublayer(videolayer)
        parentlayer.addSublayer(imglayer)
        parentlayer.addSublayer(titleLayerShadow)
        parentlayer.addSublayer(titleLayer)
        
        let layercomposition = AVMutableVideoComposition()
        layercomposition.frameDuration = CMTimeMake(value: 1, timescale: 30)//60
        layercomposition.renderSize = size
        layercomposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videolayer, in: parentlayer)
        
        // instruction for watermark
        
        
        instruction.layerInstructions = [layerinstruction]
        layercomposition.instructions = [instruction]
        
        let movieDestinationUrl = destURL

        // use AVAssetExportSession to export video
        let assetExport = AVAssetExportSession(asset: composition, presetName:AVAssetExportPresetHEVCHighestQuality)
        assetExport?.videoComposition = layercomposition
        assetExport?.outputFileType = AVFileType.mp4
        assetExport?.outputURL = movieDestinationUrl

        print("exporting")
        assetExport?.exportAsynchronously(completionHandler: {
            switch assetExport!.status{
            case  AVAssetExportSessionStatus.failed:
                print("\nfailed \(String(describing: assetExport!.error)) \(movieDestinationUrl)")
                completion(nil)
            case AVAssetExportSessionStatus.cancelled:
                print("\ncancelled \(String(describing: assetExport!.error)) \(movieDestinationUrl)")
                completion(nil)
            case .unknown:
                print("\n unknown \(String(describing: assetExport!.error)) \(movieDestinationUrl)")
                completion(nil)
            case .waiting:
                print("\n waiting \(String(describing: assetExport!.error)) \(movieDestinationUrl)")
                completion(nil)
            case .exporting:
                print("\n exporting \(String(describing: assetExport!.error)) \(movieDestinationUrl)")
                completion(nil)
            case .completed:
                completion(nil)
            @unknown default:
                completion(nil)
            }
        })
        
        
    }
    
}
