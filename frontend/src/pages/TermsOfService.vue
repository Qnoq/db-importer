<template>
  <div class="legal-page">
    <div class="legal-container">
      <!-- Header Section -->
      <div class="legal-card">
        <div class="legal-header">
          <h1 class="legal-title">Terms of Service</h1>
          <p class="legal-subtitle">SQLSheetr Data Import Service</p>
          <p class="legal-date">Last updated: {{ lastUpdated }}</p>
        </div>

        <!-- Critical Warning Banner -->
        <Message severity="error" :closable="false" class="critical-banner">
          <div class="warning-content">
            <i class="pi pi-exclamation-triangle warning-icon"></i>
            <div>
              <h3 class="warning-title">CRITICAL: READ BEFORE USE</h3>
              <p class="warning-text">
                By using this service, you acknowledge and accept full responsibility for:
              </p>
              <ul class="warning-list">
                <li><strong>ALWAYS creating complete database backups before executing any generated SQL</strong></li>
                <li>Testing all generated SQL on development/staging environments first</li>
                <li>Reviewing and validating all SQL statements before execution</li>
                <li>Any and all consequences of executing generated SQL in your databases</li>
              </ul>
              <p class="warning-footer">
                WE ARE NOT LIABLE FOR ANY DATA LOSS, CORRUPTION, OR DAMAGE TO YOUR DATABASES.
              </p>
            </div>
          </div>
        </Message>

        <div class="legal-content">
          <section class="legal-section">
            <h2 class="section-title">1. Acceptance of Terms</h2>
            <p class="section-text">
              By accessing and using SQLSheetr ("the Service"), you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to abide by the terms below, please do not use this service.
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">2. Description of Service</h2>
            <p class="section-text">
              SQLSheetr is a secure web-based tool that helps you import data from Excel/CSV files into SQL databases. The Service provides the following features:
            </p>
            <ul class="feature-list">
              <li><strong>SQL Schema Parsing:</strong> Upload SQL dump files (.sql) containing CREATE TABLE statements for MySQL/MariaDB or PostgreSQL</li>
              <li><strong>Data File Upload:</strong> Upload Excel (.xlsx, .xls) or CSV files containing your data</li>
              <li><strong>Intelligent Column Mapping:</strong> Automatic column matching using Levenshtein distance algorithm with manual override options</li>
              <li><strong>Data Validation:</strong> Server-side validation against schema constraints (NOT NULL, data types, length, ranges)</li>
              <li><strong>SQL Generation:</strong> Generate type-safe, injection-proof INSERT statements ready for execution</li>
              <li><strong>Import History:</strong> Track your past imports and download generated SQL files (for registered users)</li>
            </ul>
            <Message severity="info" :closable="false" class="info-box">
              <p class="info-text">
                <i class="pi pi-info-circle"></i>
                <strong>Important:</strong> The Service does NOT connect to your database directly. You download the generated SQL and execute it yourself in your own environment, ensuring full control and security.
              </p>
            </Message>
          </section>

          <section class="legal-section">
            <h2 class="section-title">3. User Accounts</h2>
            <p class="section-text">
              To access certain features of the Service, you must register for an account. You agree to:
            </p>
            <ul class="feature-list">
              <li>Provide accurate, current, and complete information during registration</li>
              <li>Maintain the security of your password and account</li>
              <li>Notify us immediately of any unauthorized use of your account</li>
              <li>Be responsible for all activities that occur under your account</li>
            </ul>
          </section>

          <section class="legal-section">
            <h2 class="section-title">4. User Data and Privacy</h2>
            <p class="section-text">
              You retain all rights to your data. The Service processes your uploaded files (SQL schemas and data files) temporarily to generate SQL statements. Key privacy principles:
            </p>
            <ul class="feature-list">
              <li><strong>No Database Access:</strong> We never access or connect to your actual databases</li>
              <li><strong>Temporary Processing:</strong> Uploaded files are processed in memory and not permanently stored on our servers (except import history metadata for registered users)</li>
              <li><strong>You Control Execution:</strong> Generated SQL is downloaded by you and executed in your own environment</li>
              <li><strong>Account Data:</strong> For registered users, we store account information (email, name) and import history metadata (table names, row counts, timestamps) - not the actual data content</li>
            </ul>
            <p class="section-text">
              For complete details on data handling, please review our <router-link to="/privacy-policy" class="text-link">Privacy Policy</router-link>.
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">5. Acceptable Use</h2>
            <p class="section-text">
              You agree not to:
            </p>
            <ul class="feature-list">
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

          <section class="legal-section">
            <h2 class="section-title">6. Intellectual Property</h2>
            <p class="section-text">
              The Service and its original content, features, and functionality are owned by SQLSheetr and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title liability-title">7. Limitation of Liability</h2>
            <Message severity="error" :closable="false" class="liability-box">
              <p class="liability-header">
                <i class="pi pi-exclamation-circle"></i>PLEASE READ THIS SECTION CAREFULLY
              </p>
              <p class="liability-text">
                In no event shall SQLSheetr, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation:
              </p>
              <ul class="liability-list">
                <li><strong>Loss of data or database corruption</strong></li>
                <li><strong>Loss of profits, revenue, or business opportunities</strong></li>
                <li><strong>Downtime or service interruptions</strong></li>
                <li><strong>Errors in generated SQL statements</strong></li>
                <li><strong>Data integrity issues resulting from executed SQL</strong></li>
                <li>Any conduct or content of any third party on the Service</li>
                <li>Unauthorized access, use, or alteration of your transmissions or content</li>
              </ul>
              <p class="liability-footer">
                YOU ARE SOLELY RESPONSIBLE FOR BACKING UP YOUR DATABASES BEFORE EXECUTING ANY GENERATED SQL.
              </p>
            </Message>
          </section>

          <section class="legal-section">
            <h2 class="section-title">8. Disclaimer of Warranties</h2>
            <p class="section-text">
              The Service is provided on an "AS IS" and "AS AVAILABLE" basis. SQLSheetr makes no warranties, expressed or implied, regarding:
            </p>
            <ul class="feature-list">
              <li><strong>Accuracy or correctness of generated SQL statements</strong></li>
              <li><strong>Suitability of generated SQL for your specific use case</strong></li>
              <li>Merchantability, fitness for a particular purpose, or non-infringement</li>
              <li>That the Service will be uninterrupted, secure, or error-free</li>
              <li>That any defects will be corrected</li>
              <li><strong>That the generated SQL will not cause data loss or corruption</strong></li>
            </ul>
          </section>

          <section class="responsibility-section">
            <h2 class="responsibility-title">
              <i class="pi pi-shield"></i>9. Data Backup and User Responsibility
            </h2>
            <div class="responsibility-box">
              <p class="responsibility-header">
                <i class="pi pi-exclamation-triangle"></i>MANDATORY USER RESPONSIBILITIES:
              </p>
              <div class="responsibility-list">
                <div class="responsibility-item">
                  <span class="responsibility-number">1</span>
                  <div>
                    <p class="responsibility-item-title">ALWAYS BACKUP YOUR DATABASE FIRST</p>
                    <p class="responsibility-item-text">Create a complete backup of your database before executing ANY generated SQL. This is NON-NEGOTIABLE.</p>
                  </div>
                </div>
                <div class="responsibility-item">
                  <span class="responsibility-number">2</span>
                  <div>
                    <p class="responsibility-item-title">Test on Development/Staging Environment</p>
                    <p class="responsibility-item-text">Never execute generated SQL directly in production without testing it first.</p>
                  </div>
                </div>
                <div class="responsibility-item">
                  <span class="responsibility-number">3</span>
                  <div>
                    <p class="responsibility-item-title">Review Every SQL Statement</p>
                    <p class="responsibility-item-text">Carefully review the generated SQL before execution. Understand what it will do to your database.</p>
                  </div>
                </div>
                <div class="responsibility-item">
                  <span class="responsibility-number">4</span>
                  <div>
                    <p class="responsibility-item-title">Verify Data Accuracy</p>
                    <p class="responsibility-item-text">Ensure your source data (Excel/CSV) is accurate and complete before generating SQL.</p>
                  </div>
                </div>
                <div class="responsibility-item">
                  <span class="responsibility-number">5</span>
                  <div>
                    <p class="responsibility-item-title">Save Generated SQL Files</p>
                    <p class="responsibility-item-text">Once downloaded, you are responsible for securely storing the SQL files.</p>
                  </div>
                </div>
              </div>
            </div>
            <Message severity="error" :closable="false" class="disclaimer-box">
              <p class="disclaimer-title">
                CRITICAL DISCLAIMER
              </p>
              <p class="disclaimer-text">
                SQLSheetr is NOT liable for any data loss, corruption, errors, or damages that occur in your database as a result of executing generated SQL statements. The Service generates SQL based on YOUR inputs, but YOU are SOLELY RESPONSIBLE for validating, testing, and executing it. By using this service, you accept FULL RESPONSIBILITY for all consequences.
              </p>
            </Message>
          </section>

          <section class="legal-section">
            <h2 class="section-title">10. Termination</h2>
            <p class="section-text">
              We may terminate or suspend your account and access to the Service immediately, without prior notice or liability, for any reason, including breach of these Terms. Upon termination, your right to use the Service will immediately cease.
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">11. Changes to Terms</h2>
            <p class="section-text">
              We reserve the right to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days' notice prior to any new terms taking effect. Continued use of the Service after changes constitutes acceptance of the modified Terms.
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">12. Governing Law</h2>
            <p class="section-text">
              These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which SQLSheetr operates, without regard to its conflict of law provisions.
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">13. Contact Information</h2>
            <p class="section-text">
              If you have any questions about these Terms, please contact us.
            </p>
          </section>
        </div>

        <!-- Footer Navigation -->
        <div class="legal-footer">
          <router-link to="/" class="back-link">
            <i class="pi pi-arrow-left"></i>
            Back to Home
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import Message from 'primevue/message'

