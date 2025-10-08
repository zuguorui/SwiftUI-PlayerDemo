//
//  PlayScreen.swift
//  PlayerDemo
//
//  Created by zu on 2025/10/8.
//

import SwiftUI

struct PlayScreen: View {
    
    @EnvironmentObject var navPath: NavigationPath
    var fileUrl: URL
    
    var body: some View {
        AVPlayerView(
            url: fileUrl,
            onExit: {
                navPath.path.popLast()
            }
        )
        .navigationTitle("playScreen")
        .navigationBarHidden(true)
    }
}

