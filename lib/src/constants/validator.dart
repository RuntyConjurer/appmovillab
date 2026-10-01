import 'package:form_field_validator/form_field_validator.dart';

final emailValidator = MultiValidator([
  RequiredValidator(errorText: 'El correo es requerido'),
  EmailValidator(errorText: 'Ingrese un correo válido'),
]);

final nameValidator = MultiValidator([
  RequiredValidator(errorText: 'El nombre es requerido'),
  MinLengthValidator(
    3,
    errorText: 'El nombre debe tener al menos 3 caracteres',
  ),
]);

final passwordValidator = MultiValidator([
  RequiredValidator(errorText: 'La contraseña es requerida'),
  MinLengthValidator(
    8,
    errorText: 'La contraseña debe tener al menos 8 caracteres',
  ),
]);

String? confirmPasswordValidator(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Debe confirmar la contraseña';
  }
  if (value != password) {
    return 'Las contraseñas no coinciden';
  }
  return null;
}
