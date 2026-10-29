import '../../../generated/l10n.dart';
import '../logger/logger.dart';

class Validator {
  static bool isValidEmail(String email) => RegExp(
    r"^(([^<>()[\]\\.,;:\s@\']+(\.[^<>()[\]\\.,;:\s@\']+)*)|(\'.+\'))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$",
  ).hasMatch(email);

  static bool validatePhone(String phone) =>
      RegExp(r"^(03|05|07|08|09|01)+([0-9]{8})$").hasMatch(phone);

  // TODO: Change this
  /// Ít nhất 8 kí tự.
  /// Ít nhất 1 letter và 1 số
  // static bool validatePassword(String password) {
  //   return RegExp(r"^[A-Za-z\d!@#$%^&*]{8,100}$").hasMatch(password);
  // }

  static bool validate0to9Character(String string) {
    return RegExp(r"^(?=.*?[0-9])$").hasMatch(string);
  }

  static bool isEmptyOrNull(String text) {
    return text.isEmpty;
  }

  /// Kiểm tra chuỗi có rỗng hoặc chỉ chứa khoảng trắng hay không (bao gồm cả các ký tự khoảng trắng
  /// Unicode đặc biệt như non-breaking space \u00A0, zero-width space \u200B, zero-width joiner \u200C/\u200D, BOM \uFEFF).
  static bool isBlank(String? value) {
    if (value == null) return true;
    return value.replaceAll(RegExp(r'[\s\u00A0\u200B-\u200D\uFEFF]'), '').isEmpty;
  }

  /// Loại bỏ các ký tự khoảng trắng đầu và cuối chuỗi (bao gồm cả ký tự vô hình/Unicode đặc biệt).
  static String cleanWhitespace(String? value) {
    if (value == null) return '';
    return value.replaceAll(
      RegExp(r'^[\s\u00A0\u200B-\u200D\uFEFF]+|[\s\u00A0\u200B-\u200D\uFEFF]+$'),
      '',
    );
  }

  static String? validateExplanation(String? value) {
    if (isBlank(value)) {
      return S.current.common_please_enter_explanation;
    }
    return null;
  }

  /// Như [validateEmpty] nhưng chỉ toàn khoảng trắng / ký tự vô hình cũng tính là trống.
  static String? validateNotBlank(String? value) => isBlank(value) ? "" : null;

  static String? validateEmpty(String? value, String text) {
    if (value == null || value.isEmpty) {
      // return '$text ${S.current.is_not_empty}';
      return "";
    }

    return null;
  }

  String? validateUserName(String? userNameValue) {
    if (userNameValue == null || userNameValue.isEmpty) {
      // return '${S.current.user_name} ${S.current.is_not_empty}';
      return "";
    }

    if (containDiacritics(userNameValue)) {
      // return '${S.current.user_name} ${S.current.username_not_diacritic}';
      return "";
    }
    return null;
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      // return '${S.current.email} ${S.current.is_not_empty}';
      return "";
    }

    bool e = isValidEmail(email);

    if (!isValidEmail(email)) {
      // return '${S.current.email} ${S.current.valid_email}';
      return "";
    }

    if (containDiacritics(email)) {
      // return '${S.current.email} ${S.current.username_not_diacritic}';
      return "";
    }

    return null;
  }

  String? validatePassword(String? value, String text) {
    if (value == null || value.isEmpty) {
      // return '$text ${S.current.is_not_empty}';
      return "";
    }

    bool e = isStrongPassword(value);
    logger.d("e : $e");

    if (!isStrongPassword(value)) {
      // return '$text ${S.current.valid_password}';
      return "";
    }

    if (containsNonASCII(value)) {
      // return '$text ${S.current.valid_password}';
      return "";
    }

    if (hasDot(value)) {
      // return '$text ${S.current.valid_password}';
      return "";
    }

    return null;
  }

  bool isStrongPassword(String pwd) {
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,16}$',
    );
    return re.hasMatch(pwd);
  }

  bool hasDot(String pwd) {
    return pwd.contains('.');
  }

  bool containsNonASCII(String pwd) {
    return RegExp(r'[^\x00-\x7F]').hasMatch(pwd);
  }

  bool containDiacritics(String text) {
    final vietnameseDiacritics = RegExp(
      r'[àáảãạăắằẳẵặâấầẩẫậèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵđÀÁẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬÈÉẺẼẸÊẾỀỂỄỆÌÍỈĨỊÒÓỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÙÚỦŨỤƯỨỪỬỮỰỲÝỶỸỴĐ]',
    );
    return vietnameseDiacritics.hasMatch(text);
  }

  String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return S.current.common_please_reenter_password;
    }

    if (password != confirmPassword) {
      return S.current.common_password_mismatch;
    }

    return null;
  }
}
