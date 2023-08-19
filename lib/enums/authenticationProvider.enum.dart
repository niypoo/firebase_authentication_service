enum AuthenticationProvider {
  Apple,
  Google,
  Facebook,
  Twitter,
  Linkedin,
  Github,
  Anonymously,
}

String authenticationProviderToString(AuthenticationProvider type) {
  switch (type) {
    case AuthenticationProvider.Apple:
      return 'Apple';

    case AuthenticationProvider.Google:
      return 'Google';

    case AuthenticationProvider.Facebook:
      return 'Facebook';

    case AuthenticationProvider.Linkedin:
      return 'Linkedin';

    case AuthenticationProvider.Github:
      return 'Github';

    case AuthenticationProvider.Twitter:
      return 'Twitter';

    case AuthenticationProvider.Anonymously:
      return 'Anonymously';

    default:
      return 'Google';
  }
}
