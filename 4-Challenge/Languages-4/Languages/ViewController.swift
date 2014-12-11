/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

// MARK: constants
let kDeselectedDetailsText = "Managing to fluently transmit your thoughts and have daily conversations"
let kSelectedDetailsText = "Excercises: 67%\nConversations: 50%\nDaily streak: 4\nCurrent grade: B"

// MARK: - ViewController
class ViewController: UIViewController {

    @IBOutlet var speakingTrailing: NSLayoutConstraint!

    // MARK: IB outlets
    @IBOutlet var speakingDetails: UILabel!
    @IBOutlet var understandingImage: UIImageView!
    @IBOutlet var readingImage: UIImageView!
    
    @IBOutlet var speakingView: UIView!
    @IBOutlet var understandingView: UIView!
    @IBOutlet var readingView: UIView!
    
    // MARK: class properties
    var views: [UIView]!
    
    var selectedView: UIView?
    var deselectCurrentView: (()->())?
    
    var understandButton: UIButton!
    
    // MARK: - view controller methods
    override func viewDidLoad() {
        super.viewDidLoad()

        views = [speakingView, readingView, understandingView]
        
        let speakingTap = UITapGestureRecognizer(target: self, action: Selector("toggleSpeaking:"))
        speakingView.addGestureRecognizer(speakingTap)

        let readingTap = UITapGestureRecognizer(target: self, action: Selector("toggleReading:"))
        readingView.addGestureRecognizer(readingTap)

        let understandingTap = UITapGestureRecognizer(target: self, action: Selector("toggleUnderstanding:"))
        understandingView.addGestureRecognizer(understandingTap)
    }

    // MARK: - auto layout animation
    // either expands a single view or equalizes all heights
    func adjustHeights(viewToSelect: UIView, shouldSelect: Bool) {
        
        var newConstraints: [NSLayoutConstraint] = []
        
        for constraint in viewToSelect.superview!.constraints() as [NSLayoutConstraint] {
            if contains(views, constraint.firstItem as UIView) &&
                constraint.firstAttribute == .Height {

                    //remove current height constraint
                    viewToSelect.superview!.removeConstraint(constraint)

                    var multiplier: CGFloat = 0.34
                    if shouldSelect {
                        multiplier = (viewToSelect == constraint.firstItem as UIView) ? 0.55 : 0.23
                    }

                    //add new height constraint
                    let con = NSLayoutConstraint(
                        item: constraint.firstItem,
                        attribute: .Height,
                        relatedBy: .Equal,
                        toItem: (constraint.firstItem as UIView).superview!,
                        attribute: .Height,
                        multiplier: multiplier,
                        constant: 0.0)
                    
                    newConstraints.append(con)
            }
        }
        
        NSLayoutConstraint.activateConstraints(newConstraints)
    }
    
    // deselects any selected views and selects the tapped view
    func toggleView(tap: UITapGestureRecognizer) {
        
        let wasSelected = selectedView==tap.view!
        adjustHeights(tap.view!, shouldSelect: !wasSelected)

        if !wasSelected {
            UIView.animateWithDuration(1.0, delay: 0.00, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: .CurveEaseIn | .AllowUserInteraction | .BeginFromCurrentState, animations: {
                self.deselectCurrentView?()
                self.deselectCurrentView = nil
                self.view.layoutIfNeeded()
                }, completion: nil)
        }

        selectedView = wasSelected ? nil : tap.view!
        
        UIView.animateWithDuration(1.0, delay: 0.00, usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, options: .CurveEaseIn | .AllowUserInteraction | .BeginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)

    }

    func toggleSpeaking(tap: UITapGestureRecognizer) {
        toggleView(tap)
        let isSelected = (selectedView==tap.view!)
        
        UIView.animateWithDuration(1.0, delay: 0.00, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: .CurveEaseIn, animations: {
            self.speakingTrailing.constant = isSelected ? self.speakingView.frame.size.width/2.0 : 0.0
            self.changeDetailsTo(isSelected ? kSelectedDetailsText : kDeselectedDetailsText)
            self.view.layoutIfNeeded()
        }, completion: nil)

        deselectCurrentView = {
            self.speakingTrailing.constant = 0.0
            self.changeDetailsTo(kDeselectedDetailsText)
        }
    }
    
    func changeDetailsTo(text: String) {
        speakingDetails.text = text
        
        for constraint in speakingDetails.superview!.constraints() as [NSLayoutConstraint] {
            if constraint.firstItem as UIView == speakingDetails && constraint.firstAttribute == .Leading {
                
                constraint.constant = -view.frame.size.width/2
                speakingView.layoutIfNeeded()
                
                constraint.constant = 0.0
                UIView.animateWithDuration(0.5, delay: 0.1, options: .CurveEaseOut, animations: {
                    self.speakingView.layoutIfNeeded()
                }, completion: nil)

                break
            }
        }
    }
    
