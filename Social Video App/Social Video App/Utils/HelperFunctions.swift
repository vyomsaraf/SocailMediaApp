//
//  HelperFunctions.swift
//  Social Video App
//
//  Created by Vyom on 25/05/24.
//

import Foundation

struct HelperFunctions {
    static func getNameAbbreviation(name: String?) -> String? {
        if let name = name {
            var nameString = name.components(separatedBy: .symbols).joined(separator: "")
            nameString = nameString.components(separatedBy: .illegalCharacters).joined(separator: "")
            nameString = nameString.components(separatedBy: .controlCharacters).joined(separator: "")
            nameString = nameString.components(separatedBy: .punctuationCharacters).joined(separator: "")
            
            let words = nameString.components(separatedBy: .whitespacesAndNewlines).filter({!$0.isEmpty})
            
            if words.count == 1 {
                return words.first?.first?.uppercased()
            } else if words.count > 1 {
                return "\(words.first?.first?.uppercased() ?? "")\(words.last?.first?.uppercased() ?? "")"
            }
        }
        return nil
    }
}
