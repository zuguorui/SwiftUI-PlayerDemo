//
//  TimeUtil.swift
//  PlayerDemo
//
//  Created by zu on 2025/10/8.
//

import SwiftUI


/// 将毫秒时长格式化为 HH:mm:ss 或 mm:ss
/// - Parameter milliseconds: 视频时长，单位毫秒
/// - Returns: 格式化后的时间字符串
func formatVideoDuration(_ milliseconds: Int64) -> String {
    let totalSeconds = milliseconds / 1000
    let seconds = totalSeconds % 60
    let minutes = (totalSeconds / 60) % 60
    let hours = totalSeconds / 3600
    
    if hours > 0 {
            // 有小时，格式 HH:mm:ss
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    } else {
            // 无小时，格式 mm:ss
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
