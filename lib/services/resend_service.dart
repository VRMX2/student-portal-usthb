import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';

/// Service for sending emails via Resend API
class ResendService {
  static const _baseUrl = 'https://api.resend.com';

  /// Send email notification
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String html,
    String from = 'USTHB App <onboarding@resend.dev>',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/emails'),
        headers: {
          'Authorization': 'Bearer ${EnvConfig.resendApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'from': from,
          'to': [to],
          'subject': subject,
          'html': html,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Resend API error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Failed to send email: $e');
      return false;
    }
  }

  /// Send new message notification
  Future<void> sendNewMessageNotification({
    required String recipientEmail,
    required String senderName,
    required String messagePreview,
  }) async {
    final html = '''
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #005BAC; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background-color: #f4f4f4; }
          .button { background-color: #005BAC; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin-top: 10px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h2>New Message from $senderName</h2>
          </div>
          <div class="content">
            <p><strong>$senderName</strong> sent you a message:</p>
            <p style="background: white; padding: 15px; border-left: 4px solid #005BAC;">
              $messagePreview
            </p>
            <a href="usthb://chat" class="button">Open in App</a>
          </div>
        </div>
      </body>
      </html>
    ''';

    await sendEmail(
      to: recipientEmail,
      subject: 'New message from $senderName',
      html: html,
    );
  }

  /// Send follow request notification
  Future<void> sendFollowNotification({
    required String recipientEmail,
    required String followerName,
  }) async {
    final html = '''
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #005BAC; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background-color: #f4f4f4; }
          .button { background-color: #005BAC; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin-top: 10px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h2>New Follower</h2>
          </div>
          <div class="content">
            <p><strong>$followerName</strong> started following you on USTHB Student App!</p>
            <a href="usthb://profile" class="button">View Profile</a>
          </div>
        </div>
      </body>
      </html>
    ''';

    await sendEmail(
      to: recipientEmail,
      subject: '$followerName started following you',
      html: html,
    );
  }

  /// Send welcome email to new users
  Future<void> sendWelcomeEmail({
    required String recipientEmail,
    required String userName,
  }) async {
    final html = '''
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #005BAC; color: white; padding: 20px; text-align: center; }
          .content { padding: 20px; background-color: #f4f4f4; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h2>Welcome to USTHB Student App!</h2>
          </div>
          <div class="content">
            <p>Hi $userName,</p>
            <p>Welcome to the USTHB Student community! You can now:</p>
            <ul>
              <li>Chat with fellow students</li>
              <li>Share images and voice messages</li>
              <li>Follow friends and classmates</li>
              <li>Access your academic resources</li>
            </ul>
            <p>Get started by completing your profile and connecting with other students!</p>
          </div>
        </div>
      </body>
      </html>
    ''';

    await sendEmail(
      to: recipientEmail,
      subject: 'Welcome to USTHB Student App',
      html: html,
    );
  }
}
