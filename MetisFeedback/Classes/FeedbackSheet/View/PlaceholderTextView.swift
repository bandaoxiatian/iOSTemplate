//
//  PlaceholderTextView.swift
//  MetisFeedback
//
//  Created by Lyon on 2022/7/22.
//

import Foundation
import MetisLego

final class PlaceholderTextView: UITextView {
    @ObservableProperty
    var placeholder: NSString = ""

    @ObservableProperty
    var placeholderColor: UIColor = .black

    private var showPlaceholder = true

    override var font: UIFont? {
        didSet {
            setNeedsDisplay()
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        self.$placeholder.subscribeNext { [weak self]_ in
            self?.setNeedsDisplay()
        }
        self.$placeholderColor.subscribeNext {[weak self] _ in
            self?.setNeedsDisplay()
        }
        self.rx.text.orEmpty.changed.subscribeNext { [weak self] text in
            if !text.isEmpty {
                self?.showPlaceholder = false
            } else {
                self?.showPlaceholder = true
            }
            self?.setNeedsDisplay()
        }
        self.rx.attributedText.changed.subscribeNext { [weak self] attrText in
            if let text = attrText?.string, !text.isEmpty {
                self?.showPlaceholder = false
            } else {
                self?.showPlaceholder = true
            }
            self?.setNeedsDisplay()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.font] = self.font
        attributes[.foregroundColor] = self.placeholderColor
        let string = showPlaceholder ? placeholder : ""
        string.draw(in: CGRect(x: 5, y: 8, width: max(self.width, 100), height: 50), withAttributes: attributes)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
}
