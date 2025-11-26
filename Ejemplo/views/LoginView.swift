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
    
    // Animación de entrada
    @State private var appear = false
    
    // Colores personalizados (Gradientes)
    let gradientStart = Color(red: 0.1, green: 0.3, blue: 0.8) // Azul intenso
    let gradientEnd = Color(red: 0.4, green: 0.1, blue: 0.6)   // Toque morado moderno
    
    // Función de login
    func login() {
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
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func getLoginErrorMessage(_ error: Error) -> String {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue: return "Contraseña incorrecta"
        case AuthErrorCode.userNotFound.rawValue: return "No existe una cuenta con este email"
        case AuthErrorCode.invalidEmail.rawValue: return "El formato del email no es válido"
        case AuthErrorCode.networkError.rawValue: return "Error de conexión. Verifica tu internet"
        default: return "Error: \(error.localizedDescription)"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 1. FONDO CREATIVO CON GRADIENTE ANIMADO
                LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                // Círculos decorativos de fondo (Efecto bokeh sutil)
                Circle()
                    .fill(Color.white.opacity(0.1)) // CORREGIDO: Color.white
                    .frame(width: 300, height: 300)
                    .offset(x: -100, y: -300)
                    .blur(radius: 20)
                
                Circle()
                    .fill(Color.white.opacity(0.1)) // CORREGIDO: Color.white
                    .frame(width: 250, height: 250)
                    .offset(x: 150, y: 350)
                    .blur(radius: 20)
                
                ScrollView {
                    VStack(spacing: 35) {
                        
                        // 2. LOGO Y TÍTULO ANIMADOS
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2)) // CORREGIDO: Color.white
                                    .frame(width: 110, height: 110)
                                
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color.white) // CORREGIDO: Color.white
                                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5) // CORREGIDO: Color.black
                            }
                            .scaleEffect(appear ? 1 : 0.5)
                            .opacity(appear ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
                            
                            Text("Password Manager")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundColor(Color.white) // CORREGIDO: Color.white
                                .shadow(radius: 5)
                                .opacity(appear ? 1 : 0)
                                .animation(Animation.easeOut(duration: 0.8).delay(0.2))
                            
                            Text("Tu seguridad en un solo lugar")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.8)) // CORREGIDO: Color.white
                                .opacity(appear ? 1 : 0)
                                .animation(Animation.easeOut(duration: 0.8).delay(0.4))
                        }
                        .padding(.top, 60)
                        
                        // 3. FORMULARIO CON ESTILO "CRISTAL" (Glassmorphism)
                        VStack(spacing: 25) {
                            
                            // Campo Email
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CORREO ELECTRÓNICO")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white.opacity(0.8)) // CORREGIDO: Color.white
                                
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(Color.white.opacity(0.7)) // CORREGIDO: Color.white
                                    TextField("", text: $email)
                                        // Placeholder personalizado blanco
                                        .placeholder(when: email.isEmpty) {
                                            Text("ejemplo@correo.com").foregroundColor(Color.white.opacity(0.5)) // CORREGIDO: Color.white
                                        }
                                        .foregroundColor(Color.white) // CORREGIDO: Color.white
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                }
                                .padding()
                                .background(Color.white.opacity(0.2)) // CORREGIDO: Color.white
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1) // CORREGIDO: Color.white
                                )
                            }
                            
                            // Campo Contraseña
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CONTRASEÑA")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.white.opacity(0.8)) // CORREGIDO: Color.white
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(Color.white.opacity(0.7)) // CORREGIDO: Color.white
                                    SecureField("", text: $password)
                                        .placeholder(when: password.isEmpty) {
                                            Text("••••••••").foregroundColor(Color.white.opacity(0.5)) // CORREGIDO: Color.white
                                        }
                                        .foregroundColor(Color.white) // CORREGIDO: Color.white
                                }
                                .padding()
                                .background(Color.white.opacity(0.2)) // CORREGIDO: Color.white
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1) // CORREGIDO: Color.white
                                )
                            }
                            
                            // Botón Olvidaste Contraseña
                            HStack {
                                Spacer()
                                Button(action: { showingForgotPassword = true }) {
                                    Text("¿Olvidaste tu contraseña?")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.white) // CORREGIDO: Color.white
                                        .underline(true, color: Color.white.opacity(0.5)) // CORREGIDO: Color.white
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                        .opacity(appear ? 1 : 0)
                        .offset(y: appear ? 0 : 20)
                        .animation(Animation.easeOut(duration: 0.8).delay(0.6))
                        
                        Spacer().frame(height: 10)
                        
                        // 4. BOTONES DE ACCIÓN
                        VStack(spacing: 20) {
                            // Botón Login Grande
                            Button(action: login) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.white) // CORREGIDO: Color.white
                                        .frame(height: 55)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5) // CORREGIDO: Color.black
                                    
                                    HStack {
                                        if isLoading {
                                            // Usamos el ActivityIndicator compatible si lo tienes,
                                            // sino un texto simple para evitar errores.
                                            // Si tienes ActivityIndicator.swift, usa:
                                            // ActivityIndicator(isAnimating: .constant(true), style: .medium)
                                            Text("Cargando...")
                                                .foregroundColor(gradientStart)
                                        } else {
                                            Text("Iniciar Sesión")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(gradientStart)
                                            Image(systemName: "arrow.right")
                                                .font(.headline)
                                                .foregroundColor(gradientStart)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                            .disabled(email.isEmpty || password.isEmpty || isLoading)
                            .opacity(email.isEmpty || password.isEmpty ? 0.7 : 1)
                            
                            // Botón Crear Cuenta (Secundario)
                            NavigationLink(destination: RegisterView(isShowingRegisterView: $showingRegister), isActive: $showingRegister) {
                                Button(action: { showingRegister = true }) {
                                    Text("¿No tienes cuenta? **Regístrate**")
                                        .foregroundColor(Color.white) // CORREGIDO: Color.white
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .padding(.bottom, 40)
                        .opacity(appear ? 1 : 0)
                        .animation(Animation.easeOut(duration: 0.8).delay(0.8))
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                self.appear = true
            }
            .sheet(isPresented: $showingForgotPassword) {
                ForgotPasswordView()
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Atención"),
                    message: Text(errorMessage ?? "Error desconocido"),
                    dismissButton: .default(Text("Entendido"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// Extensión para placeholder personalizado
// Si ya la tienes en RegisterView y te da error de "redeclaration", BORRA ESTAS LÍNEAS.
// Solo necesitas tenerla una vez en todo el proyecto.
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


