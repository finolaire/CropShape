import UIKit

/// 裁剪形状。比例是宽比高。
public enum CropShapeKind: String, CaseIterable {
    case heart
    case square
    case portrait3x4
    case landscape4x3
    case portrait9x16
    case landscape16x9
    case circle
    case equilateralTriangle
    case octagon
    case fivePointStar
    case sixPointStar
    case cross
    case miCharacter
    case crescent
    case drop
    case arrow
    case cloud
    case bulb
    case balloon
    case sector
    case segment
    case ring
    case lightning
    case landscapeCapsule16x6
    case portraitCapsule6x16

    public var title: String {
        switch self {
        case .heart:
            return CropShapeL10n.text("heart")
        case .square:
            return CropShapeL10n.text("square")
        case .portrait3x4:
            return "3:4"
        case .landscape4x3:
            return "4:3"
        case .portrait9x16:
            return "9:16"
        case .landscape16x9:
            return "16:9"
        case .circle:
            return CropShapeL10n.text("circle")
        case .equilateralTriangle:
            return CropShapeL10n.text("triangle")
        case .octagon:
            return CropShapeL10n.text("octagon")
        case .fivePointStar:
            return CropShapeL10n.text("star")
        case .sixPointStar:
            return CropShapeL10n.text("hexagram")
        case .cross:
            return CropShapeL10n.text("cross")
        case .miCharacter:
            return CropShapeL10n.text("mi")
        case .crescent:
            return CropShapeL10n.text("crescent")
        case .drop:
            return CropShapeL10n.text("drop")
        case .arrow:
            return CropShapeL10n.text("arrow")
        case .cloud:
            return CropShapeL10n.text("cloud")
        case .bulb:
            return CropShapeL10n.text("bulb")
        case .balloon:
            return CropShapeL10n.text("balloon")
        case .sector:
            return CropShapeL10n.text("sector")
        case .segment:
            return CropShapeL10n.text("bow")
        case .ring:
            return CropShapeL10n.text("ring")
        case .lightning:
            return CropShapeL10n.text("lightning")
        case .landscapeCapsule16x6:
            return "16:6"
        case .portraitCapsule6x16:
            return "6:16"
        }
    }

    /// 宽 / 高。圆形的外接框是正方形。
    public var aspectRatio: CGFloat {
        switch self {
        case .heart:
            return 0.92
        case .square, .circle, .octagon:
            return 1
        case .fivePointStar:
            return 2 * cos(.pi / 10) / (1 + cos(.pi / 5))
        case .sixPointStar:
            return sqrt(3) / 2
        case .cross, .miCharacter:
            return 1
        case .crescent:
            let offset: CGFloat = 0.62
            let hornX = offset / 2
            let hornY = sqrt(1 - hornX * hornX)
            return (1 + hornX) / (2 * hornY)
        case .drop:
            return 0.68
        case .arrow:
            return 1.65
        case .cloud:
            return 1.8
        case .bulb:
            return 0.70
        case .balloon:
            return 0.60
        case .sector:
            return sqrt(2)
        case .ring:
            return 1
        case .segment:
            return 0.46
        case .lightning:
            return 0.58
        case .equilateralTriangle:
            return 2 / sqrt(3)
        case .portrait3x4:
            return 3.0 / 4.0
        case .landscape4x3:
            return 4.0 / 3.0
        case .portrait9x16:
            return 9.0 / 16.0
        case .landscape16x9:
            return 16.0 / 9.0
        case .landscapeCapsule16x6:
            return 16.0 / 6.0
        case .portraitCapsule6x16:
            return 6.0 / 16.0
        }
    }

    public var isCircle: Bool {
        self == .circle
    }

    var showsCropGrid: Bool {
        switch self {
        case .heart, .circle, .equilateralTriangle, .octagon, .fivePointStar, .sixPointStar, .cross, .miCharacter, .crescent, .drop, .arrow, .cloud, .bulb, .balloon, .sector, .segment, .ring, .lightning, .landscapeCapsule16x6, .portraitCapsule6x16:
            return false
        case .square, .portrait3x4, .landscape4x3, .portrait9x16, .landscape16x9:
            return true
        }
    }

