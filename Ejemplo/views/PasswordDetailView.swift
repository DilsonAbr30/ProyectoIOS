import SwiftUI
import LocalAuthentication

struct PasswordDetailView: View {
    let password: PasswordItem
    @ObservedObject var passwordViewModel: PasswordViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showPassword = false
    @State private var showEdit = false
    @State private var showDeleteConfirmation = false
    @State private var showCopiedAlert = false
    @State private var copiedText = ""
    
    // Colores azules
    let mainBlue = Color(red: 0.1, green: 0.3, blue: 0.7)
    let lightBlue = Color(red: 0.9, green: 0.95, blue: 1.0)
    let darkBlue = Color(red: 0.05, green: 0.2, blue: 0.6)
    
    init(password: PasswordItem, passwordViewModel: PasswordViewModel) {
        self.password = password
        self.passwordViewModel = passwordViewModel
    }
    
    var body: some View {
        ZStack {
            // Fondo
            lightBlue.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header con ícono
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(mainBlue.opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: getIconForService(password.service))
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(mainBlue)
                        }
                        
                        VStack(spacing: 4) {
                            Text(password.service)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(mainBlue)
                            
                            Text("Cuenta guardada")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    // Información de la cuenta
                    VStack(spacing: 16) {
                        // Servicio
                        infoRow(icon: "globe", title: "Servicio", value: password.service)
                        
                        // Usuario
                        infoRowWithCopy(icon: "person", title: "Usuario", value: password.username, copyText: password.username)
                        
                        // Contraseña
                        passwordRow()
                        
                        // Notas (si existen)
                        if !password.notes.isEmpty {
                            infoRow(icon: "note.text", title: "Notas", value: password.notes)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Acciones
                    VStack(spacing: 12) {
                        // Botón Editar
                        Button(action: {
                            showEdit = true
                        }) {
                            actionButton(icon: "pencil", title: "Editar Contraseña", color: mainBlue)
                        }
                        
                        // Botones de Copiar
                        HStack(spacing: 12) {
                            Button(action: {
                                copyToClipboard(password.username)
                                copiedText = "usuario"
                            }) {
                                HStack {
                                    Image(systemName: "person.crop.circle")
                                        .font(.system(size: 16))
                                    Text("Copiar Usuario")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(mainBlue)
                                .cornerRadius(10)
                            }
                            
                            Button(action: {
                                copyToClipboard(password.password)
                                copiedText = "contraseña"
                            }) {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 16))
                                    Text("Copiar Contraseña")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(darkBlue)
                                .cornerRadius(10)
                            }
                        }
                        
                        // Botón Eliminar
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            actionButton(icon: "trash", title: "Eliminar Cuenta", color: Color.red)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                        .frame(height: 50)
                }
            }
        }
        .navigationBarTitle("Detalles", displayMode: .inline)
        .navigationBarItems(
            trailing: Button("Editar") {
                showEdit = true
            }
            .foregroundColor(mainBlue)
            .font(.system(size: 16, weight: .medium))
        )
        .sheet(isPresented: $showEdit) {
            EditPasswordView(
                password: password,
                passwordViewModel: passwordViewModel
            )
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Eliminar Cuenta"),
                message: Text("¿Estás seguro de que quieres eliminar esta cuenta? Esta acción no se puede deshacer."),
                primaryButton: .destructive(Text("Eliminar")) {
                    deletePassword()
                },
                secondaryButton: .cancel(Text("Cancelar"))
            )
        }
        .alert(isPresented: $showCopiedAlert) {
            Alert(
                title: Text("Copiado"),
                message: Text("\(copiedText) copiado al portapapeles"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Fila de información normal
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(mainBlue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(mainBlue)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Fila de información con botón de copiar
    private func infoRowWithCopy(icon: String, title: String, value: String, copyText: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(mainBlue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(mainBlue)
            }
            
            Spacer()
            
            Button(action: {
                copyToClipboard(copyText)
                copiedText = title.lowercased()
            }) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14))
                    .foregroundColor(mainBlue)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Fila de contraseña con toggle de visibilidad
    private func passwordRow() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(mainBlue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Contraseña")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                if showPassword {
                    Text(password.password)
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundColor(Color.green)
                } else {
                    Text("••••••••")
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: {
                togglePasswordVisibility()
            }) {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .font(.system(size: 16))
                    .foregroundColor(mainBlue)
            }
            
            Button(action: {
                copyToClipboard(password.password)
                copiedText = "contraseña"
            }) {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 14))
                    .foregroundColor(mainBlue)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // Botón de acción
    private func actionButton(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func togglePasswordVisibility() {
        authenticateForPassword()
    }
    
    private func authenticateForPassword() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Autentícate para ver la contraseña"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, _ in
                DispatchQueue.main.async {
                    if success {
                        self.showPassword.toggle()
                    }
                }
            }
        } else {
            // Si no hay Face ID/Touch ID, mostrar directamente
            self.showPassword.toggle()
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        showCopiedAlert = true
    }
    
    private func deletePassword() {
        passwordViewModel.deletePassword(password)
        presentationMode.wrappedValue.dismiss()
    }
    
    // Función para obtener ícono según el servicio
    private func getIconForService(_ service: String) -> String {
        let lowercased = service.lowercased()
        
        if lowercased.contains("gmail") || lowercased.contains("google") {
            return "envelope.fill"
        } else if lowercased.contains("facebook") {
            return "f.circle.fill"
        } else if lowercased.contains("twitter") || lowercased.contains("x.com") {
            return "bird.fill"
        } else if lowercased.contains("instagram") {
            return "camera.fill"
        } else if lowercased.contains("netflix") {
            return "play.tv.fill"
        } else if lowercased.contains("apple") {
            return "applelogo"
        } else if lowercased.contains("amazon") {
            return "a.circle.fill"
        } else if lowercased.contains("microsoft") {
            return "m.circle.fill"
        } else if lowercased.contains("whatsapp") {
            return "message.fill"
        } else if lowercased.contains("spotify") {
            return "music.note"
        } else if lowercased.contains("youtube") {
            return "play.rectangle.fill"
        } else if lowercased.contains("linkedin") {
            return "l.circle.fill"
        } else {
            return "lock.fill"
        }
    }
}

struct PasswordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PasswordDetailView(
                password: PasswordItem(
                    service: "Gmail",
                    username: "usuario@gmail.com",
                    password: "mi_contraseña_secreta",
                    notes: "Cuenta personal de correo",
                    userEmail: "test@ejemplo.com"
                ),
                passwordViewModel: PasswordViewModel()
            )
        }
    }
}
