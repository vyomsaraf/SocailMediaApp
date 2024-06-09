//
//  ViewModifiers.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import SwiftUI

struct ClearButton: ViewModifier {
    @Binding var text: String
    var isSearchBar: Bool = false
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            if !text.isEmpty
            {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(Color.primary.opacity(0.54))
                }
                .padding(.trailing, 8.0)
                .accessibilityHint("Clear text")
            }
        }
    }
}


struct AppOverlay: ViewModifier {
    var v_Padding = 16.0
    var h_Padding = 16.0
    var cornerRadius = 4.0
    var bColor = Color.primaryBorder
    var lineWidth = 1.0
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, v_Padding)
            .padding(.horizontal, h_Padding)
        
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(bColor, lineWidth: lineWidth)
            )
    }
}

struct AppNavigationTitleBar: ViewModifier {
    
    var title: String
    var placement: ToolbarItemPlacement = .principal
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: placement) {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue, .blue.opacity(0.1))
                }
            }
    }
}
