class SimplePasswordValidator {
  static String? validatePassword(String? password) {
    if (password == null || password.trim().isEmpty) {
      return 'La contraseña es obligatoria';
    }

    // Verificar que tenga al menos 6 caracteres
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    // Verificar que sea alfanumérica (solo letras y números)
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(password)) {
      return 'La contraseña solo puede contener letras y números';
    }

    // Verificar que contenga al menos una letra (no solo números)
    if (!RegExp(r'.*[a-zA-Z].*').hasMatch(password)) {
      return 'La contraseña debe contener al menos una letra';
    }

    return null; // Contraseña válida
  }
} 