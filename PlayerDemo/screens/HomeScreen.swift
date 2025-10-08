//
//  HomeScreen.swift
//  PlayerDemo
//
//  Created by zu on 2025/10/6.
//
import SwiftUI



struct HomeScreen: View {
    
    @State var showDocumentPicker = false
    @EnvironmentObject var navPath: NavigationPath
    
    @State private var fileUrl: URL? = nil {
        didSet {
            if fileUrl != nil {
                navPath.path.append("playScreen")
            }
        }
    }
    
    var body: some View {
        NavigationStack(path: $navPath.path) {
            VStack {
                Button(
                    action: {
                        showDocumentPicker = true
                    },
                    label: {
                        Text("播放本地文件")
                    }
                )
                .buttonStyle(PressedButtonStyle())
                
                Button(
                    action: {
                        
                    },
                    label: {
                        Text("播放网络流")
                    }
                )
                .buttonStyle(PressedButtonStyle())
                
            }
            .navigationTitle("homeScreen")
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { value in
                if value == "playScreen" {
                    PlayScreen(fileUrl: fileUrl!)
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPickerView { url in
                    print("url: \(url)")
                    fileUrl = url
                }
            }
        }
    }
}

#Preview {
    @StateObject var navPath = NavigationPath()
    HomeScreen().environmentObject(navPath)
}
