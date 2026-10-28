import UIKit
import SwiftUI

/// 裁剪界面。单指移动图片，双指缩放。完成后形状以外的像素是透明的。
public final class CropShapeViewController: UIViewController {
    public var onCancel: (() -> Void)?
    public var onCrop: ((UIImage) -> Void)?

    private let image: UIImage
    private var selectedKind: CropShapeKind
    private var scale: CGFloat = 1
    private var translation: CGPoint = .zero
    private var pinchAnchorScale: CGFloat = 1
    private var panAnchorTranslation: CGPoint = .zero
    private var cropRect: CGRect = .zero
    private var shouldAnimateShape = false

    private let topBar = UIView()
    private let bottomBar = UIView()
    private let canvasView = UIView()
    private let imageView = UIImageView()
    private let overlayView = CropOverlayView()
    private let horizontalScroll = UIScrollView()
    private let horizontalStack = UIStackView()
    private let gridScroll = UIScrollView()
    private let gridStack = UIStackView()
    private let expandButton = UIButton(type: .system)
    private var bottomBarHeightConstraint: NSLayoutConstraint?
    private var stripWidthConstraints: [NSLayoutConstraint] = []
    private var isShapePanelExpanded = false
    private var shapeButtons: [ShapeButton] = []

    private let collapsedStripHeight: CGFloat = 88
    private let shapeRowHeight: CGFloat = 76
    private let shapeGridSpacing: CGFloat = 8
    private let shapeColumns = 5
    private let expandedShapeRows = 4

    public init(image: UIImage, kind: CropShapeKind = .square) {
        self.image = image
        self.selectedKind = kind
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = .black
        configureChrome()
        configureShapeBar()
        configureCanvas()
        view.bringSubviewToFront(bottomBar)
        view.bringSubviewToFront(expandButton)
        updateSelection()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshCropLayout(animated: shouldAnimateShape)
        shouldAnimateShape = false
    }

    private func refreshCropLayout(animated: Bool) {
        guard canvasView.bounds.width > 1, canvasView.bounds.height > 1 else { return }
        cropRect = rectFitting(
            aspectRatio: selectedKind.aspectRatio,
            in: canvasView.bounds.insetBy(dx: 24, dy: 20)
        )
        layoutImage()
        overlayView.update(cropRect: cropRect, kind: selectedKind, animated: animated)
    }

