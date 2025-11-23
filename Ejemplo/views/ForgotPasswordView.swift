import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var isSending = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    // Colores azules (consistentes con tu app)
    let mainBlue = Color(red: 0.1, green: 0.3, blue: 0.7)
    let lightBlue = Color(red: 0.9, green: 0.95, blue: 1.0)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                lightBlue.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "envelope.badge.fill")
                            .font(.system(size: 50))
                            .foregroundColor(mainBlue)
                        
                        Text("Recuperar Contraseña")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(mainBlue)
                            .multilineTextAlignment(.center)
                        
                        Text("Te enviaremos un enlace a tu email para restablecer tu contraseña")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    
                    // Formulario
                    VStack(spacing: 25) {
                        // Campo de email
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(mainBlue)
                                    .font(.system(size: 14, weight: .medium))
                                
                                Text("Email de Recuperación")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(mainBlue)
                                
                                Text("*")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.red)
                            }
                            
                            TextField("tu@email.com", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(email.isEmpty ? Color.gray.opacity(0.3) : mainBlue, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal)
                        
                        // Botón de enviar
                        Button(action: {
                            sendRecoveryEmail()
                        }) {
                            HStack {
                                if isSending {
                                    Text("⏳")
                                        .font(.system(size: 18))
                                } else {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 18, weight: .medium))
                                }
                                
                                Text(isSending ? "Enviando..." : "Enviar Enlace de Recuperación")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(!email.isEmpty && !isSending ? mainBlue : Color.gray)
                            .cornerRadius(12)
                            .shadow(color: !email.isEmpty && !isSending ? mainBlue.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 3)
                        }
                        .disabled(email.isEmpty || isSending)
                        .padding(.horizontal)
                        
                        // Información importante
                        VStack(alignment: .leading, spacing: 10) {
                            Text("📧 ¿Qué pasa después?")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(mainBlue)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                InfoRow(icon: "1.circle.fill", text: "Recibirás un email de Firebase")
                                InfoRow(icon: "2.circle.fill", text: "Abre el email y haz clic en el enlace")
                                InfoRow(icon: "3.circle.fill", text: "Crea tu nueva contraseña")
                                InfoRow(icon: "4.circle.fill", text: "Vuelve a la app e inicia sesión")
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.top, 30)
                }
            }
            .navigationBarTitle("Recuperar Contraseña", displayMode: .inline)
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
                    message: Text("Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func sendRecoveryEmail() {
        isSending = true
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            isSending = false
            
            if let error = error {
                errorMessage = getErrorMessage(error)
                showError = true
            } else {
                showSuccess = true
                print("✅ Email de recuperación enviado a: \(email)")
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

// Componente para información
struct InfoRow: View {
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

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
