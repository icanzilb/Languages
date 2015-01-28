# 306: Animating Auto Layout Constraints, Part 2 - Demo

In this demo you will add some basic auto layout constraints animations to the starter project. The steps here will be explained in the demo, but here are the raw steps in case you miss a step or get stuck.
## 1) Find Height Constraints

In **ViewController.swift**, add in `adjustHeights(…)`:
    var newConstraints: [NSLayoutConstraint] = []
        
    for constraint in viewToSelect.superview!.constraints() as [NSLayoutConstraint] {
      if contains(views, constraint.firstItem as UIView) &&
        constraint.firstAttribute == .Height {
        println("height constraint found")
       }
    }

## 2) Remove existing constraint

Add after the `println()`:

    NSLayoutConstraint.deactivateConstraints([constraint])

## 3) Create a new Height constraint

Add the code to calculate the multiplier:

    var multiplier: CGFloat = 0.34
    if shouldSelect {
      multiplier = (viewToSelect == constraint.firstItem as UIView) ? 0.55 : 0.23
    }

Finally add the new constraint to replace the old one:

    let con = NSLayoutConstraint(
      item: constraint.firstItem,
      attribute: .Height,
      relatedBy: .Equal,
      toItem: (constraint.firstItem as UIView).superview!,
      attribute: .Height,
      multiplier: multiplier,
      constant: 0.0)

    newConstraints.append(con)

Out of the loop body activate the constraints:

    NSLayoutConstraint.activateConstraints(newConstraints)
## 4) Add animations

At the bottom of `toggleView(…)` add:

    UIView.animateWithDuration(1.0, delay: 0.00, 
    usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, 
    options: .CurveEaseIn | .AllowUserInteraction | .BeginFromCurrentState, 
    animations: {

      self.view.layoutIfNeeded()
    }, completion: nil)

## 5) Customize Speaking animations

In `viewDidLoad()` replace:

    Selector("toggleView:")

with:

    Selector("toggleSpeaking:")

This will now direct the taps on speaking to toggleSpeaking: instead. The method is already included in the starter project.

Append to `toggleSpeaking(…)`:

    UIView.animateWithDuration(1.0, delay: 0.00, 
    usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0, 
    options: .CurveEaseIn, animations: {

       self.updateSpeakingDetails(selected: isSelected)

    }, completion: nil)

## 6) Animate the Speaking text

Find `updateSpeakingDetails(…)` - here you will add some more code to create a speaking specific animation. Add the code to move the text out of the screen:

    for constraint in speakingDetails.superview!.constraints() as [NSLayoutConstraint] {

      if constraint.firstItem as UIView == speakingDetails && 
      constraint.firstAttribute == .Leading {
        constraint.constant = -view.frame.size.width/2

        speakingView.layoutIfNeeded()

      }
    }

And insert the code to animate the text back after calling `layoutIfNeeded()`:

    UIView.animateWithDuration(0.5, delay: 0.1, 
    options: .CurveEaseOut, animations: {
      constraint.constant = 0.0
      self.speakingView.layoutIfNeeded()
    }, completion: nil)
       
     break

# Conclusion

Congrats, at this time you should have the basic animations complete, and learned a lot about Auto Layout along the way! 

You now know how to find and replace constraints, animate the layout changes of those new constraints, and also modify existing constraints without removing them first.

You are ready to move on to the lab.