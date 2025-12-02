import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_dimensions.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Terms of Service'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: October 26, 2023',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppDimensions.spacing24),
            
            _buildSection(
              theme,
              title: '1. Introduction',
              content: 'Welcome to DocChat. These Terms of Service ("Terms") govern your use of our PDF summarizer and document chat services (the "Service"). By accessing or using the Service, you agree to be bound by these Terms.',
            ),
            
            _buildSection(
              theme,
              title: '2. Account Registration & Use',
              content: 'You must be at least 13 years old to use the Service. When you create an account, you agree to provide accurate and complete information. You are responsible for safeguarding your password and for all activities that occur under your account. You must immediately notify DocChat of any unauthorized use of your account.',
            ),
            
            _buildSection(
              theme,
              title: '3. User Content & Data Privacy',
              content: 'You retain ownership of any documents you upload to the Service ("User Content"). By uploading User Content, you grant DocChat a worldwide, non-exclusive license to use, process, and display it solely for the purpose of providing the Service. DocChat is committed to protecting your privacy. Please review our Privacy Policy for details on how we collect and use your data.',
            ),
            
            _buildSection(
              theme,
              title: '4. Prohibited Conduct',
              content: 'You agree not to: (i) copy, distribute, or disclose any part of the Service in any medium; (ii) use any automated system to access the Service; (iii) transmit spam or other unsolicited email; (iv) attempt to interfere with the system\'s integrity or security.',
            ),
            
            _buildSection(
              theme,
              title: '5. Disclaimers & Limitation of Liability',
              content: 'The Service is provided "as is" without warranty of any kind. DocChat, its affiliates, agents, directors, or employees shall not be liable for any indirect, punitive, incidental, special, consequential, or exemplary damages, including damages for loss of profits, goodwill, or other intangible losses.',
            ),
            
            _buildSection(
              theme,
              title: '6. Termination',
              content: 'DocChat may terminate or suspend your access to the Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms. Upon termination, your right to use the Service will immediately cease.',
            ),
            
            _buildSection(
              theme,
              title: '7. Governing Law',
              content: 'These Terms shall be governed and construed in accordance with the laws of the jurisdiction in which DocChat\'s company is established, without regard to its conflict of law provisions.',
            ),
            
            const SizedBox(height: AppDimensions.spacing32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, {required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            content,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}


