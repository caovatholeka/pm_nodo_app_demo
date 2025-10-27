import 'package:fluro/fluro.dart';

import 'router_handler.dart';

class Routes {
  static String root = "/";

  ///Home
  static String login = "/login";
  static String home = "/home";

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = notHandler;
    router.define(root, handler:splashHandler);


    // ///Auth
    router.define(login, handler: loginHandler);
    // router.define(forgotPassword, handler: forgotPassHandler);

    /// Home
    router.define(home, handler: bottomNavHandler);
  }
}