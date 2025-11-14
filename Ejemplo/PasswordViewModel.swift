import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class PasswordViewModel: ObservableObject {
    @Published var passwords: [PasswordItem] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // ✅ Servicio de encriptación
    private let encryptionService = EncryptionService()
    
    init() {
        // Configurar encriptación al inicializar
        setupEncryption()
        
        // ✅ LIMPIAR CONTRASEÑAS VIEJAS (ejecutar solo una vez)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.deleteUnencryptedPasswords()
        }
    }
    
    deinit {
        listener?.remove()
    }
    
    // ✅ Configurar encriptación
    private func setupEncryption() {
        // ⚠️ TEMPORAL: Usar una clave fija por ahora
        let temporaryMasterPassword = "clave-maestra-temporal-123"
        encryptionService.setupEncryptionKey(masterPassword: temporaryMasterPassword)
        print("🔐 DEBUG - Encriptación configurada")
    }
    
    // ✅ NUEVA FUNCIÓN: Borrar contraseñas antiguas sin encriptar
    func deleteUnencryptedPasswords() {
        guard let user = Auth.auth().currentUser else {
            print("❌ DEBUG - No hay usuario para limpiar contraseñas")
            return
        }
        
        let userUID = user.uid
        
        print("🔍 DEBUG - 🗑️ INICIANDO LIMPIEZA DE CONTRASEÑAS SIN ENCRIPTAR...")
        print("🔍 DEBUG - 🔍 Buscando contraseñas del usuario: \(userUID)")
        
        db.collection("passwords").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("❌ DEBUG - Error al obtener documentos: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("🔍 DEBUG - No se encontraron documentos")
                return
            }
            
            print("🔍 DEBUG - 📊 Total de documentos en BD: \(documents.count)")
            
            var deletedCount = 0
            let group = DispatchGroup()
            
            for document in documents {
                let data = document.data()
                let docUserId = data["userId"] as? String
                let docService = data["service"] as? String ?? "Sin nombre"
                
                // Solo procesar documentos del usuario actual
                if docUserId == userUID {
                    let encryptedPassword = data["password"] as? String ?? ""
                    
                    // Intentar desencriptar - si falla, es porque no está encriptada
                    if self?.encryptionService.decrypt(encryptedPassword) == nil {
                        print("🔍 DEBUG - 🗑️ ELIMINANDO contraseña sin encriptar: \(docService)")
                        
                        group.enter()
                        document.reference.delete { error in
                            if let error = error {
                                print("❌ DEBUG - Error eliminando \(docService): \(error)")
                            } else {
                                deletedCount += 1
                                print("✅ DEBUG - Eliminada: \(docService)")
                            }
                            group.leave()
                        }
                    } else {
                        print("🔍 DEBUG - ✅ Contraseña ENCRIPTADA (se mantiene): \(docService)")
                    }
                }
            }
            
            group.notify(queue: .main) {
                print("🔍 DEBUG - 🎯 LIMPIEZA COMPLETADA")
                print("🔍 DEBUG - 📊 Contraseñas eliminadas: \(deletedCount)")
                
                if deletedCount > 0 {
                    print("🔍 DEBUG - 🔄 Recargando lista después de limpieza...")
                    // Esperar un poco y recargar
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.fetchPasswords()
                    }
                } else {
                    print("🔍 DEBUG - ✅ No había contraseñas sin encriptar")
                }
            }
        }
    }
    
    func fetchPasswords() {
        guard let user = Auth.auth().currentUser else {
            print("❌ DEBUG - No hay usuario autenticado")
            return
        }
        
        let userUID = user.uid
        let userEmail = user.email ?? "sin-email"
        
        print("🔍 DEBUG === INICIANDO FETCH ===")
        print("🔍 DEBUG - Email del usuario: \(userEmail)")
        print("🔍 DEBUG - UID del usuario: \(userUID)")
        
        // Remover listener anterior si existe
        listener?.remove()
        
        print("🔍 DEBUG - 🔍 Buscando documentos con filtro: userId = \(userUID)")
        
        listener = db.collection("passwords")
            .whereField("userId", isEqualTo: userUID)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("❌ DEBUG - Error en fetch filtrado: \(error.localizedDescription)")
                    
                    if error.localizedDescription.contains("index") {
                        print("🔍 DEBUG - ⚠️ Índice en construcción, usando consulta alternativa...")
                        self?.fetchPasswordsAlternative()
                    }
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("🔍 DEBUG - ❌ No se encontraron documentos para userId: \(userUID)")
                    self?.passwords = []
                    return
                }
                
                print("🔍 DEBUG - ✅ Documentos ENCONTRADOS con filtro: \(documents.count)")
                
                if documents.count == 0 {
                    print("🔍 DEBUG - ⚠️ NO HAY DOCUMENTOS CON EL USER_ID: \(userUID)")
                }
                
                self?.passwords = documents.compactMap { document in
                    let data = document.data()
                    
                    // ✅ Desencriptar la contraseña
                    let encryptedPassword = data["password"] as? String ?? ""
                    let decryptedPassword = self?.encryptionService.decrypt(encryptedPassword) ?? "❌ Error desencriptando"
                    
                    let passwordItem = PasswordItem(
                        id: document.documentID,
                        service: data["service"] as? String ?? "",
                        username: data["username"] as? String ?? "",
                        password: decryptedPassword,
                        notes: data["notes"] as? String ?? "",
                        userEmail: data["userEmail"] as? String ?? "",
                        userId: data["userId"] as? String ?? "",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                    
                    if decryptedPassword == "❌ Error desencriptando" {
                        print("🔍 DEBUG - ⚠️ Problema con: \(passwordItem.service)")
                    } else {
                        print("🔍 DEBUG - 🎯 Password cargado: \(passwordItem.service) - \(decryptedPassword.prefix(3))...")
                    }
                    
                    return passwordItem
                }
                
                print("🔍 DEBUG - 📱 passwords array actualizado con \(self?.passwords.count ?? 0) elementos")
            }
    }
    
    // CONSULTA ALTERNATIVA para cuando el índice está en construcción
    private func fetchPasswordsAlternative() {
        guard let user = Auth.auth().currentUser else { return }
        let userUID = user.uid
        
        print("🔍 DEBUG - 🔄 Usando consulta alternativa...")
        
        db.collection("passwords").getDocuments { [weak self] snapshot, error in
            if let documents = snapshot?.documents {
                let filteredDocs = documents.filter { doc in
                    let docUserId = doc.data()["userId"] as? String
                    return docUserId == userUID
                }
                
                print("🔍 DEBUG - ✅ Documentos filtrados manualmente: \(filteredDocs.count)")
                
                self?.passwords = filteredDocs.compactMap { document in
                    let data = document.data()
                    
                    let encryptedPassword = data["password"] as? String ?? ""
                    let decryptedPassword = self?.encryptionService.decrypt(encryptedPassword) ?? "❌ Error desencriptando"
                    
                    return PasswordItem(
                        id: document.documentID,
                        service: data["service"] as? String ?? "",
                        username: data["username"] as? String ?? "",
                        password: decryptedPassword,
                        notes: data["notes"] as? String ?? "",
                        userEmail: data["userEmail"] as? String ?? "",
                        userId: data["userId"] as? String ?? "",
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
            }
        }
    }
    
    func savePassword(service: String, username: String, password: String, notes: String) {
        guard let user = Auth.auth().currentUser else {
            print("❌ No user logged in")
            return
        }
        
        let userUID = user.uid
        let userEmail = user.email ?? "sin-email"
        
        print("🔍 DEBUG - 💾 Guardando contraseña para userId: \(userUID)")
        
        // ✅ Encriptar la contraseña antes de guardar
        guard let encryptedPassword = encryptionService.encrypt(password) else {
            print("❌ DEBUG - Error: No se pudo encriptar la contraseña")
            return
        }
        
        let passwordData: [String: Any] = [
            "service": service,
            "username": username,
            "password": encryptedPassword,
            "notes": notes,
            "userEmail": userEmail,
            "userId": userUID,
            "createdAt": Timestamp(date: Date())
        ]
        
        print("🔍 DEBUG - 📊 Datos a guardar:")
        print("🔍 DEBUG -   Service: \(service)")
        print("🔍 DEBUG -   Username: \(username)")
        print("🔍 DEBUG -   Password (original): \(password)")
        print("🔍 DEBUG -   Password (encriptado): \(encryptedPassword.prefix(20))...")
        print("🔍 DEBUG -   Notes: \(notes)")
        print("🔍 DEBUG -   userEmail: \(userEmail)")
        print("🔍 DEBUG -   userId: \(userUID)")
        
        db.collection("passwords").addDocument(data: passwordData) { [weak self] error in
            if let error = error {
                print("❌ Error guardando contraseña: \(error)")
            } else {
                print("✅ Contraseña guardada y ENCRIPTADA exitosamente para: \(service)")
                print("✅ userId asociado: \(userUID)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    print("🔍 DEBUG - 🔄 Ejecutando refresh después de guardar...")
                    self?.fetchPasswords()
                }
            }
        }
    }
    
    func deletePassword(_ password: PasswordItem) {
        guard let id = password.id else { return }
        
        print("🔍 DEBUG - 🗑️ Eliminando contraseña: \(password.service)")
        
        db.collection("passwords").document(id).delete { [weak self] error in
            if let error = error {
                print("❌ Error eliminando contraseña: \(error)")
            } else {
                print("✅ Contraseña eliminada: \(password.service)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.fetchPasswords()
                }
            }
        }
    }
    
    func refreshPasswords() {
        print("🔍 DEBUG - 🔄 Refresh manual solicitado")
        fetchPasswords()
    }
    
    func updatePassword(_ passwordItem: PasswordItem) {
        guard let id = passwordItem.id else { return }
        
        guard let encryptedPassword = encryptionService.encrypt(passwordItem.password) else {
            print("❌ DEBUG - Error: No se pudo encriptar la contraseña para actualizar")
            return
        }
        
        let updateData: [String: Any] = [
            "service": passwordItem.service,
            "username": passwordItem.username,
            "password": encryptedPassword,
            "notes": passwordItem.notes,
            "userEmail": passwordItem.userEmail,
            "userId": passwordItem.userId,
            "createdAt": Timestamp(date: passwordItem.createdAt)
        ]
        
        db.collection("passwords").document(id).updateData(updateData) { error in
            if let error = error {
                print("❌ Error actualizando contraseña: \(error)")
            } else {
                print("✅ Contraseña actualizada y ENCRIPTADA: \(passwordItem.service)")
            }
        }
    }
    
    // ✅ FUNCIÓN: Borrar TODAS las contraseñas (solo para desarrollo)
    func deleteAllPasswords() {
        print("🔍 DEBUG - 🗑️ ELIMINANDO TODAS LAS CONTRASEÑAS")
        
        db.collection("passwords").getDocuments { [weak self] snapshot, error in
            if let documents = snapshot?.documents {
                print("🔍 DEBUG - 📝 Documentos a eliminar: \(documents.count)")
                
                for document in documents {
                    document.reference.delete()
                }
                
                print("🔍 DEBUG - ✅ Todos los documentos eliminados")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self?.fetchPasswords()
                }
            }
        }
    }
}