    public func path(in rect: CGRect) -> UIBezierPath {
        switch self {
        case .heart:
            return heartPath(in: rect)
        case .circle:
            return UIBezierPath(ovalIn: rect)
        case .equilateralTriangle:
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.close()
            return path
        case .octagon:
            let cut = min(rect.width, rect.height) / (2 + sqrt(2))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.minX + cut, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cut))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cut))
            path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + cut, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cut))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cut))
            path.close()
            return path
        case .fivePointStar:
            return starPath(pointCount: 5, innerRatio: cos(2 * .pi / 5) / cos(.pi / 5), in: rect)
        case .sixPointStar:
            return starPath(pointCount: 6, innerRatio: 1 / sqrt(3), in: rect)
        case .cross:
            return crossPath(in: rect)
        case .miCharacter:
            return miCharacterPath(in: rect)
        case .crescent:
            return crescentPath(in: rect)
        case .drop:
            return dropPath(in: rect)
        case .arrow:
            return arrowPath(in: rect)
        case .cloud:
            return cloudPath(in: rect)
        case .bulb:
            return bulbPath(in: rect)
        case .balloon:
            return balloonPath(in: rect)
        case .sector:
            return sectorPath(in: rect)
        case .segment:
            return segmentPath(in: rect)
        case .ring:
            return ringPath(in: rect)
        case .lightning:
            return lightningPath(in: rect)
        case .landscapeCapsule16x6, .portraitCapsule6x16:
            let radius = min(rect.width, rect.height) / 2
            return UIBezierPath(roundedRect: rect, cornerRadius: radius)
        case .square, .portrait3x4, .landscape4x3, .portrait9x16, .landscape16x9:
            return UIBezierPath(rect: rect)
        }
    }
}

private final class CropShapeBundleToken {}

enum CropShapeL10n {
    static func text(_ key: String) -> String {
        NSLocalizedString(key, tableName: "Localizable", bundle: languageBundle, value: key, comment: "")
    }

    private static let languageBundle: Bundle = {
        let language = Locale.preferredLanguages.first?.hasPrefix("zh") == true ? "zh-Hans" : "en"
        guard let path = libraryBundle.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return libraryBundle
        }
        return bundle
    }()

    private static let libraryBundle: Bundle = {
        let framework = Bundle(for: CropShapeBundleToken.self)
        if let url = framework.url(forResource: "CropShape", withExtension: "bundle"),
           let bundle = Bundle(url: url) {
            return bundle
        }
        return framework
    }()
}

enum CropShapeRenderer {
    static func image(
        _ image: UIImage,
        displayedIn imageFrame: CGRect,
        cropRect: CGRect,
        kind: CropShapeKind
    ) -> UIImage {
        guard imageFrame.width > 1,
              imageFrame.height > 1,
              cropRect.width > 1,
              cropRect.height > 1,
              image.size.width > 0,
              image.size.height > 0 else {
            return image
        }

        let scaleX = image.size.width / imageFrame.width
        let scaleY = image.size.height / imageFrame.height
        let origin = CGPoint(
            x: (cropRect.minX - imageFrame.minX) * scaleX,
            y: (cropRect.minY - imageFrame.minY) * scaleY
        )
        let size = CGSize(width: cropRect.width * scaleX, height: cropRect.height * scaleY)

        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            let path = kind.path(in: CGRect(origin: .zero, size: size))
            context.cgContext.addPath(path.cgPath)
            context.cgContext.clip(using: path.usesEvenOddFillRule ? .evenOdd : .winding)
            image.draw(in: CGRect(
                x: -origin.x,
                y: -origin.y,
                width: image.size.width,
                height: image.size.height
            ))
        }
    }
}

