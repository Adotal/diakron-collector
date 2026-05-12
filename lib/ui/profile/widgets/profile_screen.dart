import 'package:diakron_collectors/ui/core/ui/error_indicator.dart';
import 'package:diakron_collectors/ui/profile/view_models/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.viewModel});

  final ProfileViewModel viewModel;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();  
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  @override
  void initState() {
    super.initState();
    widget.viewModel.load.execute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListenableBuilder(
        listenable: widget.viewModel.load,
        builder: (context, _) {
          if (widget.viewModel.load.running) {
            return Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.load.error) {
            return ErrorIndicator(
              title: 'Error cargando información',
              label: 'Recargar',
              onPressed: widget.viewModel.load.execute,
            );
          }
          final collector = widget.viewModel.collector;
          final size = MediaQuery.of(context).size;

          // Formateador de fecha: "15 de mayo, 2026"
          final String memberSince = DateFormat(
            'dd MMMM, yyyy',
          ).format(collector.createdAt);
          return Column(
            children: [
              // --- CABECERA ---
              Stack(
                children: [
                  Container(
                    height: size.height * 0.30,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFF38761D),                      
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Text(
                              collector.userName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF38761D),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${collector.userName} ${collector.surnames}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          collector.userType.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // --- LISTA DE INFORMACIÓN ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildInfoSection("Información Personal", [
                      _infoTile(
                        Icons.email_outlined,
                        "Correo electrónico",
                        collector.email,
                      ),
                      _infoTile(
                        Icons.phone_android_outlined,
                        "Teléfono",
                        collector.phoneNumber,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildInfoSection("Cuenta", [
                      _infoTile(
                        Icons.calendar_today_outlined,
                        "Miembro desde",
                        memberSince,
                      ),
                      _statusTile(collector.isActive),
                    ]),
                    const SizedBox(height: 20),

                    // Botón de Cerrar Sesión (Opcional)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: OutlinedButton.icon(
                        onPressed: widget.viewModel.logout.execute,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text("Cerrar Sesión"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Contenedor blanco para agrupar ítems
  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  // Ítem individual de información
  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF38761D)),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Ítem especial para el estado (Activo/Inactivo)
  Widget _statusTile(bool isActive) {
    return ListTile(
      leading: Icon(
        isActive ? Icons.check_circle_outline : Icons.error_outline,
        color: isActive ? Colors.green : Colors.red,
      ),
      title: const Text(
        "Estado de la cuenta",
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        isActive ? "Activo" : "Inactivo",
        style: TextStyle(
          fontSize: 16,
          color: isActive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
