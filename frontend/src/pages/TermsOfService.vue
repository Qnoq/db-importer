<template>
  <div class="container mx-auto px-4 py-8 max-w-4xl">
    <div class="bg-white rounded-lg shadow-lg p-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-6">Terms of Service</h1>

      <div class="prose prose-blue max-w-none">
        <p class="text-gray-600 mb-6">
          Last updated: {{ lastUpdated }}
        </p>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">1. Acceptance of Terms</h2>
          <p class="text-gray-700 mb-4">
            By accessing and using SQL Importer ("the Service"), you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">2. Description of Service</h2>
          <p class="text-gray-700 mb-4">
            SQL Data Importer is a secure web-based tool that helps you safely import data from Excel/CSV files into SQL databases. The Service provides the following features:
          </p>
          <ul class="list-disc list-inside text-gray-700 mb-4 ml-4">
            <li><strong>SQL Schema Parsing:</strong> Upload SQL dump files (.sql) containing CREATE TABLE statements for MySQL/MariaDB or PostgreSQL</li>
            <li><strong>Data File Upload:</strong> Upload Excel (.xlsx, .xls) or CSV files containing your data</li>
            <li><strong>Intelligent Column Mapping:</strong> Automatic column matching using Levenshtein distance algorithm with manual override options</li>
            <li><strong>Data Validation:</strong> Server-side validation against schema constraints (NOT NULL, data types, length, ranges)</li>
            <li><strong>SQL Generation:</strong> Generate type-safe, injection-proof INSERT statements ready for execution</li>
            <li><strong>Import History:</strong> Track your past imports and download generated SQL files (for registered users)</li>
          </ul>
          <p class="text-gray-700 mb-4">
            <strong>Important:</strong> The Service does NOT connect to your database directly. You download the generated SQL and execute it yourself in your own environment, ensuring full control and security.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">3. User Accounts</h2>
          <p class="text-gray-700 mb-4">
            To access certain features of the Service, you must register for an account. You agree to:
          </p>
          <ul class="list-disc list-inside text-gray-700 mb-4 ml-4">
            <li>Provide accurate, current, and complete information during registration</li>
            <li>Maintain the security of your password and account</li>
            <li>Notify us immediately of any unauthorized use of your account</li>
            <li>Be responsible for all activities that occur under your account</li>
          </ul>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">4. User Data and Privacy</h2>
          <p class="text-gray-700 mb-4">
            You retain all rights to your data. The Service processes your uploaded files (SQL schemas and data files) temporarily to generate SQL statements. Key privacy principles:
          </p>
          <ul class="list-disc list-inside text-gray-700 mb-4 ml-4">
            <li><strong>No Database Access:</strong> We never access or connect to your actual databases</li>
            <li><strong>Temporary Processing:</strong> Uploaded files are processed in memory and not permanently stored on our servers (except import history metadata for registered users)</li>
            <li><strong>You Control Execution:</strong> Generated SQL is downloaded by you and executed in your own environment</li>
            <li><strong>Account Data:</strong> For registered users, we store account information (email, name) and import history metadata (table names, row counts, timestamps) - not the actual data content</li>
          </ul>
          <p class="text-gray-700 mb-4">
            For complete details on data handling, please review our <router-link to="/privacy-policy" class="text-blue-600 hover:text-blue-800 underline">Privacy Policy</router-link>.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">5. Acceptable Use</h2>
          <p class="text-gray-700 mb-4">
            You agree not to:
          </p>
          <ul class="list-disc list-inside text-gray-700 mb-4 ml-4">
            <li>Use the Service for any illegal purpose or in violation of any laws</li>
            <li>Upload malicious code, viruses, or any other harmful software in SQL or data files</li>
            <li>Attempt to gain unauthorized access to the Service or related systems</li>
            <li>Interfere with or disrupt the Service or servers, including circumventing rate limits</li>
            <li>Upload excessively large files to overload the system (maximum file size limits apply)</li>
            <li>Attempt to exploit the SQL generation feature to create malicious SQL code</li>
            <li>Use the Service to process data you do not have legal rights to access or modify</li>
            <li>Impersonate any person or entity or misrepresent your affiliation</li>
            <li>Reverse engineer or attempt to extract the source code of the Service</li>
          </ul>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">6. Intellectual Property</h2>
          <p class="text-gray-700 mb-4">
            The Service and its original content, features, and functionality are owned by SQL Importer and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">7. Limitation of Liability</h2>
          <p class="text-gray-700 mb-4">
            In no event shall SQL Importer, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from:
          </p>
          <ul class="list-disc list-inside text-gray-700 mb-4 ml-4">
            <li>Your access to or use of or inability to access or use the Service</li>
            <li>Any conduct or content of any third party on the Service</li>
            <li>Any content obtained from the Service</li>
            <li>Unauthorized access, use, or alteration of your transmissions or content</li>
          </ul>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">8. Disclaimer of Warranties</h2>
          <p class="text-gray-700 mb-4">
            The Service is provided on an "AS IS" and "AS AVAILABLE" basis. SQL Importer makes no warranties, expressed or implied, regarding the Service, including but not limited to:
          </p>
          <ul class="list-disc list-inside text-gray-700 mb-4 ml-4">
            <li>Merchantability, fitness for a particular purpose, or non-infringement</li>
            <li>That the Service will be uninterrupted, secure, or error-free</li>
            <li>That any defects will be corrected</li>
          </ul>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">9. Data Backup and User Responsibility</h2>
          <p class="text-gray-700 mb-4">
            <strong>Critical responsibilities:</strong>
          </p>
          <ul class="list-disc list-inside text-gray-700 mb-4 ml-4">
            <li><strong>Test Generated SQL:</strong> Always test generated SQL on a development/staging database before executing in production</li>
            <li><strong>Backup Your Database:</strong> Create complete backups before running any import operations</li>
            <li><strong>Review SQL Output:</strong> Carefully review the generated SQL statements before execution</li>
            <li><strong>Save Downloaded Files:</strong> Once you download generated SQL, you are responsible for storing it securely</li>
            <li><strong>Verify Data Accuracy:</strong> Ensure your source data (Excel/CSV) is accurate and complete</li>
          </ul>
          <p class="text-gray-700 mb-4">
            We are not liable for any data loss, corruption, or errors that occur in your database as a result of executing generated SQL statements. The Service generates SQL based on the inputs you provide, but you are solely responsible for validating and executing it.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">10. Termination</h2>
          <p class="text-gray-700 mb-4">
            We may terminate or suspend your account and access to the Service immediately, without prior notice or liability, for any reason, including breach of these Terms. Upon termination, your right to use the Service will immediately cease.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">11. Changes to Terms</h2>
          <p class="text-gray-700 mb-4">
            We reserve the right to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days' notice prior to any new terms taking effect. Continued use of the Service after changes constitutes acceptance of the modified Terms.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">12. Governing Law</h2>
          <p class="text-gray-700 mb-4">
            These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which SQL Importer operates, without regard to its conflict of law provisions.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">13. Contact Information</h2>
          <p class="text-gray-700 mb-4">
            If you have any questions about these Terms, please contact us.
          </p>
        </section>
      </div>

      <div class="mt-8 pt-6 border-t border-gray-200">
        <router-link to="/" class="text-blue-600 hover:text-blue-800 flex items-center">
          <i class="pi pi-arrow-left mr-2"></i>
          Back to Home
        </router-link>
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

.prose ul {
  margin-top: 0.5rem;
  margin-bottom: 0.5rem;
}

.prose p {
  margin-bottom: 1rem;
}
</style>