func starPath(pointCount: Int, innerRatio: CGFloat, in rect: CGRect) -> UIBezierPath {
    var unitPoints: [CGPoint] = []
    for index in 0..<pointCount {
        let outerAngle = -CGFloat.pi / 2 + CGFloat(index) * 2 * .pi / CGFloat(pointCount)
        let innerAngle = outerAngle + .pi / CGFloat(pointCount)
        unitPoints.append(CGPoint(x: cos(outerAngle), y: sin(outerAngle)))
        unitPoints.append(CGPoint(x: innerRatio * cos(innerAngle), y: innerRatio * sin(innerAngle)))
    }

    let minX = unitPoints.map(\.x).min() ?? 0
    let maxX = unitPoints.map(\.x).max() ?? 1
    let minY = unitPoints.map(\.y).min() ?? 0
    let maxY = unitPoints.map(\.y).max() ?? 1
    let spanX = max(maxX - minX, 0.001)
    let spanY = max(maxY - minY, 0.001)

    let path = UIBezierPath()
    for (index, point) in unitPoints.enumerated() {
        let mapped = CGPoint(
            x: rect.minX + (point.x - minX) / spanX * rect.width,
            y: rect.minY + (point.y - minY) / spanY * rect.height
        )
        if index == 0 {
            path.move(to: mapped)
        } else {
            path.addLine(to: mapped)
        }
    }
    path.close()
    return path
}

func crossPath(in rect: CGRect) -> UIBezierPath {
    let thickness = min(rect.width, rect.height) / 3
    let path = UIBezierPath()
    path.move(to: CGPoint(x: rect.midX - thickness / 2, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.midX + thickness / 2, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.midX + thickness / 2, y: rect.midY - thickness / 2))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - thickness / 2))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY + thickness / 2))
    path.addLine(to: CGPoint(x: rect.midX + thickness / 2, y: rect.midY + thickness / 2))
    path.addLine(to: CGPoint(x: rect.midX + thickness / 2, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.midX - thickness / 2, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.midX - thickness / 2, y: rect.midY + thickness / 2))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.midY + thickness / 2))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.midY - thickness / 2))
    path.addLine(to: CGPoint(x: rect.midX - thickness / 2, y: rect.midY - thickness / 2))
    path.close()
    return path
}

func crescentPath(in rect: CGRect) -> UIBezierPath {
    let offset: CGFloat = 0.62
    let hornX = offset / 2
    let hornY = sqrt(max(1 - hornX * hornX, 0))
    let outerUpper = atan2(hornY, hornX)
    let outerLower = atan2(-hornY, hornX)
    let innerUpper = atan2(hornY, hornX - offset)
    let innerLower = atan2(-hornY, hornX - offset)

    var points = arcPoints(center: .zero, radius: 1, from: outerUpper, to: outerLower, clockwise: false, steps: 48)
    points.append(contentsOf: arcPoints(
        center: CGPoint(x: offset, y: 0),
        radius: 1,
        from: innerLower,
        to: innerUpper,
        clockwise: true,
        steps: 28
    ).dropFirst())
    let flipped = points.map { CGPoint(x: $0.x, y: -$0.y) }
    return pathFitting(flipped, in: rect)
}

func arcPoints(
    center: CGPoint,
    radius: CGFloat,
    from start: CGFloat,
    to end: CGFloat,
    clockwise: Bool,
    steps: Int
) -> [CGPoint] {
    var delta = end - start
    if clockwise {
        if delta > 0 { delta -= 2 * .pi }
    } else if delta < 0 {
        delta += 2 * .pi
    }
    return (0...steps).map { index in
        let angle = start + delta * CGFloat(index) / CGFloat(steps)
        return CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
    }
}

func dropPath(in rect: CGRect) -> UIBezierPath {
    let path = UIBezierPath()
    let radius = rect.width / 2
    let center = CGPoint(x: rect.midX, y: rect.maxY - radius)
    path.move(to: CGPoint(x: rect.midX, y: rect.minY))
    path.addCurve(
        to: CGPoint(x: rect.maxX, y: center.y),
        controlPoint1: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.34),
        controlPoint2: CGPoint(x: rect.maxX, y: center.y - radius * 0.2)
    )
    path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: .pi, clockwise: true)
    path.addCurve(
        to: CGPoint(x: rect.midX, y: rect.minY),
        controlPoint1: CGPoint(x: rect.minX, y: center.y - radius * 0.2),
        controlPoint2: CGPoint(x: rect.minX, y: rect.minY + rect.height * 0.34)
    )
    path.close()
    return path
}

