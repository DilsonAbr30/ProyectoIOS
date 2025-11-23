import SwiftUI

struct EditPasswordView: View {
    let password: PasswordItem
    @ObservedObject var passwordViewModel: PasswordViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var editedService: String
    @State private var editedUsername: String
    @State private var editedPassword: String
    @State private var editedNotes: String
    @State private var showPassword = false
    @State private var isSaving = false
    
    init(password: PasswordItem, passwordViewModel: PasswordViewModel) {
        self.password = password
        self.passwordViewModel = passwordViewModel
        _editedService = State(initialValue: password.service)
        _editedUsername = State(initialValue: password.username)
        _editedPassword = State(initialValue: password.password)
        _editedNotes = State(initialValue: password.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del Servicio")) {
                    TextField("Nombre del servicio", text: $editedService)
                    TextField("Usuario/Correo", text: $editedUsername)
                    
                    // Campo de contraseña con botón de ojo
                    HStack {
                        if showPassword {
                            TextField("Contraseña", text: $editedPassword)
                        } else {
                            SecureField("Contraseña", text: $editedPassword)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Notas")) {
                    TextField("Notas opcionales", text: $editedNotes)
                }
                
                // Botón para generar contraseña segura
                Section {
                    Button(action: {
                        editedPassword = PasswordGenerator.generateSecurePassword()
                    }) {
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.blue)
                            Text("Generar Contraseña Segura")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationBarTitle("Editar Contraseña", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Guardar") {
                    saveChanges()
                }
                .disabled(!isFormValid || isSaving)
            )
        }
    }
    
    private var isFormValid: Bool {
        !editedService.isEmpty && !editedUsername.isEmpty && !editedPassword.isEmpty
    }
    
    private func saveChanges() {
        isSaving = true
        
        // Crear un nuevo PasswordItem con los datos editados
        let updatedPassword = PasswordItem(
            id: password.id,
            service: editedService,
            username: editedUsername,
            password: editedPassword,
            notes: editedNotes,
            userEmail: password.userEmail,
            userId: password.userId,
            createdAt: password.createdAt
        )
        
        // Llamar al ViewModel con el objeto completo
        passwordViewModel.updatePassword(updatedPassword)
        
        // Pequeño delay para que se complete la operación
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSaving = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct EditPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        EditPasswordView(
            password: PasswordItem(
                service: "Gmail",
                username: "usuario@gmail.com",
                password: "123456",
                notes: "Cuenta personal",
                userEmail: "test@ejemplo.com"
            ),
            passwordViewModel: PasswordViewModel()
        )
    }
}
