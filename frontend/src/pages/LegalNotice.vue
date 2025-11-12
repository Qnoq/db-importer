<template>
  <div class="legal-page">
    <div class="legal-container">
      <!-- Header Section -->
      <div class="legal-card">
        <div class="legal-header">
          <h1 class="legal-title">Legal Notice</h1>
          <p class="legal-subtitle">SQLSheetr Data Import Service</p>
          <p class="legal-date">Last updated: {{ lastUpdated }}</p>
        </div>

        <div class="legal-content">
          <section class="legal-section">
            <h2 class="section-title">1. Site Publisher</h2>
            <p class="section-text">
              This website is published by SQLSheetr.
            </p>
            <div class="info-box">
              <p class="info-item"><strong>Service Name:</strong> SQLSheetr</p>
              <p class="info-item"><strong>Type:</strong> Web-based SQL Data Import Tool</p>
              <p class="info-item"><strong>Description:</strong> Secure platform for importing data from Excel/CSV files into SQL databases (MySQL/MariaDB, PostgreSQL)</p>
              <p class="info-item tech-stack"><strong>Technology Stack:</strong></p>
              <ul class="tech-list">
                <li>Backend: Go 1.21+</li>
                <li>Frontend: Vue 3 + TypeScript + Vite + PrimeVue</li>
                <li>Database: Supabase (PostgreSQL)</li>
                <li>Hosting: Docker containerization on VPS</li>
              </ul>
            </div>
            <p class="note-text">
              <em>Note: Please update this section with your actual company information, including registered business name, business address, company registration number (SIRET/SIREN for France, equivalent for other jurisdictions), and official contact details.</em>
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">2. Website Hosting</h2>
            <p class="section-text">
              This website uses the following hosting infrastructure:
            </p>
            <div class="hosting-box">
              <p class="hosting-item"><strong>Web Application Hosting:</strong> VPS (Virtual Private Server) with Docker containerization</p>
              <p class="hosting-item"><strong>Database Hosting:</strong> Supabase (PostgreSQL managed database service)</p>
              <p class="hosting-address">Supabase Inc.<br>
              970 Toa Payoh North, #07-04<br>
              Singapore 318992</p>
              <p class="hosting-note">Supabase is SOC 2 Type II compliant and provides secure, managed PostgreSQL database services.</p>
            </div>
            <p class="note-text">
              <em>Note: Please add your specific VPS hosting provider information (name, address, contact) as required by applicable law in your jurisdiction.</em>
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">3. Intellectual Property</h2>
            <p class="section-text">
              All content on this website, including but not limited to:
            </p>
            <ul class="feature-list">
              <li>Source code (Go backend, Vue.js frontend)</li>
              <li>User interface design and components (PrimeVue, TailwindCSS)</li>
              <li>SQL parsing and generation algorithms</li>
              <li>Levenshtein distance matching implementation</li>
              <li>Documentation, text, and graphics</li>
              <li>Logos and branding elements</li>
              <li>Database schema and architecture</li>
            </ul>
            <p class="section-text">
              is the property of SQLSheetr and is protected by international copyright laws.
            </p>
            <p class="section-text">
              <strong>Open Source Components:</strong> This service uses open-source libraries and frameworks (Go, Vue.js, PrimeVue, etc.) which retain their respective licenses. The service's proprietary code and implementation remain the exclusive property of SQLSheetr.
            </p>
            <Message severity="info" :closable="false">
              <p class="data-rights-text">
                <i class="pi pi-info-circle"></i><strong>Your Data:</strong> You retain all intellectual property rights to your uploaded files and data. The Service does not claim any ownership over your SQL schemas or data files.
              </p>
            </Message>
          </section>

          <section class="legal-section">
            <h2 class="section-title">4. Trademarks</h2>
            <p class="section-text">
              "SQLSheetr" and all related logos and service marks are trademarks of SQLSheetr.
            </p>
            <p class="section-text">
              Third-party trademarks referenced on this site:
            </p>
            <ul class="feature-list">
              <li>MySQL, MariaDB are trademarks of Oracle Corporation and MariaDB Foundation respectively</li>
              <li>PostgreSQL is a trademark of the PostgreSQL Global Development Group</li>
              <li>Vue.js, Vite are trademarks of their respective owners</li>
              <li>Supabase is a trademark of Supabase Inc.</li>
              <li>Go (Golang) is a trademark of Google LLC</li>
              <li>PrimeVue is a trademark of PrimeTek Informatics</li>
            </ul>
            <p class="section-text">
              All other trademarks, service marks, and trade names referenced are the property of their respective owners.
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">5. Website Director</h2>
            <p class="note-text">
              <em>Note: Please add publication director information as required by applicable law in your jurisdiction.</em>
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">6. Personal Data Protection</h2>
            <p class="section-text">
              SQL Importer is committed to protecting your personal data. For detailed information about how we collect, use, and protect your data, please refer to our <router-link to="/privacy-policy" class="text-link">Privacy Policy</router-link>.
            </p>
            <p class="section-text">
              In accordance with applicable data protection regulations (including GDPR for EU users), you have the right to access, rectify, delete, and port your personal data. You can exercise these rights by contacting us.
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">7. Cookies</h2>
            <p class="section-text">
              This website uses cookies to improve user experience and analyze website traffic. By continuing to use this website, you consent to our use of cookies in accordance with our Privacy Policy.
            </p>
            <p class="section-text">
              You can configure your browser to refuse cookies or to alert you when cookies are being sent. However, some features of the website may not function properly without cookies.
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">8. Limitation of Liability</h2>
            <p class="section-text">
              SQL Importer strives to ensure the accuracy and reliability of information provided on this website. However, we cannot guarantee:
            </p>
            <ul class="feature-list">
              <li>The accuracy, completeness, or timeliness of the information</li>
              <li>That the website will be uninterrupted or error-free</li>
              <li>That defects will be corrected</li>
              <li>That the website or servers are free from viruses or harmful components</li>
            </ul>
            <p class="section-text">
              SQL Importer shall not be liable for any direct, indirect, incidental, consequential, or punitive damages arising from your use of or inability to use the website.
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">9. External Links</h2>
            <p class="section-text">
              This website may contain links to external websites. These links are provided for your convenience. SQL Importer has no control over the content of these external sites and accepts no responsibility for them or for any loss or damage that may arise from your use of them.
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">10. Applicable Law</h2>
            <p class="section-text">
              This website and these legal notices are governed by and construed in accordance with applicable laws. Any disputes relating to this website shall be subject to the exclusive jurisdiction of the competent courts.
            </p>
            <p class="note-text">
              <em>Note: Please specify the applicable jurisdiction and governing law for your service.</em>
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">11. Report Illegal Content</h2>
            <p class="section-text">
              If you believe that content on this website is illegal or infringes your rights, please contact us immediately with:
            </p>
            <ul class="feature-list">
              <li>Your contact information</li>
              <li>Description of the content in question</li>
              <li>Location (URL) of the content</li>
              <li>Reason for the complaint</li>
              <li>Supporting evidence (if applicable)</li>
            </ul>
          </section>

          <section class="legal-section">
            <h2 class="section-title">12. Modification of Legal Notice</h2>
            <p class="section-text">
              SQLSheetr reserves the right to modify this legal notice at any time. Any changes will be effective immediately upon posting on this page. Your continued use of the website after changes constitutes acceptance of the modified legal notice.
            </p>
          </section>

          <section class="legal-section">
            <h2 class="section-title">13. Contact</h2>
            <p class="section-text">
              For any questions regarding this legal notice or the website, please contact us.
            </p>
            <p class="note-text">
              <em>Note: Please add specific contact information (email, phone, postal address) as required by law.</em>
            </p>
          </section>

          <Message severity="warn" :closable="false" class="important-notice">
            <div class="notice-content">
              <h3 class="notice-title">Important Notice</h3>
              <p class="notice-text">
                This legal notice template should be customized with your actual company information and reviewed by legal counsel to ensure compliance with applicable laws in your jurisdiction. Areas requiring customization are marked with <em>italic notes</em>.
              </p>
            </div>
          </Message>
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
  margin-top: 2rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid var(--p-green-600);
  color: var(--p-text-color);
}

