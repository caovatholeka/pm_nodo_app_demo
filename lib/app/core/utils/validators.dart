import '../logger/logger.dart';

class Validator {
  static bool isValidEmail(String email) =>
      RegExp(
          r"^(([^<>()[\]\\.,;:\s@\']+(\.[^<>()[\]\\.,;:\s@\']+)*)|(\'.+\'))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$")
          .hasMatch(email);

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
      return "Vui lòng nhập mật khẩu";
    }

    bool e = isStrongPassword(value);
    logger.d("e : $e");

    if (!isStrongPassword(value)) {
      // return '$text ${S.current.valid_password}';
      return "Mật khẩu mới của bạn phải có tối thiểu 8 ký tự, bao gồm CHỮ IN HOA, chữ thường, ký tự đặc biệt và số.";
    }

    if (containsNonASCII(value)) {
      // return '$text ${S.current.valid_password}';
      return "Mật khẩu mới của bạn không được viết Tiếng Việt có dấu.";
    }

    if(hasDot(value)) {
      // return '$text ${S.current.valid_password}';
      return "Dấu chấm (.) không được phép sử dụng trong mật khẩu.";
    }

    return null;
  }

  bool isStrongPassword(String pwd) {
    final re = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\w\s]).{8,16}$');
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
        r'[àáảãạăắằẳẵặâấầẩẫậèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵđÀÁẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬÈÉẺẼẸÊẾỀỂỄỆÌÍỈĨỊÒÓỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÙÚỦŨỤƯỨỪỬỮỰỲÝỶỸỴĐ]'
    );
    return vietnameseDiacritics.hasMatch(text);
  }


  String? validateConfirmPassword(String? password, String? confirmPassword) {
    if(confirmPassword == null || confirmPassword.isEmpty) {
      return "Vui lòng nhập lại mật khẩu";
    }
    
    if(password != confirmPassword){
      return "Mật khẩu không khớp";
    }

    return null;

  }
}