    private func configureChrome() {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle(CropShapeL10n.text("cancel"), for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        let cropButton = UIButton(type: .system)
        cropButton.setTitle(CropShapeL10n.text("crop"), for: .normal)
        cropButton.setTitleColor(.systemYellow, for: .normal)
        cropButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        cropButton.addTarget(self, action: #selector(cropTapped), for: .touchUpInside)

        [topBar, cancelButton, cropButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(topBar)
        topBar.addSubview(cancelButton)
        topBar.addSubview(cropButton)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 52),
            cancelButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 16),
            cancelButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            cropButton.trailingAnchor.constraint(equalTo: topBar.trailingAnchor, constant: -16),
            cropButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor)
        ])
    }

    private func configureCanvas() {
        canvasView.backgroundColor = .black
        canvasView.clipsToBounds = true
        imageView.image = image
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = false
        overlayView.isUserInteractionEnabled = false

        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        canvasView.addSubview(imageView)
        canvasView.addSubview(overlayView)
        overlayView.frame = canvasView.bounds
        overlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.delegate = self
        canvasView.addGestureRecognizer(pan)
        canvasView.addGestureRecognizer(pinch)

        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -collapsedStripHeight
            )
        ])
    }

    private func configureShapeBar() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)

        bottomBar.backgroundColor = .black

        expandButton.tintColor = .white
        expandButton.backgroundColor = UIColor(white: 0.22, alpha: 1)
        expandButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        expandButton.accessibilityLabel = CropShapeL10n.text("expand")
        expandButton.layer.cornerRadius = 18
        expandButton.clipsToBounds = true
        expandButton.addTarget(self, action: #selector(expandTapped), for: .touchUpInside)
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(expandButton)

        horizontalScroll.showsHorizontalScrollIndicator = false
        horizontalScroll.alwaysBounceHorizontal = true
        horizontalScroll.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(horizontalScroll)

        horizontalStack.axis = .horizontal
        horizontalStack.alignment = .center
        horizontalStack.spacing = 6
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        horizontalScroll.addSubview(horizontalStack)

        gridScroll.showsVerticalScrollIndicator = true
        gridScroll.alwaysBounceVertical = true
        gridScroll.isHidden = true
        gridScroll.translatesAutoresizingMaskIntoConstraints = false
        bottomBar.addSubview(gridScroll)

        gridStack.axis = .vertical
        gridStack.alignment = .fill
        gridStack.spacing = shapeGridSpacing
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        gridScroll.addSubview(gridStack)

        shapeButtons = CropShapeKind.allCases.map { kind in
            let button = ShapeButton(kind: kind)
            button.addTarget(self, action: #selector(shapeTapped(_:)), for: .touchUpInside)
            return button
        }
        placeShapeButtons(expanded: false)

        let heightConstraint = bottomBar.heightAnchor.constraint(equalToConstant: collapsedStripHeight)
        bottomBarHeightConstraint = heightConstraint
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            heightConstraint,
            expandButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            expandButton.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: -10),
            expandButton.widthAnchor.constraint(equalToConstant: 36),
            expandButton.heightAnchor.constraint(equalToConstant: 36),
            horizontalScroll.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            horizontalScroll.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
            horizontalScroll.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
            horizontalScroll.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),
            horizontalStack.topAnchor.constraint(equalTo: horizontalScroll.contentLayoutGuide.topAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: horizontalScroll.contentLayoutGuide.bottomAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: horizontalScroll.contentLayoutGuide.leadingAnchor, constant: 12),
            horizontalStack.trailingAnchor.constraint(equalTo: horizontalScroll.contentLayoutGuide.trailingAnchor, constant: -12),
            horizontalStack.heightAnchor.constraint(equalTo: horizontalScroll.frameLayoutGuide.heightAnchor),
            gridScroll.topAnchor.constraint(equalTo: bottomBar.topAnchor),
            gridScroll.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor),
            gridScroll.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor),
            gridScroll.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),
            gridStack.topAnchor.constraint(equalTo: gridScroll.contentLayoutGuide.topAnchor, constant: 4),
            gridStack.bottomAnchor.constraint(equalTo: gridScroll.contentLayoutGuide.bottomAnchor, constant: -8),
            gridStack.leadingAnchor.constraint(equalTo: gridScroll.contentLayoutGuide.leadingAnchor, constant: 12),
            gridStack.trailingAnchor.constraint(equalTo: gridScroll.contentLayoutGuide.trailingAnchor, constant: -12),
            gridStack.widthAnchor.constraint(equalTo: gridScroll.frameLayoutGuide.widthAnchor, constant: -24)
        ])
    }

    private var expandedShapePanelHeight: CGFloat {
        let rows = CGFloat(expandedShapeRows)
        return rows * shapeRowHeight + (rows - 1) * shapeGridSpacing + 12
    }

    private func placeShapeButtons(expanded: Bool) {
        NSLayoutConstraint.deactivate(stripWidthConstraints)
        stripWidthConstraints.removeAll()
        shapeButtons.forEach { $0.removeFromSuperview() }
        gridStack.arrangedSubviews.forEach { row in
            gridStack.removeArrangedSubview(row)
            row.removeFromSuperview()
        }

        if expanded {
            var row: UIStackView?
            for (index, button) in shapeButtons.enumerated() {
                if index.isMultiple(of: shapeColumns) {
                    let newRow = UIStackView()
                    newRow.axis = .horizontal
                    newRow.alignment = .center
                    newRow.distribution = .fillEqually
                    newRow.spacing = 6
                    newRow.translatesAutoresizingMaskIntoConstraints = false
                    newRow.heightAnchor.constraint(equalToConstant: shapeRowHeight).isActive = true
                    gridStack.addArrangedSubview(newRow)
                    row = newRow
                }
                row?.addArrangedSubview(button)
            }
            if let row {
                let missing = shapeColumns - row.arrangedSubviews.count
                for _ in 0..<missing {
                    row.addArrangedSubview(UIView())
                }
            }
        } else {
            for button in shapeButtons {
                horizontalStack.addArrangedSubview(button)
                let width = button.widthAnchor.constraint(equalToConstant: 68)
                width.isActive = true
                stripWidthConstraints.append(width)
            }
        }
    }

    @objc private func expandTapped() {
        isShapePanelExpanded.toggle()
        let expanded = isShapePanelExpanded
        expandButton.setImage(UIImage(systemName: expanded ? "chevron.down" : "chevron.up"), for: .normal)
        expandButton.accessibilityLabel = CropShapeL10n.text(expanded ? "collapse" : "expand")
        horizontalScroll.isHidden = expanded
        gridScroll.isHidden = !expanded
        placeShapeButtons(expanded: expanded)
        bottomBarHeightConstraint?.constant = expanded ? expandedShapePanelHeight : collapsedStripHeight
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }

    private func updateSelection() {
        for button in shapeButtons {
            button.isChosen = button.kind == selectedKind
        }
    }

    private func imageDisplaySize() -> CGSize {
        guard image.size.width > 0, image.size.height > 0, cropRect.width > 1, cropRect.height > 1 else {
            return .zero
        }
        let cover = max(cropRect.width / image.size.width, cropRect.height / image.size.height)
        return CGSize(width: image.size.width * cover * scale, height: image.size.height * cover * scale)
    }

    private func layoutImage() {
        let size = imageDisplaySize()
        guard size.width > 1, size.height > 1 else { return }
        let maxX = max(0, (size.width - cropRect.width) / 2)
        let maxY = max(0, (size.height - cropRect.height) / 2)
        translation.x = min(max(translation.x, -maxX), maxX)
        translation.y = min(max(translation.y, -maxY), maxY)
        imageView.bounds = CGRect(origin: .zero, size: size)
        imageView.center = CGPoint(x: cropRect.midX + translation.x, y: cropRect.midY + translation.y)
    }

    private func applyZoom(to newScale: CGFloat, around location: CGPoint) {
        let oldScale = max(scale, 0.01)
        let factor = newScale / oldScale
        let imageCenter = CGPoint(x: cropRect.midX + translation.x, y: cropRect.midY + translation.y)
        let vector = CGPoint(x: location.x - imageCenter.x, y: location.y - imageCenter.y)
        let newCenter = CGPoint(x: location.x - vector.x * factor, y: location.y - vector.y * factor)
        translation = CGPoint(x: newCenter.x - cropRect.midX, y: newCenter.y - cropRect.midY)
        scale = newScale
        layoutImage()
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            panAnchorTranslation = translation
        case .changed:
            let delta = gesture.translation(in: canvasView)
            translation = CGPoint(x: panAnchorTranslation.x + delta.x, y: panAnchorTranslation.y + delta.y)
            layoutImage()
        default:
            break
        }
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            pinchAnchorScale = scale
        case .changed:
            let proposed = pinchAnchorScale * gesture.scale
            let newScale = min(max(proposed, 1), 6)
            applyZoom(to: newScale, around: gesture.location(in: canvasView))
        default:
            break
        }
    }

    @objc private func shapeTapped(_ sender: UIControl) {
        guard let button = sender as? ShapeButton, button.kind != selectedKind else { return }
        selectedKind = button.kind
        updateSelection()
        refreshCropLayout(animated: true)
    }

    @objc private func cancelTapped() {
        onCancel?()
    }

    @objc private func cropTapped() {
        let result = CropShapeRenderer.image(
            image,
            displayedIn: imageView.frame,
            cropRect: cropRect,
            kind: selectedKind
        )
        onCrop?(result)
    }
}

