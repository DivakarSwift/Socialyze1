//
//  TextViewAutoHeight.swift
//  TextViewAutoHeightDemo
//
//  Created by Salem Khan on 5/3/17.
//  Copyright (c) 2017 Salem Khan. All rights reserved.
//
import UIKit

class TextViewAutoHeight: UITextView {
    lazy var placeholderLabel: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.frame.origin.x = 5
        label.textColor = UIColor.lightGray
        self.addSubview(label)
        return label
    }()
    
    //MARK: attributes
    var  maxHeight:CGFloat?
    var  heightConstraint:NSLayoutConstraint?
    
    //MARK: initialize
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpInit()
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setUpInit()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpConstraint()
    }
    
    //MARK: private
    
    private func setUpInit() {
        self.delegate = self
        for constraint in self.constraints {
            if constraint.firstAttribute == NSLayoutAttribute.height {
                self.heightConstraint = constraint;
                break;
            }
        }
        
    }
    
    private func setUpConstraint() {
        var finalContentSize:CGSize = self.contentSize
        finalContentSize.width  += (self.textContainerInset.left + self.textContainerInset.right ) / 2.0
        finalContentSize.height += (self.textContainerInset.top  + self.textContainerInset.bottom) / 2.0
        
        fixTextViewHeigth(finalContentSize: finalContentSize)
    }
    
    private func fixTextViewHeigth(finalContentSize:CGSize) {
        if let maxHeight = self.maxHeight {
            var  customContentSize = finalContentSize;
            
            customContentSize.height = min(customContentSize.height, CGFloat(maxHeight))
            
            self.heightConstraint?.constant = customContentSize.height;
            
            if finalContentSize.height <= self.frame.height {
                let textViewHeight = (self.frame.height - self.contentSize.height * self.zoomScale)/2.0
                
                self.contentOffset = CGPoint(x: 0, y: -(textViewHeight < 0.0 ? 0.0 : textViewHeight))
                
            }
        }
    }
}

extension TextViewAutoHeight: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = NSString(string: textView.text!)
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        placeholderLabel.isHidden = updatedText.characters.count > 0
        
        return true
    }
}
