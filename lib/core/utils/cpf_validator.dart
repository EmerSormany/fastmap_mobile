abstract class CpfValidator {
  static String? validar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira seu CPF';
    }

    // Remove caracteres especiais como pontos e traços
    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cpf.length != 11) {
      return 'O CPF deve conter 11 dígitos';
    }

    // Rejeita sequências repetidas conhecidas (ex: 11111111111)
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) {
      return 'CPF inválido';
    }

    // Validação do primeiro dígito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(cpf[i]) * (10 - i);
    }
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;

    if (int.parse(cpf[9]) != digito1) {
      return 'CPF inválido';
    }

    // Validação do segundo dígito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(cpf[i]) * (11 - i);
    }
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;

    if (int.parse(cpf[10]) != digito2) {
      return 'CPF inválido';
    }

    return null; // CPF Válido!
  }
}