extension CropShapeViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}

/// SwiftUI 入口。Demo 或宿主 App 选好图片后打开这个界面。
public struct CropShapeEditor: UIViewControllerRepresentable {
    let image: UIImage
    let kind: CropShapeKind
    let onCancel: () -> Void
    let onCrop: (UIImage) -> Void

    public init(
        image: UIImage,
        kind: CropShapeKind = .square,
        onCancel: @escaping () -> Void,
        onCrop: @escaping (UIImage) -> Void
    ) {
        self.image = image
        self.kind = kind
        self.onCancel = onCancel
        self.onCrop = onCrop
    }

    public func makeUIViewController(context: Context) -> CropShapeViewController {
        let controller = CropShapeViewController(image: image, kind: kind)
        controller.onCancel = onCancel
        controller.onCrop = onCrop
        return controller
    }

    public func updateUIViewController(_ uiViewController: CropShapeViewController, context: Context) {
        uiViewController.onCancel = onCancel
        uiViewController.onCrop = onCrop
    }
}

private final class ShapeButton: UIControl {
    let kind: CropShapeKind
    private let nameLabel = UILabel()

    init(kind: CropShapeKind) {
        self.kind = kind
        super.init(frame: .zero)
        let iconView = UIImageView(image: ShapeIcon.image(for: kind))
        iconView.contentMode = .scaleAspectFit
        nameLabel.text = kind.title
        nameLabel.font = .systemFont(ofSize: 12)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.7
        nameLabel.lineBreakMode = .byTruncatingTail

        let stack = UIStackView(arrangedSubviews: [iconView, nameLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 2),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -2),
            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),
            heightAnchor.constraint(equalToConstant: 72)
        ])
        layer.cornerRadius = 10
        isChosen = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isChosen: Bool = false {
        didSet {
            backgroundColor = isChosen ? UIColor.white.withAlphaComponent(0.2) : .clear
            nameLabel.textColor = isChosen ? .systemYellow : .white
        }
    }
}

