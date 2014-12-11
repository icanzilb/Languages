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
        
        let speakingTap = UITapGestureRecognizer(target: self, action: Selector("toggleView:"))
        speakingView.addGestureRecognizer(speakingTap)

        let readingTap = UITapGestureRecognizer(target: self, action: Selector("toggleView:"))
        readingView.addGestureRecognizer(readingTap)

        let understandingTap = UITapGestureRecognizer(target: self, action: Selector("toggleView:"))
        understandingView.addGestureRecognizer(understandingTap)
    }

    // MARK: - auto layout animation
    func adjustHeights(viewToSelect: UIView, shouldSelect: Bool) {
        println("tapped: \(viewToSelect) select: \(shouldSelect)")
        
    }
    
    // deselects any selected views and selects the tapped view
    func toggleView(tap: UITapGestureRecognizer) {
        
        let wasSelected = selectedView==tap.view!
        adjustHeights(tap.view!, shouldSelect: !wasSelected)
        
        selectedView = wasSelected ? nil : tap.view!
        
        if !wasSelected {
            
            UIView.animateWithDuration(1.0, delay: 0.00,
                usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0,
                options: .CurveEaseIn | .AllowUserInteraction | .BeginFromCurrentState,
                animations: {
                    
                    self.deselectCurrentView?()
                    self.deselectCurrentView = nil
                    
                    self.view.layoutIfNeeded()
                    
                }, completion: nil)
        }

    }
    
}
