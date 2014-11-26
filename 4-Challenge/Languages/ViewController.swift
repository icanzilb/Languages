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

    // MARK: IB outlets
    @IBOutlet var speakingTrailing: NSLayoutConstraint!
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
        
        for constraint in viewToSelect.superview!.constraints() as [NSLayoutConstraint] {
            if contains(views, constraint.firstItem as UIView) &&
                constraint.firstAttribute == .Height {

                    //remove current height constraint
                    viewToSelect.superview!.removeConstraint(constraint)
                    
                    var multiplier: CGFloat = 1.0
                    if shouldSelect {
                        multiplier = (viewToSelect == constraint.firstItem as UIView) ? 0.55 : 0.23
                    } else {
                        multiplier = 0.34
                    }
                    
                    //add new height constraint
                    let newConstraint = NSLayoutConstraint(
                        item: constraint.firstItem,
                        attribute: .Height,
                        relatedBy: .Equal,
                        toItem: (constraint.firstItem as UIView).superview!,
                        attribute: .Height,
                        multiplier: multiplier,
                        constant: 0.0)
                    viewToSelect.superview!.addConstraint(newConstraint)
            }
        }
    }
    
    // deselects any selected views and selects the tapped view
    func toggleView(tap: UITapGestureRecognizer) {
        
        let wasSelected = selectedView==tap.view!
        adjustHeights(tap.view!, shouldSelect: !wasSelected)
        
        if !wasSelected {
            UIView.animateWithDuration(1.0, delay: 0.00, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: .CurveEaseIn | .AllowUserInteraction | .BeginFromCurrentState, animations: {
                self.deselectCurrentView?()
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        selectedView = wasSelected ? nil : tap.view!
        
        UIView.animateWithDuration(1.0, delay: 0.00, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: .CurveEaseIn | .AllowUserInteraction | .BeginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: speaking animations
    // special handle for selecting the speaking view
    func toggleSpeaking(tap: UITapGestureRecognizer) {
        
        toggleView(tap)
        let isSelected = (selectedView==tap.view!)
        
        UIView.animateWithDuration(1.0, delay: 0.00, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: .CurveEaseIn, animations: {
            
            //move the image
            self.speakingTrailing.constant = isSelected ? 180.0 : 0.0
            self.changeDetailsTo(isSelected ? kSelectedDetailsText : kDeselectedDetailsText)
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
        deselectCurrentView = {
            self.speakingTrailing.constant = 0.0
            self.changeDetailsTo(kDeselectedDetailsText)
        }
    }
    
    // change the text of and animate the details label in speaking
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
    
    // MARK: understanding animations
    // special handle for selecting the understanding view
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
        }
    }
    
    // enlarge/contract the image in the understanding view
    func toggleUnderstandingImageViewSize(imageView: UIImageView, isSelected: Bool) {
        
        for constraint in imageView.superview!.constraints() as [NSLayoutConstraint] {
            if constraint.firstItem as UIView == imageView && constraint.firstAttribute == .Height {
                
                //remove existing height constraint
                imageView.superview!.removeConstraint(constraint)
                
                //add new height constraint
                let newConstraint = NSLayoutConstraint(
                    item: constraint.firstItem,
                    attribute: .Height,
                    relatedBy: .Equal,
                    toItem: (constraint.firstItem as UIView).superview!,
                    attribute: .Height,
                    multiplier: isSelected ? 1.6 : 0.45,
                    constant: 0.0)
                imageView.superview!.addConstraint(newConstraint)
            }
            
            if constraint.firstItem as UIView == imageView && constraint.firstAttribute == .CenterY {
                
                //remove existing vertical constraint
                imageView.superview!.removeConstraint(constraint)
                
                //add new vertical constraint
                let newConstraint = NSLayoutConstraint(
                    item: constraint.firstItem,
                    attribute: .CenterY,
                    relatedBy: .Equal,
                    toItem: (constraint.firstItem as UIView).superview!,
                    attribute: .CenterY,
                    multiplier: isSelected ? 1.8 : 0.75,
                    constant: 0.0)
                imageView.superview!.addConstraint(newConstraint)
            }
        }
    }
    
    // MARK: reading animations
    func toggleReading(tap: UITapGestureRecognizer) {
        toggleView(tap)
        let isSelected = (selectedView==tap.view!)
        
        toggleReadingImageSize(readingImage, isSelected: isSelected)
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: {
            self.readingImage.superview!.layoutIfNeeded()
            }, completion: nil)
        
        deselectCurrentView = {
            self.toggleReadingImageSize(self.readingImage, isSelected: false)
        }
    }
    
    func toggleReadingImageSize(imageView: UIImageView, isSelected: Bool) {
        
        for constraint in imageView.superview!.constraints() as [NSLayoutConstraint] {
            if constraint.firstItem as UIView == imageView && constraint.firstAttribute == .Height {
                
                //remove existing height constraint
                imageView.superview!.removeConstraint(constraint)
                
                //add new height constraint
                let newConstraint = NSLayoutConstraint(
                    item: constraint.firstItem,
                    attribute: .Height,
                    relatedBy: .Equal,
                    toItem: (constraint.firstItem as UIView).superview!,
                    attribute: .Height,
                    multiplier: isSelected ? 0.33 : 0.67,
                    constant: 0.0)
                imageView.superview!.addConstraint(newConstraint)
            }
            
        }
    }
}
