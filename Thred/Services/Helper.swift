//
//  Helper.swift
//  Thred
//
//  Created by Casey Corvino on 11/29/17.
//  Copyright © 2017 corvino. All rights reserved.
//

import Foundation
import UIKit

public class Helper {
    
    let colors = [UIColor.init(red: 0.600, green: 0.7, blue: 1.0, alpha: 1), UIColor.init(red: 1.0, green: 0.7, blue: 0.3, alpha: 1), UIColor.init(red: 0.822, green: 0.735, blue: 1.0, alpha: 1), UIColor.init(red: 1.0, green: 0.40, blue: 0.4, alpha: 1), UIColor.init(red: 0.837, green: 0.837, blue: 0.837, alpha: 1.0)]
    
    

    
    func getRandColor() -> UIColor {
        let i: Int = Int(arc4random_uniform(5))
        return colors[i]
    }
    
    func getColorForIndex(index: Int) -> UIColor{
        return colors[index % 5]
    }
    
    var colorCount = 0;
    func getNextColor() -> UIColor{
        if(colorCount == colors.count - 1){
            colorCount = 0
        } else{
            colorCount += 1
        }
        return colors[colorCount]
    }
    
    func dateToHHmm(d: Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from:d)
    }
    
    func isValidCaption(caption:String)->Bool{
        if(caption.count > 1 && caption != "Compose..."){
            return true;
        }
        return false;
    }
    
    
    func substring(text: String, startIndex: Int, endIndex: Int)->String{
        let sIndex = text.index(text.startIndex, offsetBy: startIndex);
        let eIndex = text.index(text.startIndex, offsetBy: endIndex);
        let ret = String(text[sIndex..<eIndex])
        return ret
    }
    
    
    public func strokeAttribute(font: UIFont, strokeWidth: Float, insideColor: UIColor, strokeColor: UIColor) -> [NSAttributedStringKey: Any]{
        return [
            NSAttributedStringKey.strokeColor : strokeColor,
            NSAttributedStringKey.foregroundColor : insideColor,
            NSAttributedStringKey.strokeWidth : -strokeWidth,
            NSAttributedStringKey.font : font
        ]
    }
    
    func stringInArray(str: String, arr: [String])->Int{
        for (index, element) in arr.enumerated() {
            if(element == str){
                return index;
            }
        }
        return -1;
    }
    func userInArray(user: BackendlessUser, arr: [BackendlessUser])->Int{
        for (index, element) in arr.enumerated() {
            if(element == user){
                return index;
            }
        }
        return -1;
    }
    
    func setForFollowing(background : UIView, button: UIButton){
        background.backgroundColor = UIColor.black;
        putSquareBorderOnButton(buttonView: background)
        button.setTitle("Following", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
    }
    func setForNotFollowing(background : UIView, button: UIButton){
        background.backgroundColor = UIColor.white;
        putSquareBorderOnButton(buttonView: background)
        button.setTitle("Follow", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
    }
    
    //==================buttons==================//
    func putBorderOnButton(buttonView: UIView, radius: Int ){
        buttonView.layer.borderColor = UIColor.black.cgColor
        buttonView.layer.borderWidth = 1
        buttonView.layer.cornerRadius = CGFloat(radius)
        buttonView.layer.masksToBounds = true;
    }
    func putSquareBorderOnButton(buttonView: UIView ){
        buttonView.layer.borderColor = UIColor.black.cgColor
        buttonView.layer.borderWidth = 1
        buttonView.layer.masksToBounds = true;
    }
    func putSquareBorderOnButtonColor(buttonView: UIView, color: UIColor ){
        buttonView.layer.borderColor = color.cgColor
        buttonView.layer.borderWidth = 1
        buttonView.layer.masksToBounds = true;
    }
    
    ///===========text field=======================//
    func underlineTextField(field : UITextField){
        field.isEnabled = true;
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.black.cgColor
        border.frame = CGRect(x: 0, y: field.frame.size.height - width, width:  field.frame.size.width, height: 1)

        border.borderWidth = width
        field.layer.addSublayer(border)
    }
    
    //===========Dispay Alert==============//
    
    func displayAlertOK(_ title: String, message: String, view :UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            alert.dismiss(animated: true, completion: nil)
        })))
        
        view.present(alert, animated: true, completion: nil)
    }
    func displayAlertOKThenPush(_ title: String, message: String, view :UIViewController, nav: UINavigationController?, story: UIStoryboard?, identifier: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            alert.dismiss(animated: true, completion: nil)
            self.pushViewController(nav: nav, story: story, identifier: identifier)
        })))
        
        view.present(alert, animated: true, completion: nil)
    }
    
    func displayAlertOKThenToRoot(_ title: String, message: String, view :UIViewController, nav: UINavigationController?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            alert.dismiss(animated: true, completion: nil)
            nav?.popToRootViewController(animated: true)
        })))
        
        view.present(alert, animated: true, completion: nil)
    }
    
    func displayAlertOKThenDismiss(_ title: String, message: String, view :UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            alert.dismiss(animated: true, completion: nil)
            view.dismiss(animated: true, completion: nil)
        })))
        
        view.present(alert, animated: true, completion: nil)
    }
    
    func displayAlertOKThenPop(_ title: String, message: String, view :UIViewController) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            alert.dismiss(animated: true, completion: nil)
            self.popViewControllerAnimated(nav: view.navigationController)
            
        })))
        
        view.present(alert, animated: true, completion: nil)
    }
    
    func pushViewController(nav: UINavigationController?, story: UIStoryboard?, identifier: String){
        let viewController = story?.instantiateViewController(withIdentifier: identifier) as UIViewController!
        nav?.pushViewController(viewController!, animated: false)
    }
    
    func pushViewControllerAnimated(nav: UINavigationController?, story: UIStoryboard?, identifier: String){
        let viewController = story?.instantiateViewController(withIdentifier: identifier) as UIViewController!
        nav?.pushViewController(viewController!, animated: true)
    }
    func popViewControllerAnimated(nav: UINavigationController?){
        nav?.popViewController(animated: true)
    }
}

//=========emoji handling==========//
extension String {
    
    var glyphCount: Int {
        
        let richText = NSAttributedString(string: self)
        let line = CTLineCreateWithAttributedString(richText)
        return CTLineGetGlyphCount(line)
    }
    
    var isSingleEmoji: Bool {
        
        return glyphCount == 1 && containsEmoji
    }
    
    var containsEmoji: Bool {
        
        return unicodeScalars.contains { $0.isEmoji }
    }
    
    var containsOnlyEmoji: Bool {
        return !isEmpty
            && !unicodeScalars.contains(where: {
                !$0.isEmoji
                    && !$0.isZeroWidthJoiner
            })
    }
    
}
extension UnicodeScalar {
    
    var isEmoji: Bool {
        
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        0x1F1E6...0x1F1FF, // Regional country flags
        0x2600...0x26FF,   // Misc symbols
        0x2700...0x27BF,   // Dingbats
        0xFE00...0xFE0F,   // Variation Selectors
        0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
        65024...65039, // Variation selector
        8400...8447: // Combining Diacritical Marks for Symbols
            return true
            
        default: return false
        }
    }
    
    var isZeroWidthJoiner: Bool {
        
        return value == 8205
    }
}


