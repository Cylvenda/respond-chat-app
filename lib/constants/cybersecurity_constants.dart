class CybersecurityConstants {
  // Phishing Prevention Tips
  static const List<String> phishingTips = [
    'Never click links in unsolicited emails',
    'Verify sender email address carefully',
    'Look for secure HTTPS connections',
    'Hover over links to see actual URL',
    'Be suspicious of urgent requests',
  ];

  // Password Security Tips
  static const List<String> passwordTips = [
    'Use at least 12 characters',
    'Mix uppercase, lowercase, numbers, and symbols',
    'Never reuse passwords across sites',
    'Use a password manager',
    'Enable two-factor authentication',
  ];

  // Malware Prevention Tips
  static const List<String> malwareTips = [
    'Keep software updated regularly',
    'Use reputable antivirus software',
    'Don\'t download from untrusted sources',
    'Scan attachments before opening',
    'Disable unnecessary browser extensions',
  ];

  // Data Privacy Tips
  static const List<String> privacyTips = [
    'Review privacy settings on social media',
    'Limit personal information sharing',
    'Use VPN on public networks',
    'Encrypt sensitive documents',
    'Read privacy policies carefully',
  ];

  // General Security Best Practices
  static const List<String> bestPractices = [
    'Use unique passwords for each account',
    'Enable two-factor authentication everywhere',
    'Keep your operating system updated',
    'Backup your data regularly',
    'Be skeptical of unsolicited contacts',
    'Use strong, unique passphrases',
    'Monitor your accounts for suspicious activity',
    'Update your browser and plugins',
    'Don\'t share personal information online',
    'Use security keys for critical accounts',
  ];

  // Common threats
  static const Map<String, String> commonThreats = {
    'Phishing': 'Deceptive emails or websites designed to steal credentials',
    'Malware': 'Malicious software that can damage or control your computer',
    'Ransomware':
        'Malware that encrypts your files and demands payment for decryption',
    'Social Engineering':
        'Manipulation tactics to trick people into revealing secrets',
    'Man-in-the-Middle': 'Intercepting communications between two parties',
    'Brute Force': 'Attempting passwords until one works',
    'SQL Injection': 'Inserting malicious code into website input fields',
    'Cross-Site Scripting (XSS)':
        'Injecting scripts into web pages viewed by others',
  };
}
