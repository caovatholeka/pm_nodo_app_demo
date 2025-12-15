enum Environment {
  dev,
  demo,
  test,
  prod,
}

extension EnvironmentExt on Environment {
  static Environment fromName(String name) {
    if (name.compareTo("DEV") == 0) {
      return Environment.dev;
    } else if (name.compareTo("DEMO") == 0) {
      return Environment.demo;
    } else if (name.compareTo("TEST") == 0) {
      return Environment.test;
    } else if (name.compareTo("PROD") == 0) {
      return Environment.prod;
    }
    return Environment.dev;
  }

  String get envName {
    switch (this) {
      case Environment.dev:
        return 'DEV';
      case Environment.demo:
        return 'DEMO';
      case Environment.test:
        return 'TEST';
      case Environment.prod:
        return 'PROD';
    }
  }

  String get baseUrl {
    return 'https://pm.nodo.vn/';
    // switch (this) {
    //   case Environment.dev:
    //     return 'https://api-nodo-pm-dev.com/';
    //   case Environment.staging:
    //     return 'https://api-nodo-pm-staging.vn/';
    //   case Environment.prod:
    //     return 'https://api.nodo-pm.vn/';
    // }
  }

  String get logId {
    switch (this) {
      case Environment.dev:
        return 'dev-mobile';
      case Environment.demo:
        return 'demo-mobile';
      case Environment.test:
        return 'testing-mobile';
      case Environment.prod:
        return 'prod-mobile';
    }
  }
}