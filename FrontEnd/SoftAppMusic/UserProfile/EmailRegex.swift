//
//  EmailRegex.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation
import RegexBuilder

let EmailRegex = Regex {
    OneOrMore {
        ChoiceOf {
            .word
            "."
        }
    }
    "@"
    OneOrMore {
        ChoiceOf {
            .word
            "."
        }
    }
}

let passwordPattern =
    #"(?=.{8,})"# +     // At least 8 characters
    #"(?=.*[A-Z])"# +   // At least one capital letter
    #"(?=.*[a-z])"# +   // At least one lowercase letter
    #"(?=.*\d)"# +      // At least one digit
    #"(?=.*[ !$%&?._-])"#   // At least one special character

