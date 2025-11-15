//
//  AVPlayerView.swift
//  PlayerDemo
//
//  Created by zu on 2025/10/7.
//

import SwiftUI
import AVFoundation
import CoreFoundation

struct AVPlayerView: View {
    
    let url: URL
    var onExit: (() -> Void)? = nil
    
    private let player: AVPlayer
    
    @StateObject private var uiState = PlayerViewUIState()
    
    @State private var hideControlTask: Task<Void, Never>? = nil
    @State private var playStateTask: Task<Void, Never>? = nil
    
    
    init(url: URL, onExit: (() -> Void)? = nil) {
        self.onExit = onExit
        self.url = url
        self.player = AVPlayer(url: url)
    }
    

    
    var body: some View {
        GeometryReader { geomtry in
            ZStack{
                AVPlayerViewBridge(player: player)
                if uiState.showControl {
                    VStack {
                        topController
                        Spacer()
                        bottomController
                    }
                }
            }
        }
        .onTapGesture {
            uiState.showControl = true
            uiState.lastTouchTime = Date()
        }
        .onAppear {
            uiState.lastTouchTime = Date()
            startHideControlTask()
            Task {
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    if player.status == .readyToPlay {
                        player.play()
                        break
                    }
                }
            }
            Task {
                while !Task.isCancelled {
                    uiState.isPlaying = player.timeControlStatus == .playing
                    if uiState.isPlaying {
                        let currentPos = player.currentTime()
                        uiState.playPos = Int64(CMTimeGetSeconds(currentPos) * 1000)
                    }
                    
                    try? await Task.sleep(nanoseconds: 500_000_000)
                }
            }
            Task {
                await getVideoInfo(from: url)
            }
        }
        .onDisappear {
            stopHideControlTask()
        }
    }
    
    var topController: some View {
        GeometryReader { geoReader in
            ZStack {
                HStack {
                    Button(action: {
                        player.pause()
                        player.replaceCurrentItem(with: nil)
                        onExit?()
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.white)
                            .frame(width: Dimens.playerButtonSize, height: Dimens.playerButtonSize, alignment: .center)
                    }
                    Spacer()
                }
                Text(uiState.name)
                    .foregroundStyle(.white)
                    .frame(maxWidth: geoReader.size.width * 0.5)
                    .lineLimit(1)
            }
            .padding()
            .frame(height: geoReader.size.height)
            
        }.frame(height: 40).background(.black)
        
    }
    
    var bottomController: some View {
        VStack {
            slider
            ZStack {
                HStack(alignment: .center) {
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Image(systemName: "backward.end.fill")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.white)
                            .frame(width: Dimens.playerButtonSize, height: Dimens.playerButtonSize, alignment: .center)
                    }
                    
                    Spacer().frame(width: 30.0)
                    Button(action: {
                        if player.timeControlStatus == .playing {
                            player.pause()
                        } else {
                            player.play()
                        }
                    }) {
                        Image(systemName: uiState.isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.white)
                            .frame(width: Dimens.playerButtonSize * 1.5, height: Dimens.playerButtonSize * 1.5, alignment: .center)
                    }
                    Spacer().frame(width: 30.0)
                    Button(action: {}) {
                        Image(systemName: "forward.end.fill")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.white)
                            .frame(width: Dimens.playerButtonSize, height: Dimens.playerButtonSize, alignment: .center)
                    }
                    
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button(action: {}) {
                        Image("IconAudioTrack")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: Dimens.playerButtonSize, height: Dimens.playerButtonSize, alignment: .center)
                    }
                    Spacer().frame(width: 20.0)
                    Button(action: {}) {
                        Image("IconSubtitle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: Dimens.playerButtonSize, height: Dimens.playerButtonSize, alignment: .center)
                            .padding(.trailing, 15.0)
                    }
                }
            }
            
        }.padding(.vertical, 10).background(.black)
    }
    
    
    @State var slideValue: Double = 0.0
    var slider: some View {
        Slider(
            value: Binding<Double>(
                get: {
                    slideValue == 0 ? Double(uiState.playPos) : slideValue
                },
                set: { newValue in
                    slideValue = newValue
                }
            ),
            in: 0...Double(max(uiState.duration, 1)),
            label: { Text("视频进度").foregroundStyle(.white) },
            minimumValueLabel: { Text("\(formatVideoDuration(uiState.playPos))").foregroundStyle(.white)},
            maximumValueLabel: { Text("\(formatVideoDuration(uiState.duration))").foregroundStyle(.white) },
            onEditingChanged: { editing in
                if !editing {
                    print("滑动结束: \(slideValue)")
                    player.seek(to: CMTime(value: CMTimeValue(slideValue), timescale: 1000))
                    slideValue = 0
                }
            }
        )
    }
    
    private func getVideoInfo(from url: URL) async {
        let asset = AVURLAsset(url: url)
        
        uiState.name = url.lastPathComponent
        
        // ✅ 1. 获取时长（秒）
        let duration = (try? await asset.load(.duration)) ?? .zero
        let durationInSeconds = CMTimeGetSeconds(duration)
        print("时长: \(durationInSeconds) 秒")
        uiState.duration = Int64(durationInSeconds * 1000)
        
        // ✅ 2. 获取视频轨道
        if let track = try? await asset.loadTracks(withMediaType: .video).first {
            do {
                // 获取分辨率（注意：分辨率要乘 transform）
                let transform = try await track.load(.preferredTransform)
                let size = try await track.load(.naturalSize).applying(transform)
                let width = abs(size.width)
                let height = abs(size.height)
                print("分辨率: \(Int(width)) x \(Int(height))")
                uiState.width = Int(width)
                uiState.height = Int(height)
            } catch {
                print("获取分辨率错误：\(error)")
            }
            
            
            // ✅ 3. 获取帧率
            if let frameRate = try? await track.load(.nominalFrameRate) {
                print("帧率: \(frameRate) fps")
                uiState.fps = frameRate
            }
            
            
            // ✅ 4. 获取码率（bitrate）
            if let bitrate = try? await track.load(.estimatedDataRate) {
                print("码率: \(bitrate) bps")
                
            }
            
        }
        
        // ✅ 5. 元数据（比如标题、创建日期）
        let metadata = asset.commonMetadata
        for item in metadata {
            if let key = item.commonKey?.rawValue, let value = item.value {
                print("\(key): \(value)")
            }
        }
    }
    
    
    private func startHideControlTask() {
        hideControlTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1000_000_000)
                let elapsed = Date().timeIntervalSince(uiState.lastTouchTime)
                if elapsed > 3 {
                    await MainActor.run {
                        withAnimation {
                            uiState.showControl = false
                        }
                    }
                }
            }
        }
    }
    
    private func stopHideControlTask() {
        hideControlTask?.cancel()
        hideControlTask = nil
    }
}

struct AVPlayerViewBridge: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        let view = PlayerContainerView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(view.playerLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.playerLayer?.frame = uiView.bounds
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var playerLayer: AVPlayerLayer?
    }
}


internal class PlayerViewUIState: ObservableObject {
    @Published var playPos: Int64 = 10000
    @Published var isPlaying: Bool = false
    @Published var duration: Int64 = 27837856
    @Published var name: String = "video.mp4"
    @Published var width: Int = 1920
    @Published var height: Int = 1080
    @Published var fps: Float = 25.0
    @Published var format: String = "H264"
    @Published var decoderType: String = "HW"
    
    @Published var showControl: Bool = true
    @Published var lastTouchTime: Date = Date()
}

#Preview {
    AVPlayerView(url: URL(filePath: "")!)
//    @StateObject var uiState = PlayerViewUIState()
//    VideoBottomControlView(uiState: uiState)
}

