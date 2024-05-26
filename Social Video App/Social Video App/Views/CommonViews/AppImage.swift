//
//  AppImage.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import SwiftUI
import Kingfisher

struct AppImage: View {
    var url: String? = ""
    var label: String? = ""
    
    var size: CGFloat? = nil
    var width = 0.0
    var height = 0.0
    
    var cornerRadius = 0.0
    var shadowRadius = 0.0
    
    var labelFontSize : Font = .caption2
    var systemImageColor = Color.secondary
    
    var body: some View {
        KFImage.url(URL(string: url ?? "" ))
            .placeholder {
                getPlaceholderView()
            }
            .resizable()
            .frame(width: size ?? width, height: size ??  height)
            .cornerRadius(cornerRadius)
    }
    
    @ViewBuilder
    private func getPlaceholderView() -> some View {
        if let label = label, !label.isEmpty, let imageLabel = HelperFunctions.getNameAbbreviation(name: label), !imageLabel.isEmpty{
            RoundedRectangle(cornerRadius: cornerRadius)
                .frame(width: size ?? width, height: size ??  height)
                .foregroundColor(Color.imageBg)
                .overlay{
                    Text(imageLabel)
                        .font(labelFontSize)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 1.0)
                }
        } else {
            Image(systemName: "photo.fill")
                .foregroundColor(systemImageColor)
                .font(labelFontSize)
        }
    }
    
}
