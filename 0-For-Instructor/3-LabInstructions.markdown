# 306: Animating Auto Layout Constraints, Part 3 - Lab Instructions

At this point the UI of the project looks pretty jumpy. This however is nothing compared to where you are about to bring it by the end of the lab.

Following the instructions in this document you will add the following features to the project:

 * **Interface Builder integration**. You will learn how to connect an outlet to a constraint in Interface Builder and use that outlet to animate the constraint.

 * **”Reading strip” animations**. You will add some custom animations also to the Reading strip.

# I. Polishing up the Speaking animation

But first - you need to warm up!

When you expand the Speaking view and then tap on another the old details text stays in the Speaking strip. You can assign a closure to `deselectCurrentView` and it will be executed any time the view is deselected. 

Add to `toggleSpeaking(…)` method:

    deselectCurrentView = {
      self.updateSpeakingDetails(selected: false)
    }

This should fix the details text when it’s deselected and you can go on with working on the rest of the menu strips.

# II. Interface Builder Integration

As you can imagine you can get sick of enumerating over all constraints pretty soon. Lucky for you you can significantly decrease the amount of code you need to write by integrating with Interface Builder.

A constraint is a UI element that you can create an outlet to just as with any `UIView`, `UIButton`, or `UISwitch`.

In this part of the lab you are going to create an outlet to the `.Trailing` constraint of the image in the Reading strip and animate it. By doing this you will learn how to:

1. Animate an existing constraint without replacing it.

2. Create an IB outlet to a constraint.

First add the outlet declaration inside the `ViewController` class. Add the line just under `class ViewController…`:

    @IBOutlet var speakingTrailing: NSLayoutConstraint!

Next - open Main.storyboard. To connect the outlet open Interface Builder and select the Speaking image:

![](./3-LabImages/ib1.png)

Open the Size Inspector (2nd tab from right to left):

![](./3-LabImages/ib2.png)

Double click the `.Trailing` constraint:

![](./3-LabImages/ib3.png)

This will open the constraint for editing:

![](./3-LabImages/ib4.png)

Select the Connections tab and you will see the UI allowing you to connect the constraint via an outlet to your code:

![](./3-LabImages/ib5.png)

Drag with the mouse from Referencing Outlets to your View Controller object in Interface Builder:

![](./3-LabImages/ib6.png)

From the popup menu select **speakingTrailing** and you’re done!

Now you can access the live constraint at run time just as any other outlet your have in `ViewController`. But what to do with it?

Since the only read-write property is the `constant` of the constraint – this is also the only property you can animate without replacing the constraint with a new one.

Switch back to ViewController.swift; let’s offset the image by increasing the constant when the user taps the Speaking strip. Add in `toggleSpeaking(…)` inside the animation block like so (the code to insert is highlighted):

    UIView.animateWithDuration(1.0, delay: 0.00,
      usingSpringWithDamping: 0.4, initialSpringVelocity: 1.0,
      options: .CurveEaseIn, animations: {
        

<span style='background:yellow'>self.speakingTrailing.constant = isSelected ? self.speakingView.frame.size.width/2.0 : 0.0</span>

        self.updateSpeakingDetails(selected: isSelected)
        
      }, completion: nil)


This will move away the image to make space inside the strip. Run the app to see the effect:

![](./3-LabImages/ib7.png)

The image moves away when you select Speaking but does not return if you tap another strip afterwards. You need to adjust the “deselect” handler. At the bottom of `toggleSpeaking(…)` add inside the `deselectCurrentView` closure:

    deselectCurrentView = {

<span style='background:yellow'>self.speakingTrailing.constant = 0.0</span>

      self.changeDetailsTo(kDeselectedDetailsText)

    }

This will bring back the image to its original location each time the Speaking strip is deselected.

# III. Adding a custom animation to the Reading strip

## 1) Adding custom Reading animations

You’ll start by custom Reading animations. In **ViewController.swift**, find and replace in `viewDidLoad()` this:

    let readingTap = UITapGestureRecognizer(target: self, action: Selector("toggleView:"))

with:

    let readingTap = UITapGestureRecognizer(target: self, action: Selector("toggleReading:”))

This will allow you to have a custom tap handler for the Reading strip. Scroll to `toggleReading(…)` and add inside:

    toggleReadingImageSize(readingImage, isSelected: isSelected)

    UIView.animateWithDuration(0.5, delay: 0.1, 
    options: .CurveEaseOut, animations: {
      self.readingView.layoutIfNeeded()
    }, completion: nil)

You will write your custom animation code in `toggleReadingImageSize(…)` and just as before call `layoutIfNeeded()` to animate the changes.

In a similar way to how the code finds all the `.Height` constraints in `adjustHeight(…)` you will need to find the `.Height` constraint of the `readingImage` image view.

The image view is already connected via an outlet to the image in the Reading strip and you pass it over as the `imageView` parameter of `toggleReadingImageSize(…)`.

Scroll to `toggleReadingImageSize(…)` and add the code to loop over the constraints affecting `imageView` and also insert an if to check whether you’ve reached the `.Height` constraint:

    for constraint in imageView.superview!.constraints() as [NSLayoutConstraint] {
      if constraint.firstItem as UIView == imageView && constraint.firstAttribute == .Height {

      }
    }

Inside the `if` statement the first thing you will need to do is to remove the existing `.Height` constraint:

    NSLayoutConstraint.deactivateConstraints([constraint])

Then you will need to create the new constraint. If the strip is currently selected the image height will be **33%** of the strip height, when it’s not that will be **67%**. You will shrink the image when the user taps the strip – this will create a comical effect. (You’ll see it in a moment)

Append just after the last code:

    let con = NSLayoutConstraint(
      item: constraint.firstItem,
      attribute: .Height,
      relatedBy: .Equal,
      toItem: (constraint.firstItem as UIView).superview!,
      attribute: .Height,
      multiplier: isSelected ? 0.33 : 0.67,
      constant: 0.0)
    con.active = true

You activate the new constraint and your code is complete.

It’s time you test the code and see the custom animation. Run the app – the Reading strip should look as usual.

When you tap Reading the image will start to grow (because its original .Height constraint will force it to) but then the new `.Height` constraint will make it shrink. It looks as if the image grows to push away the two labels and as soon as it touches them shrinks in place. W00t!

![](./3-LabImages/reading1.png)

There’s one last thing to fix - you need to add a custom deselect handler. Scroll to the bottom of `toggleReading()` and add:

    deselectCurrentView = {
      self.toggleReadingImageSize(self.readingImage, isSelected: false)
    }

**Congratulations**, the UI looks amazing! You’re ready to continue on to the challenges, where you’ll rinse and repeat one more time to make sure your new skills are here to last.