func arrowPath(in rect: CGRect) -> UIBezierPath {
    func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
    }
    let path = UIBezierPath()
    path.move(to: point(0, 0.34))
    path.addLine(to: point(0.58, 0.34))
    path.addLine(to: point(0.58, 0.06))
    path.addLine(to: point(1, 0.5))
    path.addLine(to: point(0.58, 0.94))
    path.addLine(to: point(0.58, 0.66))
    path.addLine(to: point(0, 0.66))
    path.close()
    return path
}

func cloudPath(in rect: CGRect) -> UIBezierPath {
    func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
    }
    let path = UIBezierPath()
    path.move(to: point(0.16, 0.68))
    path.addQuadCurve(to: point(0.30, 0.40), controlPoint: point(0.05, 0.42))
    path.addQuadCurve(to: point(0.50, 0.18), controlPoint: point(0.32, 0.08))
    path.addQuadCurve(to: point(0.74, 0.36), controlPoint: point(0.70, 0.04))
    path.addQuadCurve(to: point(0.92, 0.64), controlPoint: point(0.98, 0.34))
    path.addQuadCurve(to: point(0.74, 0.86), controlPoint: point(1.0, 0.90))
    path.addQuadCurve(to: point(0.42, 0.84), controlPoint: point(0.58, 1.0))
    path.addQuadCurve(to: point(0.16, 0.68), controlPoint: point(0.10, 0.96))
    path.close()
    return path
}

func bulbPath(in rect: CGRect) -> UIBezierPath {
    let path = UIBezierPath()
    let midX = rect.midX
    let radius = rect.width * 0.48
    let center = CGPoint(x: midX, y: rect.minY + rect.height * 0.015 + radius)
    let neckHalf = rect.width * 0.24
    let shoulderDrop = sqrt(max(radius * radius - neckHalf * neckHalf, 0))
    let shoulderY = center.y + shoulderDrop
    let leftShoulder = CGPoint(x: midX - neckHalf, y: shoulderY)
    let rightShoulder = CGPoint(x: midX + neckHalf, y: shoulderY)

    path.move(to: leftShoulder)
    path.addArc(
        withCenter: center,
        radius: radius,
        startAngle: atan2(leftShoulder.y - center.y, leftShoulder.x - center.x),
        endAngle: atan2(rightShoulder.y - center.y, rightShoulder.x - center.x),
        clockwise: true
    )

    let capHalf = rect.width * 0.31
    let grooveHalf = rect.width * 0.24
    let capTop = shoulderY + rect.height * 0.04
    let tipRadius = rect.width * 0.13
    let capBottom = rect.maxY - tipRadius
    let span = max(capBottom - capTop, 0)
    let grooveH = span * 0.16
    let bandH = (span - grooveH * 2) / 3

    path.addQuadCurve(
        to: CGPoint(x: midX + capHalf, y: capTop),
        controlPoint: CGPoint(x: midX + neckHalf, y: capTop)
    )

    var y = capTop
    path.addLine(to: CGPoint(x: midX + capHalf, y: y + bandH))
    y += bandH
    path.addLine(to: CGPoint(x: midX + grooveHalf, y: y))
    path.addLine(to: CGPoint(x: midX + grooveHalf, y: y + grooveH))
    y += grooveH
    path.addLine(to: CGPoint(x: midX + capHalf, y: y))
    path.addLine(to: CGPoint(x: midX + capHalf, y: y + bandH))
    y += bandH
    path.addLine(to: CGPoint(x: midX + grooveHalf, y: y))
    path.addLine(to: CGPoint(x: midX + grooveHalf, y: y + grooveH))
    y += grooveH
    path.addLine(to: CGPoint(x: midX + capHalf, y: y))
    path.addLine(to: CGPoint(x: midX + capHalf, y: capBottom))
    path.addLine(to: CGPoint(x: midX + tipRadius, y: capBottom))
    path.addArc(
        withCenter: CGPoint(x: midX, y: capBottom),
        radius: tipRadius,
        startAngle: 0,
        endAngle: .pi,
        clockwise: true
    )
    path.addLine(to: CGPoint(x: midX - capHalf, y: capBottom))
    path.addLine(to: CGPoint(x: midX - capHalf, y: y))
    path.addLine(to: CGPoint(x: midX - grooveHalf, y: y))
    path.addLine(to: CGPoint(x: midX - grooveHalf, y: y - grooveH))
    y -= grooveH
    path.addLine(to: CGPoint(x: midX - capHalf, y: y))
    path.addLine(to: CGPoint(x: midX - capHalf, y: y - bandH))
    y -= bandH
    path.addLine(to: CGPoint(x: midX - grooveHalf, y: y))
    path.addLine(to: CGPoint(x: midX - grooveHalf, y: y - grooveH))
    y -= grooveH
    path.addLine(to: CGPoint(x: midX - capHalf, y: y))
    path.addLine(to: CGPoint(x: midX - capHalf, y: capTop))
    path.addQuadCurve(
        to: leftShoulder,
        controlPoint: CGPoint(x: midX - neckHalf, y: capTop)
    )
    path.close()
    return path
}

