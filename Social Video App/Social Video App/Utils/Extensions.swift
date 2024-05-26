//
//  Extensions.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

