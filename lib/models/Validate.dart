class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove all spaces, dashes, and parentheses
    String cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check if it starts with +91 (India country code)
    if (cleanedPhone.startsWith('+91')) {
      cleanedPhone = cleanedPhone.substring(3);
    } else if (cleanedPhone.startsWith('91') && cleanedPhone.length == 12) {
      cleanedPhone = cleanedPhone.substring(2);
    }

    // Indian mobile number should be 10 digits and start with 6, 7, 8, or 9
    if (cleanedPhone.length != 10) {
      return 'Phone number must be 10 digits';
    }

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(cleanedPhone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }
}