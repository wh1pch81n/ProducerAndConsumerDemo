//
//  ViewController.swift
//  ProducerConsumerDemo
//
//  Created by Derrick  Ho on 9/30/15.
//  Copyright © 2015 Derrick  Ho. All rights reserved.
//

import UIKit

enum FrogState {
    case Top
    case Dropping
    case Down
    case Rising
    func next() -> FrogState {
        switch self {
        case Top: return Dropping
        case Dropping: return Down
        case Down: return Rising
        case Rising: return Top
        }
    }
}

enum Keyboard: ErrorType {
    case Error
}

func keyboardFrameFrom(notification: NSNotification) throws -> CGRect {
    guard let frame = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() else {
        throw Keyboard.Error
    }
    return frame
}


class Frog: UIView {
    
    static let FrogSpeed = NSTimeInterval(2)
    var state = FrogState.Top
    var next: ((currState: FrogState) -> Void)!
    var basket: Character? {
        didSet {
            let b = self.viewWithTag(57) as! UILabel
            if let basket = basket {
                b.text = String(basket)
            } else {
                b.text = ""
            }
        }
    }
    
    func begin() {
        next(currState: self.state)
    }

}

class ViewController: UIViewController {
    
    @IBOutlet var frog: Frog!
    @IBOutlet weak var textFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var frogLabel: UILabel!
    @IBOutlet weak var textField: UITextField!

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Add Frog
        
        self.view.addSubview(frog)
        self.frog.next = { (currState: FrogState) -> Void in
            switch currState {
            case .Dropping:
                fallthrough
            case .Top:
                self.frog.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                self.frog.frame.origin = self.frogLabel.frame.origin
                UIView.animateWithDuration(Frog.FrogSpeed, animations: { () -> Void in
                    self.frog.state = .Dropping
                    self.frog.frame.origin = self.textField.frame.origin
                    }, completion: { (b: Bool) -> Void in
                        self.frog.state = .Down
                        if let text = self.textField.text
                            where text.characters.count > 0 {
                                 var chars = text.characters
                                self.frog.basket = chars.popFirst()
                                self.textField.text = String(chars)
                        }
                        self.frog.begin()
                })
            case .Rising:
                fallthrough
            case .Down:
                self.frog.transform = CGAffineTransformMakeRotation(CGFloat(0))
                self.frog.frame.origin = self.textField.frame.origin
                UIView.animateWithDuration(Frog.FrogSpeed, animations: { () -> Void in
                    self.frog.state = .Dropping
                    self.frog.frame.origin = self.frogLabel.frame.origin
                    }, completion: { (b: Bool) -> Void in
                        self.frog.state = .Top
                        if let c = self.frog.basket {
                            let chars = self.frogLabel.text?.characters ?? "".characters
                            let a = [c] + Array(chars)
                            self.frogLabel.text = String(a)
                            self.frog.basket = nil
                        }
                        self.frog.begin()
                })

            }
        }
        
        // Keyboard Notification
        let keyboardNotificationBlock = { (notification: NSNotification) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                do {
                    self.textFieldBottomConstraint.constant = try keyboardFrameFrom(notification).height
                    self.frog.begin()
                } catch {
                    assertionFailure("Verify that notification should have come from UIKeyboardDidShowNotification")
                }
            })
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidShowNotification, object: nil, queue: NSOperationQueue(), usingBlock: keyboardNotificationBlock)
        self.textField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

