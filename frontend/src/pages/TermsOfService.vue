<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-950">
    <div class="max-w-7xl mx-auto px-4 py-12">
      <div class="bg-white dark:bg-gray-900 rounded-2xl shadow-2xl overflow-hidden mb-8 border border-gray-200 dark:border-gray-800">
        <!-- Header -->
        <div class="bg-gradient-to-r from-green-600 to-emerald-700 px-8 py-10">
          <h1 class="text-4xl font-extrabold text-white mb-3">Terms of Service</h1>
          <p class="text-white/90 text-lg">SQLSheetr Data Import Service</p>
          <p class="text-white/70 text-sm mt-2">Last updated: {{ lastUpdated }}</p>
        </div>

        <!-- Critical Warning Banner -->
        <div class="p-6">
          <UAlert
            color="red"
            variant="solid"
            title="CRITICAL: READ BEFORE USE"
            :close-button="null"
          >
            <template #description>
              <p class="font-semibold mb-2">
                By using this service, you acknowledge and accept full responsibility for:
              </p>
              <ul class="list-disc list-inside space-y-1 ml-4">
                <li><strong>ALWAYS creating complete database backups before executing any generated SQL</strong></li>
                <li>Testing all generated SQL on development/staging environments first</li>
                <li>Reviewing and validating all SQL statements before execution</li>
                <li>Any and all consequences of executing generated SQL in your databases</li>
              </ul>
              <p class="font-bold mt-3">
                WE ARE NOT LIABLE FOR ANY DATA LOSS, CORRUPTION, OR DAMAGE TO YOUR DATABASES.
              </p>
            </template>
          </UAlert>
        </div>

        <div class="px-8 py-6 max-w-none">
          <!-- Section 1 -->
          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">1. Acceptance of Terms</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              By accessing and using SQLSheetr ("the Service"), you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to abide by the terms below, please do not use this service.
            </p>
          </section>

          <!-- Section 2 -->
          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">2. Description of Service</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              SQLSheetr is a secure web-based tool that helps you import data from Excel/CSV files into SQL databases. The Service provides the following features:
            </p>
            <ul class="list-disc list-inside text-gray-600 dark:text-gray-400 mb-4 ml-4 space-y-1">
              <li><strong>SQL Schema Parsing:</strong> Upload SQL dump files (.sql) containing CREATE TABLE statements for MySQL/MariaDB or PostgreSQL</li>
              <li><strong>Data File Upload:</strong> Upload Excel (.xlsx, .xls) or CSV files containing your data</li>
              <li><strong>Intelligent Column Mapping:</strong> Automatic column matching using Levenshtein distance algorithm with manual override options</li>
              <li><strong>Data Validation:</strong> Server-side validation against schema constraints (NOT NULL, data types, length, ranges)</li>
              <li><strong>SQL Generation:</strong> Generate type-safe, injection-proof INSERT statements ready for execution</li>
              <li><strong>Import History:</strong> Track your past imports and download generated SQL files (for registered users)</li>
            </ul>
            <UAlert color="blue" variant="soft" class="my-6">
              <template #description>
                <p class="flex items-center gap-2 font-semibold">
                  <strong>Important:</strong> The Service does NOT connect to your database directly. You download the generated SQL and execute it yourself in your own environment, ensuring full control and security.
                </p>
              </template>
            </UAlert>
          </section>

          <!-- Sections 3-13 condensed for brevity - following same pattern -->
          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">3. User Accounts</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              To access certain features of the Service, you must register for an account. You agree to:
            </p>
            <ul class="list-disc list-inside text-gray-600 dark:text-gray-400 mb-4 ml-4">
              <li>Provide accurate, current, and complete information during registration</li>
              <li>Maintain the security of your password and account</li>
              <li>Notify us immediately of any unauthorized use of your account</li>
              <li>Be responsible for all activities that occur under your account</li>
            </ul>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">4. User Data and Privacy</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              You retain all rights to your data. The Service processes your uploaded files (SQL schemas and data files) temporarily to generate SQL statements. Key privacy principles:
            </p>
            <ul class="list-disc list-inside text-gray-600 dark:text-gray-400 mb-4 ml-4">
              <li><strong>No Database Access:</strong> We never access or connect to your actual databases</li>
              <li><strong>Temporary Processing:</strong> Uploaded files are processed in memory and not permanently stored on our servers (except import history metadata for registered users)</li>
              <li><strong>You Control Execution:</strong> Generated SQL is downloaded by you and executed in your own environment</li>
              <li><strong>Account Data:</strong> For registered users, we store account information (email, name) and import history metadata (table names, row counts, timestamps) - not the actual data content</li>
            </ul>
            <p class="text-lg text-gray-700 dark:text-gray-300">
              For complete details on data handling, please review our <router-link to="/privacy-policy" class="text-green-600 hover:text-green-800 underline">Privacy Policy</router-link>.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">5. Acceptable Use</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">You agree not to:</p>
            <ul class="list-disc list-inside text-gray-600 dark:text-gray-400 mb-4 ml-4">
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

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">6. Intellectual Property</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              The Service and its original content, features, and functionality are owned by SQLSheetr and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-red-600 text-gray-900 dark:text-gray-100">7. Limitation of Liability</h2>
            <UAlert color="red" variant="solid" :close-button="null" class="mb-4">
              <template #description>
                <p class="font-bold text-base mb-2">PLEASE READ THIS SECTION CAREFULLY</p>
                <p class="text-base mb-2">
                  In no event shall SQLSheetr, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation:
                </p>
                <ul class="list-disc list-inside space-y-1 ml-4">
                  <li><strong>Loss of data or database corruption</strong></li>
                  <li><strong>Loss of profits, revenue, or business opportunities</strong></li>
                  <li><strong>Downtime or service interruptions</strong></li>
                  <li><strong>Errors in generated SQL statements</strong></li>
                  <li><strong>Data integrity issues resulting from executed SQL</strong></li>
                  <li>Any conduct or content of any third party on the Service</li>
                  <li>Unauthorized access, use, or alteration of your transmissions or content</li>
                </ul>
                <p class="font-bold mt-3">
                  YOU ARE SOLELY RESPONSIBLE FOR BACKING UP YOUR DATABASES BEFORE EXECUTING ANY GENERATED SQL.
                </p>
              </template>
            </UAlert>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">8. Disclaimer of Warranties</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              The Service is provided on an "AS IS" and "AS AVAILABLE" basis. SQLSheetr makes no warranties, expressed or implied, regarding:
            </p>
            <ul class="list-disc list-inside text-gray-600 dark:text-gray-400 mb-4 ml-4">
              <li><strong>Accuracy or correctness of generated SQL statements</strong></li>
              <li><strong>Suitability of generated SQL for your specific use case</strong></li>
              <li>Merchantability, fitness for a particular purpose, or non-infringement</li>
              <li>That the Service will be uninterrupted, secure, or error-free</li>
              <li>That any defects will be corrected</li>
              <li><strong>That the generated SQL will not cause data loss or corruption</strong></li>
            </ul>
          </section>

          <section class="mb-10 bg-yellow-50 dark:bg-yellow-900/20 border-2 border-yellow-400 dark:border-yellow-600 rounded-xl p-6">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-yellow-600 dark:border-yellow-500 text-yellow-900 dark:text-yellow-100 flex items-center gap-2">
              9. Data Backup and User Responsibility
            </h2>
            <div class="bg-white dark:bg-gray-900 border-2 border-red-400 dark:border-red-600 rounded-lg p-6 mb-4">
              <p class="text-gray-900 dark:text-gray-100 font-bold text-xl mb-4">MANDATORY USER RESPONSIBILITIES:</p>
              <div class="space-y-4">
                <div class="flex items-start gap-3">
                  <span class="bg-red-600 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold flex-shrink-0">1</span>
                  <div>
                    <p class="font-bold text-red-900 dark:text-red-300 mb-1">ALWAYS BACKUP YOUR DATABASE FIRST</p>
                    <p class="text-gray-600 dark:text-gray-400">Create a complete backup of your database before executing ANY generated SQL. This is NON-NEGOTIABLE.</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <span class="bg-red-600 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold flex-shrink-0">2</span>
                  <div>
                    <p class="font-bold text-red-900 dark:text-red-300 mb-1">Test on Development/Staging Environment</p>
                    <p class="text-gray-600 dark:text-gray-400">Never execute generated SQL directly in production without testing it first.</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <span class="bg-red-600 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold flex-shrink-0">3</span>
                  <div>
                    <p class="font-bold text-red-900 dark:text-red-300 mb-1">Review Every SQL Statement</p>
                    <p class="text-gray-600 dark:text-gray-400">Carefully review the generated SQL before execution. Understand what it will do to your database.</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <span class="bg-red-600 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold flex-shrink-0">4</span>
                  <div>
                    <p class="font-bold text-red-900 dark:text-red-300 mb-1">Verify Data Accuracy</p>
                    <p class="text-gray-600 dark:text-gray-400">Ensure your source data (Excel/CSV) is accurate and complete before generating SQL.</p>
                  </div>
                </div>
                <div class="flex items-start gap-3">
                  <span class="bg-red-600 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold flex-shrink-0">5</span>
                  <div>
                    <p class="font-bold text-red-900 dark:text-red-300 mb-1">Save Generated SQL Files</p>
                    <p class="text-gray-600 dark:text-gray-400">Once downloaded, you are responsible for securely storing the SQL files.</p>
                  </div>
                </div>
              </div>
            </div>
            <UAlert color="red" variant="solid" :close-button="null">
              <template #title>CRITICAL DISCLAIMER</template>
              <template #description>
                <p class="mt-2">
                  SQLSheetr is NOT liable for any data loss, corruption, errors, or damages that occur in your database as a result of executing generated SQL statements. The Service generates SQL based on YOUR inputs, but YOU are SOLELY RESPONSIBLE for validating, testing, and executing it. By using this service, you accept FULL RESPONSIBILITY for all consequences.
                </p>
              </template>
            </UAlert>
          </section>

          <!-- Sections 10-13 -->
          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">10. Termination</h2>
            <p class="text-lg text-gray-700 dark:text-gray-300">
              We may terminate or suspend your account and access to the Service immediately, without prior notice or liability, for any reason, including breach of these Terms. Upon termination, your right to use the Service will immediately cease.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">11. Changes to Terms</h2>
            <p class="text-lg text-gray-700 dark:text-gray-300">
              We reserve the right to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days' notice prior to any new terms taking effect. Continued use of the Service after changes constitutes acceptance of the modified Terms.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">12. Governing Law</h2>
            <p class="text-lg text-gray-700 dark:text-gray-300">
              These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which SQLSheetr operates, without regard to its conflict of law provisions.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">13. Contact Information</h2>
            <p class="text-lg text-gray-700 dark:text-gray-300">
              If you have any questions about these Terms, please contact us.
            </p>
          </section>
        </div>

        <!-- Footer Navigation -->
        <div class="bg-gradient-to-r from-gray-50 to-green-50 dark:from-gray-800 dark:to-green-900/20 px-8 py-6 border-t border-gray-200 dark:border-gray-800">
          <router-link to="/" class="inline-flex items-center gap-2 text-green-600 dark:text-green-400 font-semibold hover:text-green-800 dark:hover:text-green-300 transition-colors">
            ← Back to Home
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