func balloonPath(in rect: CGRect) -> UIBezierPath {
    let path = UIBezierPath()
    let radius = rect.width * 0.45
    let center = CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.02 + radius)
    let neckHalf = rect.width * 0.08
    let neckDrop = sqrt(max(radius * radius - neckHalf * neckHalf, 0))
    let leftNeck = CGPoint(x: rect.midX - neckHalf, y: center.y + neckDrop)
    let rightNeck = CGPoint(x: rect.midX + neckHalf, y: center.y + neckDrop)

    let stringHalf = rect.width * 0.012
    let stringStart = CGPoint(x: rect.midX, y: center.y + radius + rect.height * 0.10)
    let stringEnd = CGPoint(x: rect.midX + rect.width * 0.05, y: rect.maxY - stringHalf)
    let stringControl = CGPoint(
        x: rect.midX + rect.width * 0.11,
        y: stringStart.y + (stringEnd.y - stringStart.y) * 0.55
    )
    let steps = 18
    let rightEdge = (0...steps).map { offset(CGFloat($0) / CGFloat(steps), by: stringHalf) }
    let leftEdge = (0...steps).map { offset(CGFloat($0) / CGFloat(steps), by: -stringHalf) }

    path.move(to: leftNeck)
    path.addArc(
        withCenter: center,
        radius: radius,
        startAngle: atan2(leftNeck.y - center.y, leftNeck.x - center.x),
        endAngle: atan2(rightNeck.y - center.y, rightNeck.x - center.x),
        clockwise: true
    )
    path.addQuadCurve(
        to: CGPoint(x: rect.midX + rect.width * 0.11, y: stringStart.y - rect.height * 0.04),
        controlPoint: CGPoint(x: rect.midX + neckHalf, y: rightNeck.y + rect.height * 0.025)
    )
    path.addQuadCurve(
        to: rightEdge[0],
        controlPoint: CGPoint(x: rect.midX + rect.width * 0.06, y: stringStart.y)
    )
    for edgePoint in rightEdge.dropFirst() {
        path.addLine(to: edgePoint)
    }
    let tipNormal = stringNormal(1)
    path.addArc(
        withCenter: stringEnd,
        radius: stringHalf,
        startAngle: atan2(tipNormal.y, tipNormal.x),
        endAngle: atan2(-tipNormal.y, -tipNormal.x),
        clockwise: true
    )
    for edgePoint in leftEdge.dropLast().reversed() {
        path.addLine(to: edgePoint)
    }
    path.addQuadCurve(
        to: CGPoint(x: rect.midX - rect.width * 0.11, y: stringStart.y - rect.height * 0.04),
        controlPoint: CGPoint(x: rect.midX - rect.width * 0.06, y: stringStart.y)
    )
    path.addQuadCurve(
        to: leftNeck,
        controlPoint: CGPoint(x: rect.midX - neckHalf, y: leftNeck.y + rect.height * 0.025)
    )
    path.close()
    return path

    func offset(_ t: CGFloat, by distance: CGFloat) -> CGPoint {
        let origin = stringPoint(t)
        let normal = stringNormal(t)
        return CGPoint(x: origin.x + normal.x * distance, y: origin.y + normal.y * distance)
    }

    func stringPoint(_ t: CGFloat) -> CGPoint {
        let u = 1 - t
        return CGPoint(
            x: u * u * stringStart.x + 2 * u * t * stringControl.x + t * t * stringEnd.x,
            y: u * u * stringStart.y + 2 * u * t * stringControl.y + t * t * stringEnd.y
        )
    }

    func stringNormal(_ t: CGFloat) -> CGPoint {
        let u = 1 - t
        let tangent = CGPoint(
            x: 2 * u * (stringControl.x - stringStart.x) + 2 * t * (stringEnd.x - stringControl.x),
            y: 2 * u * (stringControl.y - stringStart.y) + 2 * t * (stringEnd.y - stringControl.y)
        )
        let length = max(hypot(tangent.x, tangent.y), 0.001)
        return CGPoint(x: tangent.y / length, y: -tangent.x / length)
    }
}

