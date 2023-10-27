import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ConfigScreen extends StatefulWidget {
  final Function(Color, Color, Color, Color, Color) onThemeChanged;

  ConfigScreen({required this.onThemeChanged});

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  Color _primaryColor = Color(0xFFDA4040);
  Color _accentColor = Color.fromARGB(255, 12, 77, 255);
  Color _backgroundColor = Color(0xFFEEEFF5);
  Color _textColor = Color(0xFF3A3A3A);
  Color _secondaryColor = Color(0xFF717171);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações de Tema'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildColorPicker(
            'Cor Primária',
            _primaryColor,
            (color) => setState(() => _primaryColor = color),
          ),
          _buildColorPicker(
            'Cor de Destaque',
            _accentColor,
            (color) => setState(() => _accentColor = color),
          ),
          _buildColorPicker(
            'Cor de Fundo',
            _backgroundColor,
            (color) => setState(() => _backgroundColor = color),
          ),
          _buildColorPicker(
            'Cor de Texto',
            _textColor,
            (color) => setState(() => _textColor = color),
          ),
          _buildColorPicker(
            'Cor Secundária',
            _secondaryColor,
            (color) => setState(() => _secondaryColor = color),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.onThemeChanged(
                _primaryColor,
                _accentColor,
                _backgroundColor,
                _textColor,
                _secondaryColor,
              );
              Navigator.pop(context);
            },
            child: Text('Salvar Configurações de Tema'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(
      String title, Color color, Function(Color) onColorChanged) {
    return ListTile(
      title: Text(title),
      trailing: GestureDetector(
        onTap: () => _showColorPicker(context, onColorChanged),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, Function(Color) onColorChanged) {
    Color selectedColor = Colors.white; // Defina a cor padrão que você preferir

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Escolha uma cor'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Selecionar'),
              onPressed: () {
                onColorChanged(selectedColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