const lastUpdated = new Date().toLocaleDateString('en-US', {
  year: 'numeric',
  month: 'long',
  day: 'numeric'
})
</script>

<style scoped>
.legal-page {
  min-height: 100vh;
  background: var(--p-surface-ground);
  transition: background-color 0.2s;
}

.legal-container {
  max-width: 80rem;
  margin: 0 auto;
  padding: 3rem 1rem;
}

.legal-card {
  border-radius: 1rem;
  box-shadow: 0 25px 50px -12px rgb(0 0 0 / 0.25);
  overflow: hidden;
  margin-bottom: 2rem;
  border: 1px solid var(--p-surface-border);
  background: var(--p-surface-0);
  transition: all 0.2s;
}

.legal-header {
  background: linear-gradient(to right, var(--p-green-600), var(--p-emerald-700));
  padding: 2.5rem 2rem;
}

.legal-title {
  font-size: 2.25rem;
  font-weight: 800;
  color: white;
  margin-bottom: 0.75rem;
}

.legal-subtitle {
  color: rgba(255, 255, 255, 0.9);
  font-size: 1.125rem;
}

.legal-date {
  color: rgba(255, 255, 255, 0.7);
  font-size: 0.875rem;
  margin-top: 0.5rem;
}

.critical-banner {
  margin: 1.5rem;
}