private enum ShapeIcon {
    static func image(for kind: CropShapeKind) -> UIImage {
        let canvas = CGSize(width: 26, height: 26)
        return UIGraphicsImageRenderer(size: canvas).image { _ in
            let fitted = rectFitting(
                aspectRatio: kind.aspectRatio,
                in: CGRect(origin: .zero, size: canvas).insetBy(dx: 1.5, dy: 1.5)
            )
            let path = kind.path(in: fitted)
            UIColor.white.setStroke()
            path.lineWidth = 1.5
            path.stroke()
        }
    }
}

private final class CropOverlayView: UIView {
    private let dimView = UIView()
    private let maskLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    private let gridLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        dimView.frame = bounds
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        maskLayer.fillRule = .evenOdd
        dimView.layer.mask = maskLayer
        addSubview(dimView)

        borderLayer.fillColor = nil
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineWidth = 1.5
        layer.addSublayer(borderLayer)

        gridLayer.fillColor = nil
        gridLayer.strokeColor = UIColor.white.withAlphaComponent(0.7).cgColor
        gridLayer.lineWidth = 0.5
        layer.addSublayer(gridLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(cropRect: CGRect, kind: CropShapeKind, animated: Bool) {
        guard cropRect.width > 1, cropRect.height > 1 else { return }
        let hole = kind.path(in: cropRect)
        let path = UIBezierPath(rect: bounds)
        path.append(hole)
        path.usesEvenOddFillRule = true

        if animated {
            animate(layer: maskLayer, key: "path", to: path.cgPath)
            animate(layer: borderLayer, key: "path", to: hole.cgPath)
        }
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        borderLayer.frame = bounds
        borderLayer.path = hole.cgPath
        gridLayer.frame = bounds
        gridLayer.isHidden = !kind.showsCropGrid
        gridLayer.path = kind.showsCropGrid ? gridPath(in: cropRect).cgPath : nil
    }

    private func gridPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        for index in 1...2 {
            let x = rect.minX + rect.width / 3 * CGFloat(index)
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            let y = rect.minY + rect.height / 3 * CGFloat(index)
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        return path
    }

    private func animate(layer: CAShapeLayer, key: String, to path: CGPath) {
        guard let from = layer.path else { return }
        let animation = CABasicAnimation(keyPath: key)
        animation.fromValue = from
        animation.toValue = path
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: key)
    }
}
