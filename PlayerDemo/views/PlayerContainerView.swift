//
//  PlayerContainerView.swift
//  PlayerDemo
//
//  Created by zu on 2025/10/8.
//
import UIKit
import AVFoundation

class PlayerContainerView: UIView {
    let playerLayer = AVPlayerLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
