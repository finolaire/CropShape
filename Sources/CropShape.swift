import UIKit

public enum CropShape {
    public static func crop(_ image: UIImage, to path: UIBezierPath) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            path.addClip()
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }
}
