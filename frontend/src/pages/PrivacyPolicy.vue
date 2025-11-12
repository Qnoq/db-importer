<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 via-gray-100 to-gray-50 dark:from-gray-950 dark:via-gray-900 dark:to-black transition-colors duration-200">
    <div class="container mx-auto px-4 py-12 max-w-5xl">
      <!-- Header Section -->
      <div class="bg-white dark:bg-gray-900 rounded-2xl shadow-xl dark:shadow-2xl dark:shadow-neon-green-500/10 overflow-hidden mb-8 border border-transparent dark:border-gray-800 transition-all duration-200">
        <div class="bg-gradient-to-r from-neon-green-600 to-emerald-700 dark:from-neon-green-500 dark:to-emerald-600 px-8 py-10">
          <h1 class="text-4xl font-extrabold text-white mb-3">Privacy Policy</h1>
          <p class="text-white/90 text-lg">SQLSheetr Data Import Service</p>
          <p class="text-white/70 text-sm mt-2">Last updated: {{ lastUpdated }}</p>
        </div>

        <!-- Privacy Commitment Banner -->
        <div class="bg-neon-green-50 dark:bg-neon-green-950/20 border-l-4 border-neon-green-500 dark:border-neon-green-400 p-6 m-6">
          <div class="flex items-start">
            <i class="pi pi-shield text-neon-green-600 dark:text-neon-green-400 text-2xl mr-4 mt-1"></i>
            <div>
              <h3 class="text-lg font-bold text-neon-green-900 dark:text-neon-green-300 mb-2">🔒 Our Privacy Commitment</h3>
              <p class="text-neon-green-900 dark:text-neon-green-300 font-semibold mb-2">
                <strong>Key Privacy Principle:</strong> We do NOT access, connect to, or store data from your actual databases.
              </p>
              <p class="text-neon-green-900 dark:text-neon-green-300">
                SQLSheetr only processes files you upload temporarily to generate SQL statements. You maintain full control of your data and databases at all times.
              </p>
            </div>
          </div>
        </div>

        <div class="prose prose-green max-w-none px-8 py-6">
          <section class="mb-10">
            <h2 class="text-3xl font-bold text-gray-900 mb-4 pb-2 border-b-2 border-neon-green-600 dark:border-neon-green-500">1. Introduction</h2>
            <p class="text-gray-700 dark:text-gray-300 text-lg mb-4">
              SQLSheetr ("we", "our", or "us") is a secure web-based tool for importing data from Excel/CSV files into SQL databases. We are committed to protecting your privacy and handling your data transparently.
            </p>
            <p class="text-gray-700 dark:text-gray-300 text-lg mb-4">
              This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our Service. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the Service.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold text-gray-900 mb-4 pb-2 border-b-2 border-neon-green-600 dark:border-neon-green-500">2. Information We Collect</h2>

          <h3 class="text-xl font-semibold text-gray-800 mb-3 mt-4">2.1 Personal Information</h3>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            We may collect personal information that you voluntarily provide to us when you:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li>Register for an account (name, email address)</li>
            <li>Contact us for support</li>
            <li>Use certain features of the Service</li>
          </ul>

          <h3 class="text-xl font-semibold text-gray-800 mb-3 mt-4">2.2 Uploaded Files and Processing</h3>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            When you use our Service, we temporarily process:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li><strong>SQL Schema Files:</strong> SQL dump files (.sql) containing CREATE TABLE statements - processed temporarily to extract table structures</li>
            <li><strong>Data Files:</strong> Excel (.xlsx, .xls) or CSV files containing your data - processed in memory to generate SQL INSERT statements</li>
            <li><strong>Generated SQL:</strong> The output SQL statements are generated on-demand and provided for download</li>
          </ul>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            <strong>Important:</strong> Uploaded files are processed in server memory and are NOT permanently stored on our servers. For registered users, we only store metadata about imports (see section 2.3).
          </p>

          <h3 class="text-xl font-semibold text-gray-800 mb-3 mt-4">2.3 Import History Metadata (Registered Users Only)</h3>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            For users with accounts, we store limited metadata about your imports:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li>Table name (e.g., "customers", "products")</li>
            <li>Number of rows processed</li>
            <li>Timestamp of import</li>
            <li>Database type (MySQL/PostgreSQL)</li>
            <li>Status (success/failed)</li>
          </ul>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            We do NOT store: the actual data content, SQL schema details, column mappings, or generated SQL statements permanently.
          </p>

          <h3 class="text-xl font-semibold text-gray-800 mb-3 mt-4">2.4 Technical and Usage Information</h3>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            We automatically collect certain information when you use the Service:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li>Log data (IP address, browser type, operating system, timestamps)</li>
            <li>API requests and response times (for rate limiting and performance monitoring)</li>
            <li>Error logs and diagnostic information (to improve service reliability)</li>
            <li>Session information and authentication tokens</li>
            <li>File upload sizes and processing times</li>
          </ul>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            These logs do NOT include the content of your uploaded files or generated SQL.
          </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold text-gray-900 mb-4 pb-2 border-b-2 border-neon-green-600 dark:border-neon-green-500">3. How We Use Your Information</h2>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            We use the information we collect for the following purposes:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li><strong>Service Delivery:</strong> Process uploaded SQL schemas and data files to generate INSERT statements</li>
            <li><strong>Schema Parsing:</strong> Extract table structures from SQL dump files (MySQL/MariaDB, PostgreSQL)</li>
            <li><strong>Column Mapping:</strong> Apply Levenshtein distance algorithm for intelligent column matching</li>
            <li><strong>Data Validation:</strong> Validate data against schema constraints (NOT NULL, types, lengths, ranges)</li>
            <li><strong>Account Management:</strong> Manage user accounts and authentication (JWT tokens)</li>
            <li><strong>Import History:</strong> Store metadata to allow registered users to track past imports</li>
            <li><strong>Security:</strong> Apply rate limiting, detect abuse, and prevent malicious uploads</li>
            <li><strong>Service Improvement:</strong> Analyze usage patterns to optimize parsing algorithms and user experience</li>
            <li><strong>Support:</strong> Respond to support requests and troubleshoot issues</li>
            <li><strong>Communication:</strong> Send important service updates and security alerts</li>
          </ul>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            <strong>We do NOT:</strong> Access your actual databases, store your sensitive data permanently, or share your data with third parties for marketing purposes.
          </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold text-gray-900 mb-4 pb-2 border-b-2 border-neon-green-600 dark:border-neon-green-500">4. Data Storage and Security</h2>

          <h3 class="text-xl font-semibold text-gray-800 mb-3 mt-4">4.1 Security Measures</h3>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            We implement multiple layers of security to protect your information:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li><strong>HTTPS/TLS Encryption:</strong> All data transmission is encrypted using industry-standard SSL/TLS</li>
            <li><strong>Secure Authentication:</strong> JWT-based authentication with bcrypt password hashing</li>
            <li><strong>SQL Injection Prevention:</strong> Type-aware SQL generation with comprehensive input validation and escaping</li>
            <li><strong>Rate Limiting:</strong> Configurable per-IP rate limits to prevent abuse and DDoS attacks</li>
            <li><strong>File Validation:</strong> Strict validation of file types, sizes (max 50MB), and content</li>
            <li><strong>Memory Processing:</strong> Files processed in memory and discarded after SQL generation</li>
            <li><strong>No Database Access:</strong> Zero-trust architecture - we never connect to or access your databases</li>
            <li><strong>Structured Logging:</strong> Secure logging that excludes sensitive data content</li>
          </ul>

          <h3 class="text-xl font-semibold text-gray-800 mb-3 mt-4">4.2 Data Storage</h3>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            Our data storage practices:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li><strong>User Accounts:</strong> Stored securely in Supabase (PostgreSQL) with industry-standard encryption</li>
            <li><strong>Import History Metadata:</strong> Stored only for registered users (table names, timestamps, row counts)</li>
            <li><strong>Uploaded Files:</strong> NOT permanently stored - processed in memory and discarded</li>
            <li><strong>Generated SQL:</strong> NOT stored on our servers - downloaded directly by you</li>
          </ul>

          <h3 class="text-xl font-semibold text-gray-800 mb-3 mt-4">4.3 Third-Party Infrastructure</h3>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            We use trusted third-party services for infrastructure:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li><strong>Supabase:</strong> Secure PostgreSQL database hosting for user accounts and metadata (SOC 2 Type II compliant)</li>
            <li><strong>Hosting Provider:</strong> VPS infrastructure with Docker containerization</li>
          </ul>

          <p class="text-gray-700 dark:text-gray-300 mb-4">
            However, no method of transmission over the Internet or electronic storage is 100% secure. While we implement industry best practices to protect your information, we cannot guarantee absolute security.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">5. Data Retention</h2>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            Our data retention policies:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li><strong>Uploaded Files:</strong> Deleted immediately after processing (not stored on disk)</li>
            <li><strong>Generated SQL:</strong> Not stored - provided as immediate download only</li>
            <li><strong>User Accounts:</strong> Retained for the lifetime of your account</li>
            <li><strong>Import History Metadata:</strong> Retained until you delete your account or request deletion</li>
            <li><strong>System Logs:</strong> Retained for 90 days for security and troubleshooting purposes</li>
            <li><strong>Session Data:</strong> JWT tokens expire after 15 minutes (access) / 7 days (refresh)</li>
          </ul>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            <strong>Account Deletion:</strong> You may request deletion of your account and all associated data at any time. Upon deletion, all your personal data and import history will be permanently removed from our systems within 30 days.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">6. Sharing of Information</h2>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            <strong>We do NOT sell, trade, or rent your personal information or uploaded data to third parties.</strong>
          </p>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            We may share limited information only in the following circumstances:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li><strong>Infrastructure Providers:</strong> Supabase (database hosting) and VPS hosting provider - these services are bound by strict confidentiality agreements</li>
            <li><strong>Legal Requirements:</strong> When required by law, subpoena, or to respond to legal process</li>
            <li><strong>Protection of Rights:</strong> To protect our rights, security, or property, and that of our users (e.g., preventing fraud or abuse)</li>
            <li><strong>Business Transfers:</strong> In the event of a merger, acquisition, or sale of assets (users will be notified)</li>
          </ul>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            <strong>Important:</strong> The actual content of your uploaded files (SQL schemas, data files) is never shared with third parties. Only metadata (if you're a registered user) is stored in our infrastructure.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">7. Your Data Rights</h2>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            Depending on your location, you may have the following rights regarding your personal data:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li><strong>Access:</strong> Request access to your personal data</li>
            <li><strong>Correction:</strong> Request correction of inaccurate or incomplete data</li>
            <li><strong>Deletion:</strong> Request deletion of your personal data</li>
            <li><strong>Portability:</strong> Request a copy of your data in a structured format</li>
            <li><strong>Objection:</strong> Object to processing of your personal data</li>
            <li><strong>Restriction:</strong> Request restriction of processing</li>
          </ul>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            To exercise these rights, please contact us using the information provided below.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">8. Cookies and Tracking Technologies</h2>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            We use cookies and similar tracking technologies to:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li>Maintain your session and authentication state</li>
            <li>Remember your preferences</li>
            <li>Analyze usage patterns and improve the Service</li>
          </ul>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            You can control cookies through your browser settings, but disabling cookies may affect the functionality of the Service.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">9. Third-Party Services</h2>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            The Service may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to review their privacy policies.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">10. Children's Privacy</h2>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            Our Service is not intended for use by children under the age of 13. We do not knowingly collect personal information from children under 13. If you become aware that a child has provided us with personal information, please contact us.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">11. International Data Transfers</h2>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            Your information may be transferred to and processed in countries other than your country of residence. These countries may have different data protection laws. By using the Service, you consent to such transfers.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">12. Changes to This Privacy Policy</h2>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date. You are advised to review this Privacy Policy periodically for any changes.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">13. GDPR Compliance (EU Users)</h2>
          <p class="text-gray-700 dark:text-gray-300 mb-4">
            If you are located in the European Economic Area (EEA), we process your data based on the following legal grounds:
          </p>
          <ul class="list-disc list-inside text-gray-700 dark:text-gray-300 mb-4 ml-4">
            <li><strong>Contract:</strong> Processing necessary to provide the Service</li>
            <li><strong>Consent:</strong> Where you have given explicit consent</li>
            <li><strong>Legitimate Interests:</strong> For improving and securing the Service</li>
            <li><strong>Legal Obligation:</strong> To comply with applicable laws</li>
          </ul>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold text-gray-900 mb-4 pb-2 border-b-2 border-neon-green-600 dark:border-neon-green-500">14. Contact Us</h2>
            <p class="text-gray-700 dark:text-gray-300 text-lg mb-4">
              If you have any questions about this Privacy Policy or our privacy practices, please contact us.
            </p>
          </section>
        </div>

        <!-- Footer Navigation -->
        <div class="bg-gradient-to-r from-gray-50 to-neon-green-50 dark:from-gray-900 dark:to-gray-800 px-8 py-6 border-t border-gray-200">
          <router-link to="/" class="inline-flex items-center text-neon-green-600 dark:text-neon-green-400 hover:text-neon-green-900 dark:text-neon-green-300 font-semibold transition-colors">
            <i class="pi pi-arrow-left mr-2"></i>
            Back to Home
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const lastUpdated = new Date().toLocaleDateString('en-US', {
  year: 'numeric',
  month: 'long',
  day: 'numeric'
})
</script>

<style scoped>
.prose h2 {
  margin-top: 2rem;
  margin-bottom: 1rem;
}

.prose h3 {
  margin-top: 1.5rem;
  margin-bottom: 0.75rem;
}

.prose ul {
  margin-top: 0.5rem;
  margin-bottom: 0.5rem;
}

.prose p {
  margin-bottom: 1rem;
}
</style>
