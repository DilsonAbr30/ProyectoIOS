//
//  PasswordGenerator.swift
//  Ejemplo
//
//  Created by Rene Machuca on 13/11/25.
//  Copyright © 2025 Dilson Abrego. All rights reserved.
//

import Foundation

class PasswordGenerator {
    
    static func generateSecurePassword(length: Int = 16) -> String {
        let lowercaseLetters = "abcdefghijklmnopqrstuvwxyz"
        let uppercaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        let symbols = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        
        // Combinar todos los caracteres
        let allCharacters = lowercaseLetters + uppercaseLetters + numbers + symbols
        
        var password = ""
        
        // Asegurar al menos un carácter de cada tipo
        password += String(uppercaseLetters.randomElement()!)
        password += String(lowercaseLetters.randomElement()!)
        password += String(numbers.randomElement()!)
        password += String(symbols.randomElement()!)
        
        // Completar el resto de la longitud
        for _ in 4..<length {
            let randomIndex = Int.random(in: 0..<allCharacters.count)
            let index = allCharacters.index(allCharacters.startIndex, offsetBy: randomIndex)
            password.append(allCharacters[index])
        }
        
        // Mezclar los caracteres para que no siempre empiece con mayúscula
        return String(password.shuffled())
    }
    
    // Opciones predefinidas para diferentes tipos de servicios
    static func generateForSocialMedia() -> String {
        return generateSecurePassword(length: 12)
    }
    
    static func generateForBank() -> String {
        return generateSecurePassword(length: 20)
    }
    
    static func generateForEmail() -> String {
        return generateSecurePassword(length: 16)
    }
}
