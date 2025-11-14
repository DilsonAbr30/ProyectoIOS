//
//  EncryptionService.swift
//  Ejemplo
//
//  Created by Rene Machuca on 13/11/25.
//  Copyright © 2025 Dilson Abrego. All rights reserved.
//

import Foundation
import CryptoKit

class EncryptionService {
    // Clave maestra para encriptación (deberías obtenerla del login del usuario)
    private var encryptionKey: SymmetricKey?
    
    // Configurar la clave de encriptación
    func setupEncryptionKey(masterPassword: String) {
        // Convertir la contraseña maestra en una clave segura
        let passwordData = Data(masterPassword.utf8)
        let hash = SHA256.hash(data: passwordData)
        let hashData = Data(hash)
        
        self.encryptionKey = SymmetricKey(data: hashData)
    }
    
    // Encriptar texto
    func encrypt(_ text: String) -> String? {
        guard let key = encryptionKey,
              let textData = text.data(using: .utf8) else {
            print("❌ Error: No se pudo configurar la clave de encriptación")
            return nil
        }
        
        do {
            let sealedBox = try AES.GCM.seal(textData, using: key)
            guard let combinedData = sealedBox.combined else {
                print("❌ Error: No se pudo obtener datos combinados")
                return nil
            }
            return combinedData.base64EncodedString()
        } catch {
            print("❌ Error encriptando: \(error)")
            return nil
        }
    }
    
    // Desencriptar texto
    func decrypt(_ encryptedText: String) -> String? {
        guard let key = encryptionKey,
              let data = Data(base64Encoded: encryptedText) else {
            print("❌ Error: Datos inválidos para desencriptar")
            return nil
        }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("❌ Error desencriptando: \(error)")
            return nil
        }
    }
    
    // Verificar si la clave está configurada
    func isKeySetup() -> Bool {
        return encryptionKey != nil
    }
}
