//
//  ImageFromText.swift
//  Studios
//
//  Created by Vlad Kulakovsky  on 21.01.23.
//

import Foundation
import UIKit
import NaturalLanguage


extension String {
    /// Separate and return string for specific language words. In parameter enter a language key from in 15924
    
    func separateForLanguage(key: String) -> String {
        let tagger = NLTagger(tagSchemes: [.script])

        tagger.string = self

        var index = self.startIndex
        var dictionary = [String: String]()
        var lastScript = "other"
        
        while index < self.endIndex {
            let res = tagger.tag(at: index, unit: .word, scheme: .script)
            let range = res.1

            let script = res.0?.rawValue

            switch script {
            case .some(let s):
                lastScript = s
                dictionary[s, default: ""] += dictionary["other", default: ""] + self[range]
                dictionary.removeValue(forKey: "other")
            default:
                dictionary[lastScript, default: ""] += self[range]
            }
            
            index = range.upperBound
        }
        guard let string = dictionary[key] else { return ""}
        return string
    }
}
