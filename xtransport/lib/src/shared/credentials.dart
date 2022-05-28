import 'dart:io';

typedef BadCertificateHandler = bool Function(
    X509Certificate certificate, String host);

/// Options controlling TLS Ca security settings on a [ClientChannel].
class XtransportCredentials {
  final bool isSecure;
  final String? authority;
  final List<int>? _caCertificateBytes;
  final String? _caCertificatePassword;

  final List<int>? _clientCertificateBytes;
  final String? _clientCertificatePassword;

  final List<int>? _clientPrivateKeyBytes;
  final String? _clientPrivateKeyPassword;

  final BadCertificateHandler? onBadCertificate;

  const XtransportCredentials._(
    this.isSecure,
    this._caCertificateBytes,
    this._caCertificatePassword,
    this.authority,
    this.onBadCertificate,
    this._clientCertificateBytes,
    this._clientCertificatePassword,
    this._clientPrivateKeyBytes,
    this._clientPrivateKeyPassword,
  );

  /// Disable TLS. RPCs are sent in clear text.
  const XtransportCredentials.insecure({String? authority})
      : this._(false, null, null, authority, null, null, null, null, null);

  XtransportCredentials clone({bool? newIsSecure, String? newAuthority}) {
    return XtransportCredentials._(
      newIsSecure ?? isSecure,
      _caCertificateBytes,
      _caCertificatePassword,
      newAuthority ?? authority,
      onBadCertificate,
      _clientCertificateBytes,
      _clientCertificatePassword,
      _clientPrivateKeyBytes,
      _clientPrivateKeyPassword,
    );
  }

  /// Enable TLS and optionally specify the [certificates] to trust. If
  /// [certificates] is not provided, the default trust store is used.
  const XtransportCredentials.secure({
    List<int>? certificates,
    String? password,
    String? authority,
    BadCertificateHandler? onBadCertificate,
    List<int>? clientCertificateBytes,
    String? clientCertificatePassword,
    List<int>? clientPrivateKeyBytes,
    String? clientPrivateKeyPassword,
  }) : this._(
          true,
          certificates,
          password,
          authority,
          onBadCertificate,
          clientCertificateBytes,
          clientCertificatePassword,
          clientPrivateKeyBytes,
          clientPrivateKeyPassword,
        );

  SecurityContext? get securityContext {
    if (!isSecure) return null;
    if (_caCertificateBytes != null) {
      final context = SecurityContext(withTrustedRoots: true)
        ..setTrustedCertificatesBytes(_caCertificateBytes!,
            password: _caCertificatePassword);
      if (_clientCertificateBytes != null) {
        context.useCertificateChainBytes(
          _clientCertificateBytes!,
          password: _clientCertificatePassword,
        );
      }
      if (_clientPrivateKeyBytes != null) {
        context.usePrivateKeyBytes(
          _clientPrivateKeyBytes!,
          password: _clientPrivateKeyPassword,
        );
      }
      return context;
    }
    final context = SecurityContext(withTrustedRoots: _caCertificateBytes != null);
    return context;
  }
}
