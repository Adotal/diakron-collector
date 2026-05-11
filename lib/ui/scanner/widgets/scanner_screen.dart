import 'package:diakron_collectors/ui/core/themes/colors.dart';
import 'package:diakron_collectors/ui/core/themes/dimens.dart';
import 'package:diakron_collectors/ui/core/ui/custom_screen.dart';
import 'package:diakron_collectors/ui/core/ui/error_indicator.dart';
import 'package:diakron_collectors/ui/core/ui/success_indicator.dart';
import 'package:diakron_collectors/ui/scanner/view_models/scanner_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key, required this.viewModel});

  final ScannerViewModel viewModel;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScreen(
      title: 'Escanear QR de canjeo',
      actions: [
        ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {          
            return IconButton(
              onPressed: widget.viewModel.selectedMaterials.isNotEmpty
                  ? widget.viewModel.resetSelection
                  : null,
              icon: Icon(Icons.restart_alt),
            );
          },
        ),
      ],
      child: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            // 1. Si no ha confirmado la selección, mostrar el menú
            if (!widget.viewModel.isScanning) {
              return _buildMaterialMultiSelection();
            }

            final verifyCommand = widget.viewModel.verifyQR;
            if (verifyCommand.running) {
              return const Center(child: CircularProgressIndicator());
            }

            if (verifyCommand.error) {
              // Ajustar error
              final errorMessage = verifyCommand.result.toString();

              return ErrorIndicator(
                title: errorMessage,
                label: 'Escanear otra vez',
                onPressed: () => verifyCommand.clearResult(),
              );
            }

            if (verifyCommand.completed) {
              return Center(
                child: Column(
                  children: [
                    SizedBox(height: Dimens.paddingVertical),
                    SuccessIndicator(
                      title:
                          '¡Canje registrado exitosamente!\nPuedes entregar el siguiente beneficio al cliente',
                      label: 'Escanear otra vez',
                      onPressed: () => verifyCommand.clearResult(),
                    ),

                    ListenableBuilder(
                      listenable: widget.viewModel.loadCoupon,
                      builder: (context, child) {
                        if (widget.viewModel.loadCoupon.running) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (widget.viewModel.loadCoupon.error) {
                          return Center(
                            child: ErrorIndicator(
                              title: 'Error loading Coupon Info',
                              label: 'Try again',
                              onPressed: widget.viewModel.loadCoupon.execute,
                            ),
                          );
                        }
                        // Here show info about collection
                        return Text('EXITO');
                      },
                    ),
                  ],
                ),
              );
            }

            // Si ya eligió y no hay proceso de carga, mostrar cámara
            return Stack(
              children: [
                MobileScanner(onDetect: widget.viewModel.handleBarcode),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 150,
                    padding: const EdgeInsets.all(
                      20,
                    ), // Preferible sobre EdgeInsetsGeometry.all
                    color: const Color.fromRGBO(0, 0, 0, 0.4),
                    // Eliminado el Row vacío para limpiar el árbol de widgets
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMaterialMultiSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return Column(
            children: [
              const Text(
                '¿Qué materiales vas a recolectar?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona todos los que apliquen',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: widget.viewModel.materials.map((material) {
                    final isSelected = widget.viewModel.selectedMaterials
                        .contains(material);

                    return InkWell(
                      onTap: () => widget.viewModel.toggleMaterial(material),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withAlpha(30),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            if (isSelected)
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _getMaterialIcon(material, isSelected),
                                  const SizedBox(height: 8),
                                  Text(
                                    material,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Botón de Confirmación
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: widget.viewModel.selectedMaterials.isNotEmpty
                      ? () => widget.viewModel.startScanning()
                      : null,

                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 60),
                    backgroundColor: AppColors.greenDiakron1,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'EMPEZAR ESCANEO (${widget.viewModel.selectedMaterials.length})',
                  ),
                ),
              ),

              // FormButton(text: "EMPEZAR ESCANEO", onPressed:
              // widget.viewModel.selectedMaterials.isNotEmpty
              //       ? () => widget.viewModel.startScanning()
              //       : null
              // , listenable: widget.viewModel.),
              // ElevatedButton(
              //   onPressed: widget.viewModel.selectedMaterials.isNotEmpty
              //       ? () => widget.viewModel.startScanning()
              //       : null, // Deshabilitado si no hay selección
              //   style: ElevatedButton.styleFrom(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              //   child: Text(
              //     'EMPEZAR ESCANEO (${widget.viewModel.selectedMaterials.length})',
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }

  // Helper para iconos con cambio de color
  Widget _getMaterialIcon(String material, bool isSelected) {
    IconData icon;
    switch (material) {
      case 'Metal':
        icon = Icons.settings_suggest;
        break;
      case 'Plástico':
        icon = Icons.science;
        break;
      case 'Papel/Cartón':
        icon = Icons.inventory_2;
        break;
      case 'Vidrio':
        icon = Icons.local_bar;
        break;
      default:
        icon = Icons.category;
    }
    return Icon(
      icon,
      size: 40,
      color: isSelected ? Colors.white : Theme.of(context).primaryColor,
    );
  }
}