    // MARK: reading animations
    func toggleReading(tap: UITapGestureRecognizer) {
        toggleView(tap)
        let isSelected = (selectedView==tap.view!)
        
        //custom animations
        toggleReadingImageSize(readingImage, isSelected: isSelected)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
            self.readingView.superview!.layoutIfNeeded()
        }, completion: nil)
        
        deselectCurrentView = {
            self.toggleReadingImageSize(self.readingImage, isSelected: false)
        }
    }

    func toggleReadingImageSize(imageView: UIImageView, isSelected: Bool) {
        
        for constraint in imageView.superview!.constraints() as [NSLayoutConstraint] {
            if constraint.firstItem as UIView == imageView && constraint.firstAttribute == .Height {
                
                imageView.superview!.removeConstraint(constraint)
                
                let con = NSLayoutConstraint(
                    item: constraint.firstItem,
                    attribute: .Height,
                    relatedBy: .Equal,
                    toItem: (constraint.firstItem as UIView).superview!,
                    attribute: .Height,
                    multiplier: isSelected ? 0.33 : 0.67,
                    constant: 0.0)
                con.active = true
                
                break
            }
        }
    }
    
    func toggleUnderstanding(tap: UITapGestureRecognizer) {
        toggleView(tap)
        let isSelected = (selectedView==tap.view!)
        
        toggleUnderstandingImageViewSize(understandingImage, isSelected: isSelected)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
            self.understandingImage.alpha = isSelected ? 0.33 : 1.0
            self.understandingImage.superview!.layoutIfNeeded()
        }, completion: nil)
        
        deselectCurrentView = {
            self.toggleUnderstandingImageViewSize(self.understandingImage, isSelected: false)
            self.understandingImage.alpha = 1.0
            self.hideUnderstandingButton()
        }
        
        showUnderstandingButton(isSelected)
    }
    
    func hideUnderstandingButton() {
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseOut | .BeginFromCurrentState, animations: {
            self.understandButton.alpha = 0.0
        }, completion: nil)
    }
    
    func showUnderstandingButton(isSelected: Bool) {
        
        if !isSelected {
            hideUnderstandingButton()
            return
        }
        
        understandButton?.removeFromSuperview()
        understandButton = UIButton.buttonWithType(.Custom) as UIButton
        understandButton.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9)
        understandButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        understandButton.setTitle("Start excercise", forState: .Normal)
        understandButton.layer.cornerRadius = 10.0
        understandButton.layer.masksToBounds = true
        understandButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        understandingView.addSubview(understandButton)
        
        let conX = NSLayoutConstraint(item: understandButton, attribute: .CenterX, relatedBy: .Equal, toItem: understandingView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
        let conY = NSLayoutConstraint(item: understandButton, attribute: .Bottom, relatedBy: .Equal, toItem: understandingView, attribute: .Bottom, multiplier: 0.75, constant: understandingView.frame.size.height)
        let conWidth = NSLayoutConstraint(item: understandButton, attribute: .Width, relatedBy: .Equal, toItem: understandingView, attribute: .Width, multiplier: 0.5, constant: 0.0)
        let conHeight = NSLayoutConstraint(item: understandButton, attribute: .Height, relatedBy: .Equal, toItem: understandButton, attribute: .Width, multiplier: 0.25, constant: 0.0)
        
        NSLayoutConstraint.activateConstraints([conX, conY, conWidth, conHeight])
        understandButton.layoutIfNeeded()
        
        UIView.animateWithDuration(1.33, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .BeginFromCurrentState, animations: {
            conY.constant = 0.0
            self.understandButton.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func toggleUnderstandingImageViewSize(imageView: UIImageView, isSelected: Bool) {
        
        var newConstraints: [NSLayoutConstraint] = []
        
        for constraint in imageView.superview!.constraints() as [NSLayoutConstraint] {
            if constraint.firstItem as UIView == imageView && constraint.firstAttribute == .Height {
                
                //remove existing height constraint
                imageView.superview!.removeConstraint(constraint)
                
                //add new height constraint
                let con = NSLayoutConstraint(
                    item: constraint.firstItem,
                    attribute: .Height,
                    relatedBy: .Equal,
                    toItem: (constraint.firstItem as UIView).superview!,
                    attribute: .Height,
                    multiplier: isSelected ? 1.6 : 0.45,
                    constant: 0.0)
                newConstraints.append(con)
            }
            
            if constraint.firstItem as UIView == imageView && constraint.firstAttribute == .CenterY {
                
                //remove existing vertical constraint
                imageView.superview!.removeConstraint(constraint)
                
                //add new vertical constraint
                let con = NSLayoutConstraint(
                    item: constraint.firstItem,
                    attribute: .CenterY,
                    relatedBy: .Equal,
                    toItem: (constraint.firstItem as UIView).superview!,
                    attribute: .CenterY,
                    multiplier: isSelected ? 1.8 : 0.75,
                    constant: 0.0)
                newConstraints.append(con)
            }
        }
        
        NSLayoutConstraint.activateConstraints(newConstraints)
    }
    
}
