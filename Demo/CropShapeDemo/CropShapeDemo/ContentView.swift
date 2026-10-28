//
//  ContentView.swift
//  CropShapeDemo
//
//  Created by apple2026 on 2026/10/27.
//

import CropShape
import Photos
import PhotosUI
import SwiftUI

struct ContentView: View {
    @State private var pickerItem: PhotosPickerItem?
    @State private var sourceImage: UIImage?
    @State private var croppedImage: UIImage?
    @State private var isCropping = false
    @State private var isSaving = false
    @State private var alertMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ZStack {
                    if let croppedImage {
                        Image(uiImage: croppedImage)
                            .resizable()
                            .scaledToFit()
                            .background(TransparencyBackground())
                            .aspectRatio(croppedImage.size, contentMode: .fit)
                            .padding(24)
                    } else {
                        ContentUnavailableView(
                            DemoL10n.text(
                                "选择一张图片",
                                "Choose a Photo"
                            ),
                            systemImage: "photo",
                            description: Text(DemoL10n.text(
                                "打开裁剪后，可以移动、缩放，并按底部的形状裁切。棋盘格表示透明区域。",
                                "Pan and zoom, then crop with a shape from the bar. The checkerboard shows transparency."
                            ))
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if croppedImage != nil {
                    Button {
                        saveCroppedImage()
                    } label: {
                        Text(isSaving ? DemoL10n.text("正在保存…", "Saving…") : DemoL10n.text("保存到相册", "Save to Photos"))
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isSaving)
                }

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Text(croppedImage == nil ? DemoL10n.text("选择图片", "Choose Photo") : DemoL10n.text("重新选择", "Choose Again"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(croppedImage == nil ? Color.accentColor : Color.clear)
                        .foregroundStyle(croppedImage == nil ? Color.white : Color.accentColor)
                        .overlay {
                            if croppedImage != nil {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
            .navigationTitle("CropShape")
            .alert(DemoL10n.text("提示", "Notice"), isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Button(DemoL10n.text("好", "OK"), role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
            .onChange(of: pickerItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    defer { pickerItem = nil }
                    guard let data = try? await newItem.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else {
                        return
                    }
                    sourceImage = image
                    isCropping = true
                }
            }
            .fullScreenCover(isPresented: $isCropping) {
                if let sourceImage {
                    CropShapeEditor(
                        image: sourceImage,
                        onCancel: { isCropping = false },
                        onCrop: { image in
                            croppedImage = image
                            isCropping = false
                        }
                    )
                    .ignoresSafeArea()
                }
            }
        }
    }

    private func saveCroppedImage() {
        guard let croppedImage, let data = croppedImage.pngData() else {
            alertMessage = DemoL10n.text("无法保存这张图片。", "This image can't be saved.")
            return
        }
        isSaving = true
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    isSaving = false
                    alertMessage = DemoL10n.text(
                        "没有相册权限，请在系统设置中允许添加照片。",
                        "Photos access is off. Allow adding photos in Settings."
                    )
                }
                return
            }
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: data, options: nil)
            } completionHandler: { success, _ in
                DispatchQueue.main.async {
                    isSaving = false
                    alertMessage = success
                        ? DemoL10n.text("已保存到相册。", "Saved to Photos.")
                        : DemoL10n.text("保存失败，请重试。", "Couldn't save. Try again.")
                }
            }
        }
    }
}

private enum DemoL10n {
    static func text(_ chinese: String, _ english: String) -> String {
        Locale.preferredLanguages.first?.hasPrefix("zh") == true ? chinese : english
    }
}

private struct TransparencyBackground: View {
    var body: some View {
        Canvas { context, size in
            let tile: CGFloat = 10
            var row = 0
            var y: CGFloat = 0
            while y < size.height {
                var column = 0
                var x: CGFloat = 0
                while x < size.width {
                    let color = (row + column).isMultiple(of: 2) ? Color.white : Color(white: 0.82)
                    context.fill(Path(CGRect(x: x, y: y, width: tile, height: tile)), with: .color(color))
                    x += tile
                    column += 1
                }
                y += tile
                row += 1
            }
        }
    }
}

#Preview {
    ContentView()
}
