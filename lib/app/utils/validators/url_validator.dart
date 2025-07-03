// lib/app/utils/validators/url_validator.dart
class UrlValidator {
  // Comprehensive URL validation regex
  static final RegExp _urlPattern = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    caseSensitive: false,
  );

  // Stricter URL pattern for academic/educational links
  static final RegExp _strictUrlPattern = RegExp(
    r'^https?:\/\/(www\.)?[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*\/[^\s]*$',
    caseSensitive: false,
  );

  /// Check if a string is a valid URL
  static bool isValidUrl(String url) {
    if (url.trim().isEmpty) return false;
    return _urlPattern.hasMatch(url.trim());
  }

  /// Check if a string is a valid URL with stricter validation
  // static bool isValidUrlStrict(String url) {
  //   if (url.trim().isEmpty) return false;
  //   return _strictUrlPattern.hasMatch(url.trim());
  // }

  /// Validate URL and return error message if invalid
  // static String? validateUrl(String? url) {
  //   if (url == null || url.trim().isEmpty) {
  //     return 'URL bo\'sh bo\'lishi mumkin emas';
  //   }
  //
  //   final trimmedUrl = url.trim();
  //
  //   if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
  //     return 'URL http:// yoki https:// bilan boshlanishi kerak';
  //   }
  //
  //   if (!isValidUrl(trimmedUrl)) {
  //     return 'Iltimos to\'g\'ri URL kiriting';
  //   }
  //
  //   return null; // Valid URL
  // }

  /// Sanitize URL by adding protocol if missing
  // static String sanitizeUrl(String url) {
  //   final trimmedUrl = url.trim();
  //
  //   if (trimmedUrl.isEmpty) return '';
  //
  //   // If it doesn't start with protocol, add https://
  //   if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
  //     return 'https://$trimmedUrl';
  //   }
  //
  //   return trimmedUrl;
  // }

  /// Check if URL is from a trusted educational domain
  static bool isEducationalDomain(String url) {
    final educationalDomains = [
      'edu',
      'ac.uk',
      'ac.jp',
      'edu.au',
      'edu.br',
      'edu.cn',
      'edu.in',
      'khan',
      'coursera',
      'edx',
      'udemy',
      'youtube.com/watch', // YouTube videos
      'youtu.be', // YouTube short links
      'drive.google.com', // Google Drive
      'docs.google.com', // Google Docs
      'github.com', // GitHub repositories
      'wikipedia.org', // Wikipedia
    ];

    return educationalDomains.any((domain) => url.toLowerCase().contains(domain));
  }

  /// Get URL domain for display purposes
  static String getUrlDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  /// Check if URL is accessible (basic format check)
  static bool isAccessibleUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  /// Validate multiple URLs and return list of invalid ones
  static List<String> validateMultipleUrls(List<String> urls) {
    final invalidUrls = <String>[];

    for (final url in urls) {
      if (!isValidUrl(url)) {
        invalidUrls.add(url);
      }
    }

    return invalidUrls;
  }

  /// Get URL validation status with detailed info
  static UrlValidationResult getValidationResult(String url) {
    if (url.trim().isEmpty) {
      return UrlValidationResult(
        isValid: false,
        error: 'URL bo\'sh bo\'lishi mumkin emas',
        suggestion: 'http:// yoki https:// bilan boshlanadigan to\'g\'ri URL kiriting',
      );
    }

    final trimmedUrl = url.trim();

    if (!trimmedUrl.startsWith('http://') && !trimmedUrl.startsWith('https://')) {
      return UrlValidationResult(
        isValid: false,
        error: 'URL http:// yoki https:// bilan boshlanishi kerak',
        suggestion: 'Masalan: https://$trimmedUrl',
      );
    }

    if (!isValidUrl(trimmedUrl)) {
      return UrlValidationResult(
        isValid: false,
        error: 'Noto\'g\'ri URL formati',
        suggestion: 'Xatolarni tekshiring va to\'g\'ri URL formatini kiriting',
      );
    }

    return UrlValidationResult(
      isValid: true,
      domain: getUrlDomain(trimmedUrl),
      isEducational: isEducationalDomain(trimmedUrl),
    );
  }
}

/// Result class for detailed URL validation
class UrlValidationResult {
  final bool isValid;
  final String? error;
  final String? suggestion;
  final String? domain;
  final bool isEducational;

  UrlValidationResult({
    required this.isValid,
    this.error,
    this.suggestion,
    this.domain,
    this.isEducational = false,
  });

  @override
  String toString() {
    return 'UrlValidationResult(isValid: $isValid, error: $error, domain: $domain)';
  }
}