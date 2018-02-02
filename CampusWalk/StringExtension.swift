//
//  StringExtension.swift
//  CampusWalk
//
//  Created by Alejandro Andrade on 10/17/17.
//  Copyright © 2017 Alejandro Andrade. All rights reserved.
//.

import Foundation

extension String {
    func firstLetter() -> String? {
        return (self.isEmpty ? nil : self.substring(to: self.characters.index(after: self.startIndex)))
    }
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

}
