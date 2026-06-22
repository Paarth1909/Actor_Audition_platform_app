import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────────────────────
// EmailJS Configuration
//
// HOW TO SET UP (free — 200 emails/month):
//  1. Sign up at https://www.emailjs.com/
//  2. Add an Email Service (Gmail, Outlook, etc.) → copy the Service ID
//  3. Create an Email Template with these variables:
//       {{to_email}}        — recipient email
//       {{to_name}}         — recipient name (first part of email)
//       {{audition_title}}  — audition name
//       {{status}}          — Selected / Shortlisted / Rejected
//       {{status_message}}  — personalised message body
//       {{from_name}}       — sender name (e.g. "CineAudition Platform")
//  4. Copy Template ID from the template dashboard
//  5. Copy your Public Key from Account → API Keys
//  6. Replace the three constants below with your real values.
// ─────────────────────────────────────────────────────────────────────────────

class EmailService {
  // ── ⚠️  Replace these with YOUR EmailJS credentials ──────────────────────
  static const String _serviceId = 'service_ejdmvsy';   // e.g. 'service_abc123'
  static const String _templateId = 'template_jlxuana'; // e.g. 'template_xyz789'
  static const String _publicKey = 'deA8nWM7tQA3UAqnO';   // e.g. 'AbCdEfGhIjKlMnOp'
  // ─────────────────────────────────────────────────────────────────────────

  static const String _emailJsUrl =
      'https://api.emailjs.com/api/v1.0/email/send';

  /// Sends an audition status notification email to the applicant.
  ///
  /// [toEmail]       – applicant's email address
  /// [auditionTitle] – name of the audition
  /// [newStatus]     – one of: 'pending', 'shortlisted', 'accepted', 'rejected'
  ///
  /// Returns `true` on success, `false` on failure (logs error details).
  static Future<bool> sendStatusNotification({
    required String toEmail,
    required String toName,
    required String auditionTitle,
    required String newStatus,
  }) async {
    // Skip if credentials are not configured yet
    // if (_serviceId == 'service_ejdmvsy' ||
    //     _templateId == 'template_jlxuana' ||
    //     _publicKey == 'deA8nWM7tQA3UAqnO') {
    //   debugPrint(
    //     '[EmailService] ⚠️  EmailJS credentials not configured. '
    //     'Open lib/services/email_service.dart and replace the placeholder values.',
    //   );
    //   return false;
    // }

    // final toName = toEmail.split('@').first;

    final statusInfo = _buildStatusInfo(newStatus, auditionTitle);
    print('sending mail');
    try {
      final response = await http
          .post(
            Uri.parse(_emailJsUrl),
            headers: {
              'Content-Type': 'application/json',
              'origin': 'http://localhost',
            },
            body: jsonEncode({
              'service_id': _serviceId,
              'template_id': _templateId,
              'user_id': _publicKey,
              'template_params': {
                'to_email': toEmail,
                'to_name': toName,
                'audition_title': auditionTitle,
                'status': statusInfo['label'],
                'status_message': statusInfo['message'],
                'from_name': 'CineAudition Platform',
              },
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        debugPrint('[EmailService] ✅ Email sent to $toEmail (status: $newStatus)');
        return true;
      } else {
        debugPrint(
          '[EmailService] ❌ EmailJS error ${response.statusCode}: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('[EmailService] ❌ Exception: $e');
      return false;
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Returns a human-readable label and personalised message body for a status.
  static Map<String, String> _buildStatusInfo(
    String status,
    String auditionTitle,
  ) {
    switch (status) {
      case 'shortlisted':
        return {
          'label': '⭐ Shortlisted',
          'message':
              'Great news! You have been SHORTLISTED for the audition '
              '"$auditionTitle". Our team was impressed with your application. '
              'Please keep an eye on your email for further instructions '
              'about the next round.',
        };

      case 'accepted':
        return {
          'label': '✅ Selected / Accepted',
          'message':
              'Congratulations! 🎉 You have been SELECTED for the audition '
              '"$auditionTitle". This is your time to shine! '
              'The casting director will contact you soon with '
              'schedule details and next steps.',
        };

      case 'rejected':
        return {
          'label': '❌ Not Selected',
          'message':
              'Thank you for applying to "$auditionTitle". '
              'After careful review, we regret to inform you that you have '
              'not been selected for this role at this time. '
              'We encourage you to keep auditioning — the right role is '
              'just around the corner! Best of luck. 🎭',
        };

      case 'pending':
      default:
        return {
          'label': '⏳ Under Review',
          'message':
              'Your application for "$auditionTitle" is currently '
              'under review. We will notify you as soon as a decision '
              'has been made. Thank you for your patience!',
        };
    }
  }
}
