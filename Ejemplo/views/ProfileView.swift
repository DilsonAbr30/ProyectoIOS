import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showingChangePassword = false
    @State private var showingLogoutAlert = false
    
    // Colores azules (consistentes con tu app)
    let mainBlue = Color(red: 0.1, green: 0.3, blue: 0.7)
    let lightBlue = Color(red: 0.9, green: 0.95, blue: 1.0)
    
    var user: User? {
        return Auth.auth().currentUser
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                lightBlue.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(mainBlue)
                        
                        Text(user?.displayName ?? "Usuario")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(mainBlue)
                        
                        Text(user?.email ?? "No email")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 30)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    
                    // Opciones
                    ScrollView {
                        VStack(spacing: 16) {
                            // Seguridad
                            VStack(alignment: .leading, spacing: 12) {
                                Text("SEGURIDAD")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 0) {
                                    // Cambiar contraseña
                                    Button(action: {
                                        showingChangePassword = true
                                    }) {
                                        HStack {
                                            Image(systemName: "key.fill")
                                                .foregroundColor(mainBlue)
                                                .frame(width: 20)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("Cambiar Contraseña Maestra")
                                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                                    .foregroundColor(.primary)
                                                Text("Actualiza tu contraseña de acceso")
                                                    .font(.system(size: 12, design: .rounded))
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 14))
                                        }
                                        .padding()
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationBarTitle("Perfil", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cerrar") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(mainBlue)
                .font(.system(size: 16, weight: .medium))
            )
            .sheet(isPresented: $showingChangePassword) {
                ChangeMasterPasswordView()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
