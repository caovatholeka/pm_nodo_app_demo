class AppConstant {
  AppConstant._privateConstructor() {}

  static final AppConstant instance = AppConstant._privateConstructor();

  static const String emptyData = 'Không có dữ liệu';
  static const String errorData = 'Đã xảy ra lỗi';

  /// Notification constants
  static const String ANDROID_CHANNEL_ID = 'myllv_channel_id';
  static const String ANDROID_STRINGEE_CHANNEL_ID = 'MyLlv stringee channels';
  static const String ANDROID_STRINGEE_CHANNEL_TITLE = 'MyLlv Stringee Channel';
  static const String ANDROID_STRINGEE_CHANNEL_DESCRIPTION = 'MyLlv Stringee Channel Description';
  static const String ANDROID_STRINGEE_GROUP_KEY = 'stringee';
  static const String SHOW_PRIVACY = "prosale_show_privacy";

  static List<String> listExtensionImage = [
    'jpg',
    'JPG',
    'PNG',
    'png',
    'jpeg',
    'JPEG'
  ];
}