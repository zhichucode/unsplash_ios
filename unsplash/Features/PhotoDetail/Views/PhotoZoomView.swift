//
//  PhotoZoomView.swift
//  unsplash
//
//  Zoomable photo view with pinch and pan gestures
//

import SwiftUI

struct PhotoZoomView: View {
    let photo: Photo
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @GestureState private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            AsyncImageView(url: URL(string: photo.urls.regular ?? ""))
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .scaleEffect(scale)
                .offset(x: offset.width, y: offset.height)
                .gesture(
                    SimultaneousGesture(
                        // Magnification gesture for zoom
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                scale = min(max(scale * delta, 1), 4)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                                if scale < 1.2 {
                                    withAnimation(.spring()) {
                                        scale = 1.0
                                        offset = .zero
                                    }
                                }
                            },

                        // Drag gesture for panning
                        DragGesture()
                            .onChanged { value in
                                let newOffset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )

                                // Limit panning when zoomed in
                                if scale > 1 {
                                    offset = newOffset
                                }
                            }
                            .onEnded { _ in
                                if scale <= 1 {
                                    withAnimation(.spring()) {
                                        offset = .zero
                                    }
                                }
                                lastOffset = offset
                            }
                    )
                )
                .onTapGesture(count: 2) {
                    // Double tap to reset zoom
                    withAnimation(.spring()) {
                        if scale > 1 {
                            scale = 1.0
                            offset = .zero
                        } else {
                            scale = 2.0
                        }
                    }
                }
                .background(Color.black)
        }
    }
}

// Preview
#Preview {
    let mockPhoto = Photo.generateMockPhotos(count: 1).first!
    PhotoZoomView(photo: mockPhoto)
}
