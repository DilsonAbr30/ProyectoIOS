import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    // Variable para manejar la presentación de la vista
    @Binding var isShowingRegisterView: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var showAlert = false
    @State private var isLoading = false
    
    // Animación de entrada
    @State private var appear = false
    
    // Colores personalizados
    let gradientStart = Color(red: 0.1, green: 0.3, blue: 0.8)
    let gradientEnd = Color(red: 0.4, green: 0.1, blue: 0.6)
    
    // Función de registro de Firebase Auth
    func register() {
        guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "Por favor completa todos los campos."
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Las contraseñas no coinciden."
            showAlert = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres."
            showAlert = true
            return
        }
        
        isLoading = true
        
        // Llamada a la API de Firebase
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            isLoading = false
            
            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
            } else {
                print("Usuario registrado exitosamente: \(result?.user.uid ?? "N/A")")
                self.isShowingRegisterView = false
            }
        }
    }
    
    var body: some View {
        ZStack {
            // 1. FONDO CON GRADIENTE ANIMADO
            LinearGradient(gradient: Gradient(colors: [gradientStart, gradientEnd]), startPoint: .bottomLeading, endPoint: .topTrailing)
                .edgesIgnoringSafeArea(.all)
            
            // Elementos decorativos de fondo
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 200, height: 200)
                .offset(x: -120, y: -350)
                .blur(radius: 20)
            
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: 120, y: 300)
                .blur(radius: 20)
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    // 2. CABECERA
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(Color.white)
                            .padding(.bottom, 10)
                            .shadow(radius: 5)
                        
                        Text("Crear Nueva Cuenta")
                            .font(.system(size: 32, weight: .heavy, design: .rounded))
                            .foregroundColor(Color.white)
                            .shadow(radius: 5)
                        
                        Text("Únete y protege tus datos hoy")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                    .padding(.top, 40)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : -20)
                    .animation(Animation.easeOut(duration: 0.8))
                    
                    // 3. FORMULARIO GLASSMORPHISM
                    VStack(spacing: 25) {
                        
                        // Campo Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CORREO ELECTRÓNICO")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white.opacity(0.8))
                            
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(Color.white.opacity(0.7))
                                TextField("", text: $email)
                                    .placeholder(when: email.isEmpty) {
                                        Text("ejemplo@correo.com").foregroundColor(Color.white.opacity(0.5))
                                    }
                                    .foregroundColor(Color.white)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.3), lineWidth: 1))
                        }
                        
                        // Campo Contraseña
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CONTRASEÑA")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white.opacity(0.8))
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color.white.opacity(0.7))
                                SecureField("", text: $password)
                                    .placeholder(when: password.isEmpty) {
                                        Text("Mínimo 6 caracteres").foregroundColor(Color.white.opacity(0.5))
                                    }
                                    .foregroundColor(Color.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.3), lineWidth: 1))
                        }
                        
                        // Campo Confirmar Contraseña
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CONFIRMAR CONTRASEÑA")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(Color.white.opacity(0.8))
                            
                            HStack {
                                Image(systemName: "checkmark.shield.fill")
                                    .foregroundColor(Color.white.opacity(0.7))
                                SecureField("", text: $confirmPassword)
                                    .placeholder(when: confirmPassword.isEmpty) {
                                        Text("Repite tu contraseña").foregroundColor(Color.white.opacity(0.5))
                                    }
                                    .foregroundColor(Color.white)
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.3), lineWidth: 1))
                        }
                        
                    }
                    .padding(.horizontal, 30)
                    .opacity(appear ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.8).delay(0.3))
                    
                    Spacer().frame(height: 10)
                    
                    // 4. BOTÓN DE REGISTRO
                    Button(action: register) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .frame(height: 55)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            
                            HStack {
                                if isLoading {
                                    // Reemplazo compatible para iOS 13/14
                                    ActivityIndicator(isAnimating: .constant(true), style: .medium)
                                } else {
                                    Text("Crear Cuenta")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(gradientEnd)
                                    if #available(iOS 14.0, *) {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(gradientEnd)
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(Animation.easeOut(duration: 0.8).delay(0.5))
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    
                    // Botón Volver (Texto simple)
                    Button(action: {
                        self.isShowingRegisterView = false
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Volver al Inicio de Sesión")
                        }
                        .foregroundColor(Color.white.opacity(0.8))
                        .font(.system(size: 15, weight: .medium))
                    }
                    .padding(.bottom, 30)
                    
                } // End VStack Principal
            } // End ScrollView
        } // End ZStack
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onAppear {
            self.appear = true
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error de Registro"), message: Text(errorMessage ?? "Ocurrió un error desconocido."), dismissButton: .default(Text("OK")))
        }
    }
}

// Componente compatible para el Spinner (Activity Indicator) en versiones viejas
struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(isShowingRegisterView: .constant(true))
    }
}
