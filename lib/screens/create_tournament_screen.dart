import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';

class CreateTournamentScreen extends StatefulWidget {
  @override
  _CreateTournamentScreenState createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tournamentService = TournamentService();
  
  // Controllers para los campos del formulario
  final _nameController = TextEditingController();
  final _maxPlayersController = TextEditingController();
  
  // Variables para las fechas
  DateTime? _registrationStartDate;
  DateTime? _registrationEndDate;
  DateTime? _tournamentStartDate;
  DateTime? _tournamentEndDate;
  
  // Variables para dropdowns
  String _selectedCategory = 'SINGLES';
  int? _userId;
  bool _isLoading = false;

  final List<String> _categories = [
    'SINGLES',
    'DOUBLES',
    'MIXED',
  ];

  @override
  void initState() {
    super.initState();
    _getUserIdFromToken();
  }

  Future<void> _getUserIdFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      final decodedToken = JwtDecoder.decode(token);
      setState(() {
        _userId = decodedToken['userId'];
      });
    }
  }

  // Validación de fechas de registro
  bool _validateRegistrationDates() {
    if (_registrationStartDate != null && _registrationEndDate != null) {
      if (_registrationEndDate!.isBefore(_registrationStartDate!)) {
        _showDateErrorDialog(
          'Error en Fechas de Registro',
          'La fecha de fin de registro no puede ser anterior a la fecha de inicio de registro.',
          'Por favor, selecciona una fecha de fin posterior o igual a la fecha de inicio.'
        );
        return false;
      }
    }
    return true;
  }

  // Validación de fechas del torneo
  bool _validateTournamentDates() {
    if (_tournamentStartDate != null && _tournamentEndDate != null) {
      if (_tournamentEndDate!.isBefore(_tournamentStartDate!)) {
        _showDateErrorDialog(
          'Error en Fechas del Torneo',
          'La fecha de fin del torneo no puede ser anterior a la fecha de inicio del torneo.',
          'Por favor, selecciona una fecha de fin posterior o igual a la fecha de inicio.'
        );
        return false;
      }
    }
    return true;
  }

  // Validación de que las fechas del torneo sean posteriores a las de registro
  bool _validateTournamentAfterRegistration() {
    if (_registrationEndDate != null && _tournamentStartDate != null) {
      if (_tournamentStartDate!.isBefore(_registrationEndDate!)) {
        _showDateErrorDialog(
          'Error en Fechas',
          'El torneo debe comenzar después del período de registro.',
          'La fecha de inicio del torneo debe ser posterior a la fecha de fin de registro.'
        );
        return false;
      }
    }
    return true;
  }

  // Diálogo elegante de error de fechas
  void _showDateErrorDialog(String title, String message, String suggestion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_today, color: Colors.red[700], size: 30),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.red[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Entendido',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isRegistrationStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isRegistrationStart) {
          _registrationStartDate = picked;
          // Si la fecha de fin de registro es anterior a la nueva fecha de inicio, la limpiamos
          if (_registrationEndDate != null && _registrationEndDate!.isBefore(picked)) {
            _registrationEndDate = null;
          }
        } else {
          _registrationEndDate = picked;
        }
      });
    }
  }

  Future<void> _selectTournamentDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _registrationEndDate ?? DateTime.now().add(Duration(days: 7)),
      firstDate: _registrationEndDate ?? DateTime.now().add(Duration(days: 7)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[700]!,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _tournamentStartDate = picked;
          // Si la fecha de fin del torneo es anterior a la nueva fecha de inicio, la limpiamos
          if (_tournamentEndDate != null && _tournamentEndDate!.isBefore(picked)) {
            _tournamentEndDate = null;
          }
        } else {
          _tournamentEndDate = picked;
        }
      });
    }
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validaciones de fechas
    if (!_validateRegistrationDates()) return;
    if (!_validateTournamentDates()) return;
    if (!_validateTournamentAfterRegistration()) return;
    
    // Validar que todas las fechas estén seleccionadas
    if (_registrationStartDate == null || _registrationEndDate == null || 
        _tournamentStartDate == null || _tournamentEndDate == null) {
      _showErrorDialog('Fechas Incompletas', 'Por favor, selecciona todas las fechas requeridas.');
      return;
    }
    
    if (_userId == null) {
      _showErrorDialog('Error', 'No se pudo obtener el ID del usuario');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tournament = Tournament(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        registrationStartDate: _registrationStartDate!,
        registrationEndDate: _registrationEndDate!,
        tournamentStartDate: _tournamentStartDate!,
        tournamentEndDate: _tournamentEndDate!,
        maxPlayers: int.parse(_maxPlayersController.text),
        createdBy: _userId!,
      );

      final createdTournament = await _tournamentService.createTournament(tournament);
      
      setState(() {
        _isLoading = false;
      });

      _showSuccessDialog(createdTournament);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error', e.toString());
    }
  }

  void _showSuccessDialog(Tournament tournament) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('¡Torneo Creado!', style: TextStyle(color: Colors.green)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('El torneo se ha creado exitosamente con los siguientes datos:'),
              SizedBox(height: 15),
              _buildInfoRow('Nombre:', tournament.name),
              _buildInfoRow('Categoría:', tournament.category),
              _buildInfoRow('Máx. Jugadores:', tournament.maxPlayers.toString()),
              _buildInfoRow('ID del Torneo:', tournament.tournamentId.toString()),
              _buildInfoRow('Fecha de Inicio:', DateFormat('dd/MM/yyyy').format(tournament.tournamentStartDate)),
              _buildInfoRow('Fecha de Fin:', DateFormat('dd/MM/yyyy').format(tournament.tournamentEndDate)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Volver a la pantalla anterior
              },
              child: Text('Aceptar', style: TextStyle(color: Colors.green[700])),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text(title, style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Aceptar', style: TextStyle(color: Colors.red[700])),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Torneo'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[50]!, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card principal del formulario
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título del formulario
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                size: 50,
                                color: Colors.green[700],
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Información del Torneo',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),

                        // Campo Nombre del Torneo
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del Torneo',
                            prefixIcon: Icon(Icons.sports_tennis, color: Colors.green[700]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingrese el nombre del torneo';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        // Campo Categoría
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            prefixIcon: Icon(Icons.category, color: Colors.green[700]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                            ),
                          ),
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                            });
                          },
                        ),
                        SizedBox(height: 20),

                        // Campo Máximo de Jugadores
                        TextFormField(
                          controller: _maxPlayersController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Máximo de Jugadores',
                            prefixIcon: Icon(Icons.people, color: Colors.green[700]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(color: Colors.green[700]!, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingrese el máximo de jugadores';
                            }
                            final number = int.tryParse(value);
                            if (number == null || number <= 0) {
                              return 'Por favor ingrese un número válido mayor a 0';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),

                        // Sección de Fechas
                        Text(
                          'Fechas de Registro',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 15),

                        // Fecha de Inicio de Registro
                        ListTile(
                          leading: Icon(Icons.calendar_today, color: Colors.green[700]),
                          title: Text('Inicio de Registro'),
                          subtitle: Text(
                            _registrationStartDate != null
                                ? DateFormat('dd/MM/yyyy').format(_registrationStartDate!)
                                : 'Seleccionar fecha',
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                          onTap: () => _selectDate(context, true),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        SizedBox(height: 10),

                        // Fecha de Fin de Registro
                        ListTile(
                          leading: Icon(Icons.calendar_today, color: Colors.green[700]),
                          title: Text('Fin de Registro'),
                          subtitle: Text(
                            _registrationEndDate != null
                                ? DateFormat('dd/MM/yyyy').format(_registrationEndDate!)
                                : 'Seleccionar fecha',
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                          onTap: () => _selectDate(context, false),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        SizedBox(height: 30),

                        // Sección de Fechas del Torneo
                        Text(
                          'Fechas del Torneo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        SizedBox(height: 15),

                        // Fecha de Inicio del Torneo
                        ListTile(
                          leading: Icon(Icons.event, color: Colors.green[700]),
                          title: Text('Inicio del Torneo'),
                          subtitle: Text(
                            _tournamentStartDate != null
                                ? DateFormat('dd/MM/yyyy').format(_tournamentStartDate!)
                                : 'Seleccionar fecha',
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                          onTap: () => _selectTournamentDate(context, true),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        SizedBox(height: 10),

                        // Fecha de Fin del Torneo
                        ListTile(
                          leading: Icon(Icons.event, color: Colors.green[700]),
                          title: Text('Fin del Torneo'),
                          subtitle: Text(
                            _tournamentEndDate != null
                                ? DateFormat('dd/MM/yyyy').format(_tournamentEndDate!)
                                : 'Seleccionar fecha',
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                          onTap: () => _selectTournamentDate(context, false),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Botón de Crear Torneo
                ElevatedButton(
                  onPressed: _isLoading ? null : _createTournament,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Creando Torneo...'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Crear Torneo',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _maxPlayersController.dispose();
    super.dispose();
  }
}