.section-text {
  font-size: 1.125rem;
  margin-bottom: 1rem;
  color: var(--p-text-color);
}

.note-text {
  margin-bottom: 1rem;
  color: var(--p-text-muted-color);
}

.info-box {
  background: var(--p-green-50);
  border: 1px solid var(--p-green-200);
  border-radius: 0.5rem;
  padding: 1.5rem;
  margin-bottom: 1rem;
}

.info-item {
  color: var(--p-text-muted-color);
  margin-bottom: 0.5rem;
}

.info-item.tech-stack {
  margin-top: 0.5rem;
}

.tech-list {
  list-style: disc;
  list-style-position: inside;
  color: var(--p-text-muted-color);
  margin-left: 1rem;
}

.hosting-box {
  background: var(--p-surface-50);
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
}

.hosting-item {
  color: var(--p-text-muted-color);
  margin-bottom: 0.5rem;
}

.hosting-address {
  color: var(--p-text-muted-color);
  margin-top: 0.5rem;
  margin-bottom: 0.5rem;
}

.hosting-note {
  color: var(--p-text-muted-color);
  margin-top: 0.5rem;
}

.feature-list {
  list-style: disc;
  list-style-position: inside;
  color: var(--p-text-muted-color);
  margin-bottom: 1rem;
  margin-left: 1rem;
  margin-top: 0.5rem;
}

.data-rights-text {
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.text-link {
  color: var(--p-primary-color);
  text-decoration: underline;
  transition: color 0.2s;
}

.text-link:hover {
  color: var(--p-primary-600);
}

.important-notice {
  margin-top: 2rem;
}

.notice-content {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.notice-title {
  font-size: 1.125rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.notice-text {
  font-size: 0.875rem;
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