func pathFitting(_ points: [CGPoint], in rect: CGRect) -> UIBezierPath {
    let minX = points.map(\.x).min() ?? 0
    let maxX = points.map(\.x).max() ?? 1
    let minY = points.map(\.y).min() ?? 0
    let maxY = points.map(\.y).max() ?? 1
    let spanX = max(maxX - minX, 0.001)
    let spanY = max(maxY - minY, 0.001)
    let path = UIBezierPath()
    for (index, point) in points.enumerated() {
        let mapped = CGPoint(
            x: rect.minX + (point.x - minX) / spanX * rect.width,
            y: rect.minY + (point.y - minY) / spanY * rect.height
        )
        if index == 0 {
            path.move(to: mapped)
        } else {
            path.addLine(to: mapped)
        }
    }
    path.close()
    return path
}

func sectorPath(in rect: CGRect) -> UIBezierPath {
    let center = CGPoint(x: rect.midX, y: rect.maxY)
    let path = UIBezierPath()
    path.move(to: center)
    path.addArc(
        withCenter: center,
        radius: rect.height,
        startAngle: -3 * .pi / 4,
        endAngle: -.pi / 4,
        clockwise: true
    )
    path.close()
    return path
}

func segmentPath(in rect: CGRect) -> UIBezierPath {
    let path = UIBezierPath()
    let stringX = rect.minX + rect.width * 0.06
    let top = CGPoint(x: stringX, y: rect.minY)
    let bottom = CGPoint(x: stringX, y: rect.maxY)
    path.move(to: top)
    path.addLine(to: bottom)
    path.addCurve(
        to: top,
        controlPoint1: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.18),
        controlPoint2: CGPoint(x: rect.maxX, y: rect.minY + rect.height * 0.18)
    )
    path.close()
    return path
}

func ringPath(in rect: CGRect) -> UIBezierPath {
    let side = min(rect.width, rect.height)
    let outerRect = CGRect(
        x: rect.midX - side / 2,
        y: rect.midY - side / 2,
        width: side,
        height: side
    )
    let innerSide = side * 0.56
    let innerRect = CGRect(
        x: rect.midX - innerSide / 2,
        y: rect.midY - innerSide / 2,
        width: innerSide,
        height: innerSide
    )
    let path = UIBezierPath(ovalIn: outerRect)
    path.append(UIBezierPath(ovalIn: innerRect))
    path.usesEvenOddFillRule = true
    return path
}

