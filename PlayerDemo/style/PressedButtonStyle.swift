//
//  PressedButtonStyle.swift
//  PlayerDemo
//
//  Created by zu on 2025/10/6.
//
import SwiftUI

struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10.0)
            .background(
                RoundedRectangle(cornerRadius: 5.0)
                    .fill(
                        configuration.isPressed ? Color(hex: 0x006293) : Color(hex: 0x008bd0)
                    )
            )
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
