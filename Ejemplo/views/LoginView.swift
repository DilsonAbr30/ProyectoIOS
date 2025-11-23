import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegister = false
    @State private var showingForgotPassword = false
    
    @State private var errorMessage: String?
    @State private var showAlert = false
    @State private var isLoading = false
    
    // Colores azules
    let mainBlue = Color(red: 0.1, green: 0.3, blue: 0.7)
    let lightBlue = Color(red: 0.9, green: 0.95, blue: 1.0)
    
    // Función de login
    func login() {
        // Validaciones básicas
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor completa todos los campos"
            showAlert = true
            return
        }
        
        guard isValidEmail(email) else {
            errorMessage = "Por favor ingresa un email válido"
            showAlert = true
            return
        }
        
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoading = false
            
            if let error = error {
                self.errorMessage = getLoginErrorMessage(error)
                self.showAlert = true
            } else {
                print("✅ Inicio de sesión exitoso: \(email)")
                // Aquí puedes navegar a la siguiente vista
            }
        }
    }
    
    // Validación de email
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Manejo de errores específicos
    private func getLoginErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Contraseña incorrecta"
        case AuthErrorCode.userNotFound.rawValue:
            return "No existe una cuenta con este email"
        case AuthErrorCode.invalidEmail.rawValue:
            return "El formato del email no es válido"
        case AuthErrorCode.networkError.rawValue:
            return "Error de conexión. Verifica tu internet"
        case AuthErrorCode.tooManyRequests.rawValue:
            return "Demasiados intentos. Intenta más tarde"
        default:
            return "Error al iniciar sesión: \(error.localizedDescription)"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo azul claro
                lightBlue.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 15) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 60))
                                .foregroundColor(mainBlue)
                            
                            Text("Password Manager")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(mainBlue)
                            
                            Text("Gestiona tus contraseñas de forma segura")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 50)
                        
                        // Campos de formulario
                        VStack(spacing: 20) {
                            // Campo Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Correo electrónico")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(mainBlue)
                                
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
                            
                            // Campo Contraseña
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Contraseña")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(mainBlue)
                                
                                SecureField("Ingresa tu contraseña", text: $password)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(password.isEmpty ? Color.gray.opacity(0.3) : mainBlue, lineWidth: 1)
                                    )
                            }
                        }
                        
                        // Botón de Iniciar Sesión
                        Button(action: login) {
                            HStack {
                                if isLoading {
                                    Text("⏳")
                                        .font(.system(size: 18))
                                } else {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 18, weight: .medium))
                                }
                                
                                Text(isLoading ? "Iniciando sesión..." : "Iniciar Sesión")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(!email.isEmpty && !password.isEmpty && !isLoading ? mainBlue : Color.gray)
                            .cornerRadius(12)
                            .shadow(color: !email.isEmpty && !password.isEmpty && !isLoading ? mainBlue.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 3)
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                        
                        // BOTONES JUNTOS - Olvidaste contraseña y Crear Cuenta
                        VStack(spacing: 15) {
                            // Botón de recuperación de contraseña
                            Button("¿Olvidaste tu contraseña?") {
                                showingForgotPassword = true
                            }
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(mainBlue)
                            
                            // Separador
                            HStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                                Text("o")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.gray)
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.horizontal, 20)
                            
                            // NavigationLink para Crear Cuenta
                            NavigationLink(destination: RegisterView(isShowingRegisterView: $showingRegister), isActive: $showingRegister) {
                                Button(action: {
                                    showingRegister = true
                                }) {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                            .font(.system(size: 16, weight: .medium))
                                        Text("Crear Cuenta Nueva")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 25)
                                    .padding(.vertical, 12)
                                    .background(mainBlue)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.top, 10)
                        
                        Spacer()
                            .frame(height: 50)
                    }
                    .padding(30)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error de Inicio de Sesión"),
                    message: Text(errorMessage ?? "Credenciales inválidas."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