func heartPath(in rect: CGRect) -> UIBezierPath {
    func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
    }
    let path = UIBezierPath()
    path.move(to: point(0.50, 0.93))
    path.addCurve(
        to: point(0.02, 0.34),
        controlPoint1: point(0.10, 0.74),
        controlPoint2: point(0.0, 0.52)
    )
    path.addCurve(
        to: point(0.50, 0.20),
        controlPoint1: point(0.04, 0.10),
        controlPoint2: point(0.28, 0.02)
    )
    path.addCurve(
        to: point(0.98, 0.34),
        controlPoint1: point(0.72, 0.02),
        controlPoint2: point(0.96, 0.10)
    )
    path.addCurve(
        to: point(0.50, 0.93),
        controlPoint1: point(1.0, 0.52),
        controlPoint2: point(0.90, 0.74)
    )
    path.close()
    return path
}

func lightningPath(in rect: CGRect) -> UIBezierPath {
    func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: rect.minX + rect.width * x, y: rect.minY + rect.height * y)
    }
    let path = UIBezierPath()
    path.move(to: point(0.58, 0.0))
    path.addLine(to: point(0.18, 0.46))
    path.addLine(to: point(0.46, 0.46))
    path.addLine(to: point(0.28, 1.0))
    path.addLine(to: point(0.86, 0.42))
    path.addLine(to: point(0.54, 0.42))
    path.addLine(to: point(0.78, 0.0))
    path.close()
    return path
}

func miCharacterPath(in rect: CGRect) -> UIBezierPath {
    let halfThickness: CGFloat = 0.16
    var unitPoints: [CGPoint] = []
    for index in 0..<8 {
        let theta = -CGFloat.pi / 2 + CGFloat(index) * .pi / 4
        let next = theta + .pi / 4
        let radius: CGFloat = index.isMultiple(of: 2) ? 1 : sqrt(2)
        let dir = CGPoint(x: cos(theta), y: sin(theta))
        let right = CGPoint(x: -sin(theta), y: cos(theta))
        let dirNext = CGPoint(x: cos(next), y: sin(next))
        let rightNext = CGPoint(x: -sin(next), y: cos(next))
        unitPoints.append(CGPoint(
            x: dir.x * radius - right.x * halfThickness,
            y: dir.y * radius - right.y * halfThickness
        ))
        unitPoints.append(CGPoint(
            x: dir.x * radius + right.x * halfThickness,
            y: dir.y * radius + right.y * halfThickness
        ))
        if let corner = lineIntersection(
            point: CGPoint(x: right.x * halfThickness, y: right.y * halfThickness),
            direction: dir,
            otherPoint: CGPoint(x: -rightNext.x * halfThickness, y: -rightNext.y * halfThickness),
            otherDirection: dirNext
        ) {
            unitPoints.append(corner)
        }
    }
    return pathFitting(unitPoints, in: rect)
}

func lineIntersection(point: CGPoint, direction: CGPoint, otherPoint: CGPoint, otherDirection: CGPoint) -> CGPoint? {
    let determinant = direction.x * otherDirection.y - direction.y * otherDirection.x
    guard abs(determinant) > 0.0001 else { return nil }
    let dx = otherPoint.x - point.x
    let dy = otherPoint.y - point.y
    let distance = (dx * otherDirection.y - dy * otherDirection.x) / determinant
    return CGPoint(x: point.x + direction.x * distance, y: point.y + direction.y * distance)
}

func rectFitting(aspectRatio: CGFloat, in bounds: CGRect) -> CGRect {
    guard bounds.width > 1, bounds.height > 1, aspectRatio > 0 else {
        return .zero
    }
    var width = bounds.width
    var height = width / aspectRatio
    if height > bounds.height {
        height = bounds.height
        width = height * aspectRatio
    }
    return CGRect(
        x: bounds.midX - width / 2,
        y: bounds.midY - height / 2,
        width: width,
        height: height
    )
}
