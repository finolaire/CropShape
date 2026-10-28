# CropShape

[English](README.en.md)

把一张图片裁成指定形状。形状以外的区域是透明的。界面跟随系统语言：首选语言为中文时显示中文，否则显示英文。

<p align="center">
  <img src="demo1.jpeg" width="250" alt="裁剪界面：单指移动、双指缩放，底部选择形状" />
  <img src="demo2.jpeg" width="250" alt="裁剪结果：五角星以外是透明的，棋盘格表示透明区域" />
</p>

要求 iOS 13 及以上。

## 安装

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'CropShape', '2.0.0'
end
```

然后执行：

```bash
pod install --repo-update
```

用生成的 `.xcworkspace` 打开工程。

## SwiftUI

选好图片后，全屏打开裁剪界面。单指移动，双指缩放（1–6 倍，图片始终盖住裁剪框）。点「裁剪」后，`onCrop` 拿到带透明通道的 `UIImage`。

```swift
import CropShape
import SwiftUI

struct EditorScreen: View {
    let source: UIImage
    @Binding var isPresented: Bool
    @Binding var cropped: UIImage?

    var body: some View {
        CropShapeEditor(
            image: source,
            kind: .circle,
            onCancel: { isPresented = false },
            onCrop: { image in
                cropped = image
                isPresented = false
            }
        )
        .ignoresSafeArea()
    }
}
```

`kind` 只决定打开时的初始形状。用户仍可在底部切换其他形状。

保存时使用 PNG，透明区域才会保留：

```swift
let data = cropped.pngData()
```

## UIKit

```swift
import CropShape

let editor = CropShapeViewController(image: image, kind: .heart)
editor.onCancel = { editor.dismiss(animated: true) }
editor.onCrop = { image in
    self.croppedImage = image
    editor.dismiss(animated: true)
}
present(editor, animated: true)
```

控制器自己是全屏弹出。

## 形状

`CropShapeKind` 是 `CaseIterable`。`title` 是当前语言下的名称，`aspectRatio` 是宽高比，`path(in:)` 返回该形状在给定矩形里的路径。

| 形状 | 说明 |
| --- | --- |
| `heart` | 爱心 |
| `square` | 正方形 |
| `portrait3x4` / `landscape4x3` | 3:4、4:3 |
| `portrait9x16` / `landscape16x9` | 9:16、16:9 |
| `circle` | 圆形 |
| `equilateralTriangle` | 等边三角形 |
| `octagon` | 八边形 |
| `fivePointStar` / `sixPointStar` | 五角星、六芒星 |
| `cross` / `miCharacter` | 十字、米字 |
| `crescent` / `drop` / `arrow` / `cloud` | 月牙、水滴、箭头、云朵 |
| `bulb` / `balloon` | 灯泡、气球 |
| `sector` / `segment` / `ring` | 扇形、弓形、圆环 |
| `lightning` | 闪电 |
| `landscapeCapsule16x6` / `portraitCapsule6x16` | 横向 16:6、纵向 6:16 胶囊 |

矩形形状会显示三分网格。圆环的内孔也是透明的。

## Demo

`Demo/CropShapeDemo` 通过本地路径引用当前仓库：

```ruby
pod 'CropShape', :path => '../..'
```

用 `Demo/CropShapeDemo/CropShapeDemo.xcworkspace` 打开。修改 `Sources` 或 `Resources` 后重新编译即可；新增 Swift 文件时需要再执行一次 `pod install`。

## 许可证

MIT
