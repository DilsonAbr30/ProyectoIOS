import SwiftUI
import FirebaseAuth

struct MainListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var passwordViewModel = PasswordViewModel()
    
    @State private var searchText = ""
    @State private var showAddPassword = false
    @State private var showLogoutConfirmation = false
    @State private var showProfile = false
    @State private var isRefreshing = false
    
    // Color azul principal
    let mainBlue = Color(red: 0.1, green: 0.3, blue: 0.7)
    let lightBlue = Color(red: 0.9, green: 0.95, blue: 1.0)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo general con degradado
                LinearGradient(
                    gradient: Gradient(colors: [lightBlue, mainBlue.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                // NavigationLinks ocultos
                NavigationLink(destination: AddPasswordView(passwordViewModel: passwordViewModel),
                               isActive: $showAddPassword) { EmptyView() }

                NavigationLink(destination: ProfileView(), isActive: $showProfile) { EmptyView() }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {

                        // -------------------------------------------------------
                        // HEADER MODERNO
                        // -------------------------------------------------------
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mis Contraseñas")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(mainBlue)

                            Text("\(passwordViewModel.passwords.count) guardadas")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)

                            HStack(spacing: 22) {
                                headerButton(
                                    icon: "person.crop.circle.fill",
                                    text: "Perfil",
                                    color: mainBlue
                                ) { showProfile = true }

                                headerButton(
                                    icon: "arrow.clockwise.circle.fill",
                                    text: isRefreshing ? "Actualizando..." : "Refrescar",
                                    color: mainBlue
                                ) { refreshPasswords() }
                                .opacity(isRefreshing ? 0.6 : 1)

                                headerButton(
                                    icon: "plus.circle.fill",
                                    text: "Agregar",
                                    color: mainBlue
                                ) { showAddPassword = true }

                                headerButton(
                                    icon: "rectangle.portrait.and.arrow.right",
                                    text: "Salir",
                                    color: .red
                                ) { showLogoutConfirmation = true }
                            }
                            .padding(.top, 4)

                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 4)
                        .padding(.horizontal)

                        // -------------------------------------------------------
                        // BARRA DE BÚSQUEDA
                        // -------------------------------------------------------
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(mainBlue)

                            TextField("Buscar servicios...", text: $searchText)
                                .font(.system(size: 16, weight: .medium))

                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(14)
                        .background(Color.white)
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal)

                        // -------------------------------------------------------
                        // LISTA VACÍA
                        // -------------------------------------------------------
                        if passwordViewModel.passwords.isEmpty {
                            VStack(spacing: 18) {
                                Image(systemName: "lock.shield")
                                    .font(.system(size: 70))
                                    .foregroundColor(mainBlue.opacity(0.5))

                                Text("Aún no tienes contraseñas 🧩")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(mainBlue)

                                Text("Presiona el botón Agregar para crear tu primera contraseña")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)

                                Button(action: { refreshPasswords() }) {
                                    Text(isRefreshing ? "Actualizando..." : "Actualizar Lista")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(mainBlue)
                                        .cornerRadius(12)
                                        .shadow(color: mainBlue.opacity(0.3), radius: 5, x: 0, y: 3)
                                }
                                .disabled(isRefreshing)
                            }
                            .padding(.top, 40)
                            .padding(.horizontal, 32)

                        } else {
                            // -------------------------------------------------------
                            // LISTA CON ELEMENTOS
                            // -------------------------------------------------------
                            VStack(spacing: 12) {
                                ForEach(passwordViewModel.passwords) { password in
                                    NavigationLink(
                                        destination: PasswordDetailView(
                                            password: password,
                                            passwordViewModel: passwordViewModel
                                        )
                                    ) {
                                        HStack(spacing: 14) {

                                            ZStack {
                                                Circle()
                                                    .fill(mainBlue.opacity(0.1))
                                                    .frame(width: 50, height: 50)

                                                Image(systemName: getIconForService(password.service))
                                                    .font(.system(size: 20, weight: .medium))
                                                    .foregroundColor(mainBlue)
                                            }

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(password.service)
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundColor(mainBlue)

                                                Text(password.username)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.gray)
                                            }

                                            Spacer()

                                            Image(systemName: "checkmark.shield.fill")
                                                .foregroundColor(.green)
                                        }
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 3)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }

                        Spacer().frame(height: 50)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showLogoutConfirmation) {
                Alert(
                    title: Text("Cerrar Sesión"),
                    message: Text("¿Deseas salir de tu cuenta?"),
                    primaryButton: .destructive(Text("Cerrar Sesión")) {
                        authViewModel.signOut()
                    },
                    secondaryButton: .cancel(Text("Cancelar"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func headerButton(icon: String, text: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(color)

                Text(text)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(color)
            }
            .padding(8)
        }
    }

    private func refreshPasswords() {
        isRefreshing = true
        passwordViewModel.refreshPasswords()
        
        // Simular un pequeño delay para el feedback visual
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isRefreshing = false
        }
    }
    
    // Función para obtener ícono según el servicio
    private func getIconForService(_ service: String) -> String {
        let lowercased = service.lowercased()
        
        if lowercased.contains("twitter") || lowercased.contains("x.com") {
            return "bird.fill"
        } else if lowercased.contains("gmail") || lowercased.contains("google") {
            return "envelope.fill"
        } else if lowercased.contains("facebook") {
            return "f.circle.fill"
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
        } else if lowercased.contains("tiktok") {
            return "music.note.list"
        } else if lowercased.contains("discord") {
            return "bubble.left.fill"
        } else if lowercased.contains("telegram") {
            return "paperplane.fill"
        } else if lowercased.contains("snapchat") {
            return "camera.viewfinder"
        } else if lowercased.contains("pinterest") {
            return "pin.fill"
        } else if lowercased.contains("reddit") {
            return "r.circle.fill"
        } else if lowercased.contains("twitch") {
            return "gamecontroller.fill"
        } else if lowercased.contains("paypal") {
            return "dollarsign.circle.fill"
        } else if lowercased.contains("ebay") {
            return "cart.fill"
        } else if lowercased.contains("airbnb") {
            return "house.fill"
        } else if lowercased.contains("uber") {
            return "car.fill"
        } else if lowercased.contains("dropbox") {
            return "folder.fill"
        } else if lowercased.contains("github") {
            return "chevron.left.slash.chevron.right"
        } else if lowercased.contains("slack") {
            return "bubble.left.and.bubble.right.fill"
        } else if lowercased.contains("zoom") {
            return "video.fill"
        } else if lowercased.contains("skype") {
            return "video.circle.fill"
        } else if lowercased.contains("outlook") || lowercased.contains("hotmail") {
            return "envelope.open.fill"
        } else if lowercased.contains("yahoo") {
            return "y.circle.fill"
        } else if lowercased.contains("tumblr") {
            return "t.circle.fill"
        } else if lowercased.contains("flickr") {
            return "photo.fill"
        } else if lowercased.contains("vimeo") {
            return "play.circle.fill"
        } else if lowercased.contains("wordpress") {
            return "w.circle.fill"
        } else if lowercased.contains("blogger") {
            return "book.fill"
        } else if lowercased.contains("wechat") {
            return "message.circle.fill"
        } else if lowercased.contains("line") {
            return "line.diagonal"
        } else if lowercased.contains("bank") || lowercased.contains("banco") {
            return "banknote.fill"
        } else if lowercased.contains("email") || lowercased.contains("correo") {
            return "envelope.fill"
        } else if lowercased.contains("wifi") {
            return "wifi"
        } else if lowercased.contains("vpn") {
            return "network"
        } else {
            return "lock.fill"
        }
    }
}

