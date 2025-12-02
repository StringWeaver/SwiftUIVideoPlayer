//
//  PlayerModel.swift
//  SwiftVideoPlayer
//
//  Created by StringWeaver on 2025-11-26.
//

import AVKit
import Combine

final class PlayerModel: NSObject, ObservableObject {

    @Published var player: AVPlayer?
    @Published var ready: Bool = false
    
    
    var title: String = ""
    var filename: String = ""
    private var timeObserver: Any?
    private var securityURL: URL?
    
    
    func load(url: URL) {
        if url.startAccessingSecurityScopedResource() {
            securityURL = url
        } else {
            securityURL = nil
        }
        filename = url.lastPathComponent
        title = trimLeadingNonDigits(filename)
        let item = AVPlayerItem(url: url)
        
        #if !os(macOS)
        let titleItem = AVMutableMetadataItem()
        titleItem.keySpace = AVMetadataKeySpace.common
        titleItem.key = AVMetadataKey.commonKeyTitle as (NSCopying & NSObjectProtocol)?
        titleItem.value = title as (NSCopying & NSObjectProtocol)?
        item.externalMetadata = [titleItem]
        #endif
        
        player = AVPlayer(playerItem: item)

        let seconds = UserDefaults.standard.double(forKey: filename)
        let twoSec = CMTimeMake(value: 2, timescale: 1)
        if seconds > 0 {
            let t = CMTimeMakeWithSeconds(seconds, preferredTimescale: 1)
            player!.seek(to: t, toleranceBefore: twoSec, toleranceAfter: twoSec)
        }
        
        

        timeObserver = player!.addPeriodicTimeObserver(forInterval: twoSec, queue: .main) {
            [weak self] time in
            self?.saveProgress(time: time, filename: self!.filename)
        }
        

        
        player!.play()
        ready = true
    }
    


    
    // MARK: - Helpers
    private func saveProgress(time: CMTime, filename: String) {
        let sec = CMTimeGetSeconds(time)
        if sec > 0 {
            UserDefaults.standard.set(sec, forKey: filename)
        }
    }
    
    // MARK: - Cleanup
    func cleanup() {
        if let player = player, let obs = timeObserver {
            player.removeTimeObserver(obs)
        }
        timeObserver = nil
        player?.pause()
        player = nil
        
        if let url = securityURL {
            url.stopAccessingSecurityScopedResource()
            securityURL = nil
        }
        ready = false
        
    }
    
    deinit {
        cleanup()
    }
    
    private func trimLeadingNonDigits(_ input: String) -> String {
        let digits = CharacterSet.decimalDigits
        if let range = input.rangeOfCharacter(from: digits) {
            return String(input[range.lowerBound...])
        }
        return input
    }
}
