import SwiftUI
import FirebaseAuth

struct ChangeMasterPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isSending = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    // Colores azules
    let mainBlue = Color(red: 0.1, green: 0.3, blue: 0.7)
    let lightBlue = Color(red: 0.9, green: 0.95, blue: 1.0)
    
    var userEmail: String {
        return Auth.auth().currentUser?.email ?? "tu correo"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                lightBlue.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "envelope.badge.fill")
                            .font(.system(size: 50))
                            .foregroundColor(mainBlue)
                        
                        Text("Cambiar Contraseña")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(mainBlue)
                            .multilineTextAlignment(.center)
                        
                        Text("Te enviaremos un email para cambiar tu contraseña")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    
                    // Contenido
                    ScrollView {
                        VStack(spacing: 25) {
                            // Información del usuario
                            VStack(spacing: 15) {
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(mainBlue)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Cambiarás la contraseña de:")
                                            .font(.system(size: 12, design: .rounded))
                                            .foregroundColor(.secondary)
                                        Text(userEmail)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(mainBlue)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            }
                            .padding(.horizontal)
                            
                            // Proceso
                            VStack(alignment: .leading, spacing: 10) {
                                Text("📧 ¿Cómo funciona?")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(mainBlue)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    ProcessStepRow(icon: "1.circle.fill", text: "Toca 'Enviar Email'")
                                    ProcessStepRow(icon: "2.circle.fill", text: "Revisa tu bandeja de entrada")
                                    ProcessStepRow(icon: "3.circle.fill", text: "Abre el email de Firebase")
                                    ProcessStepRow(icon: "4.circle.fill", text: "Sigue el enlace y cambia tu contraseña")
                                    ProcessStepRow(icon: "⚠️", text: "Si no ves el email, revisa SPAM")
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            // Botón principal
                            Button(action: {
                                sendPasswordResetEmail()
                            }) {
                                HStack {
                                    if isSending {
                                        Text("⏳")
                                            .font(.system(size: 18))
                                    } else {
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 18, weight: .medium))
                                    }
                                    
                                    Text(isSending ? "Enviando Email..." : "Enviar Email de Cambio")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(!isSending ? mainBlue : Color.gray)
                                .cornerRadius(12)
                                .shadow(color: !isSending ? mainBlue.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 3)
                            }
                            .disabled(isSending)
                            .padding(.horizontal)
                            
                            // Información adicional
                            Text("El cambio se realiza de forma segura a través de tu proveedor de email")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationBarTitle("Cambiar Contraseña", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(mainBlue)
                .font(.system(size: 16, weight: .medium))
            )
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showSuccess) {
                Alert(
                    title: Text("Email Enviado"),
                    message: Text("Hemos enviado un email a **\(userEmail)**. Revisa tu bandeja de entrada y sigue las instrucciones para cambiar tu contraseña."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // ✅ FUNCIÓN SIMPLE: Solo envía el email
    private func sendPasswordResetEmail() {
        isSending = true
        
        guard let userEmail = Auth.auth().currentUser?.email else {
            errorMessage = "No hay usuario autenticado"
            showError = true
            isSending = false
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: userEmail) { error in
            isSending = false
            
            if let error = error {
                errorMessage = getErrorMessage(error)
                showError = true
            } else {
                showSuccess = true
                print("✅ Email de cambio de contraseña enviado a: \(userEmail)")
            }
        }
    }
    
    private func getErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.userNotFound.rawValue:
            return "No existe una cuenta con este email"
        case AuthErrorCode.invalidEmail.rawValue:
            return "El formato del email no es válido"
        case AuthErrorCode.networkError.rawValue:
            return "Error de conexión. Verifica tu internet"
        default:
            return "Error al enviar el email: \(error.localizedDescription)"
        }
    }
}

struct ProcessStepRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 14))
            
            Text(text)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct ChangeMasterPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeMasterPasswordView()
    }
}