.warning-content {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
}

.warning-icon {
  font-size: 1.5rem;
  margin-top: 0.25rem;
  flex-shrink: 0;
}

.warning-title {
  font-size: 1.125rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.warning-text {
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.warning-list {
  list-style: disc;
  list-style-position: inside;
  margin-left: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.warning-footer {
  font-weight: 700;
  margin-top: 0.75rem;
}

.legal-content {
  padding: 1.5rem 2rem;
  max-width: none;
}

.legal-section {
  margin-bottom: 2.5rem;
}

.section-title {
  font-size: 1.875rem;
  font-weight: 700;
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid var(--p-green-600);
  color: var(--p-text-color);
}

.liability-title {
  border-bottom-color: var(--p-red-600);
  color: var(--p-text-color);
}

.section-text {
  font-size: 1.125rem;
  margin-bottom: 1rem;
  color: var(--p-text-color);
}

.feature-list {
  list-style: disc;
  list-style-position: inside;
  color: var(--p-text-muted-color);
  margin-bottom: 1rem;
  margin-left: 1rem;
}

.info-box {
  margin: 1.5rem 0;
}

.info-text {
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.text-link {
  color: var(--p-green-600);
  text-decoration: underline;
  transition: color 0.2s;
}

.text-link:hover {
  color: var(--p-green-800);
}

.liability-box {
  padding: 1.5rem;
  margin-bottom: 1rem;
}

.liability-header {
  font-weight: 700;
  font-size: 1.125rem;
  margin-bottom: 0.75rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.liability-text {
  font-size: 1.125rem;
  margin-bottom: 1rem;
}

.liability-list {
  list-style: disc;
  list-style-position: inside;
  margin-bottom: 1rem;
  margin-left: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.liability-footer {
  font-weight: 700;
  margin-top: 1rem;
}

.responsibility-section {
  margin-bottom: 2.5rem;
  background: var(--p-yellow-50);
  border: 2px solid var(--p-yellow-400);
  border-radius: 0.75rem;
  padding: 1.5rem;
}

.responsibility-title {
  font-size: 1.875rem;
  font-weight: 700;
  color: var(--p-yellow-900);
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid var(--p-yellow-600);
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.responsibility-box {
  background: var(--p-surface-0);
  border: 2px solid var(--p-red-400);
  border-radius: 0.5rem;
  padding: 1.5rem;
  margin-bottom: 1rem;
}

.responsibility-header {
  color: var(--p-text-color);
  font-weight: 700;
  font-size: 1.25rem;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.responsibility-header i {
  color: var(--p-red-600);
}

.responsibility-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.responsibility-item {
  display: flex;
  align-items: flex-start;
  gap: 0.75rem;
}

.responsibility-number {
  background: var(--p-red-600);
  color: white;
  border-radius: 9999px;
  width: 2rem;
  height: 2rem;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  flex-shrink: 0;
}

.responsibility-item-title {
  font-weight: 700;
  color: var(--p-red-900);
  margin-bottom: 0.25rem;
}

.responsibility-item-text {
  color: var(--p-text-muted-color);
}

.disclaimer-box {
  margin-top: 1.5rem;
}

.disclaimer-title {
  font-weight: 700;
  font-size: 1.125rem;
  margin-bottom: 0.5rem;
}

.disclaimer-text {
  margin-top: 0.5rem;
}

.legal-footer {
  background: linear-gradient(to right, var(--p-surface-50), var(--p-green-50));
  padding: 1.5rem 2rem;
  border-top: 1px solid var(--p-surface-border);
}

.back-link {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--p-green-600);
  font-weight: 600;
  transition: color 0.2s;
  text-decoration: none;
}

.back-link:hover {
  color: var(--p-green-800);
}
</style>
