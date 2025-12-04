enum Environment {
  dev,
  demo,
  prod,
}

extension EnvironmentExt on Environment {
  String get envName {
    switch (this) {
      case Environment.dev:
        return 'DEV';
      case Environment.demo:
        return 'DEMO';
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
      case Environment.prod:
        return 'prod-mobile';
    }
  }
}