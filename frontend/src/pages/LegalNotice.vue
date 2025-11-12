<template>
  <div class="container mx-auto px-4 py-8 max-w-4xl">
    <div class="bg-white rounded-lg shadow-lg p-8">
      <h1 class="text-3xl font-bold text-gray-900 mb-6">Legal Notice</h1>

      <div class="prose prose-blue max-w-none">
        <p class="text-gray-600 mb-6">
          Last updated: {{ lastUpdated }}
        </p>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">1. Site Publisher</h2>
          <p class="text-gray-700 mb-4">
            This website is published by SQL Data Importer.
          </p>
          <div class="bg-gray-50 p-4 rounded-lg mb-4">
            <p class="text-gray-700"><strong>Service Name:</strong> SQL Data Importer</p>
            <p class="text-gray-700"><strong>Type:</strong> Web-based SQL Data Import Tool</p>
            <p class="text-gray-700"><strong>Description:</strong> Secure platform for importing data from Excel/CSV files into SQL databases (MySQL/MariaDB, PostgreSQL)</p>
            <p class="text-gray-700 mt-2"><strong>Technology Stack:</strong></p>
            <ul class="list-disc list-inside text-gray-700 ml-4">
              <li>Backend: Go 1.21+</li>
              <li>Frontend: Vue 3 + TypeScript + Vite + PrimeVue</li>
              <li>Database: Supabase (PostgreSQL)</li>
              <li>Hosting: Docker containerization on VPS</li>
            </ul>
          </div>
          <p class="text-gray-700 mb-4">
            <em>Note: Please update this section with your actual company information, including registered business name, business address, company registration number (SIRET/SIREN for France, equivalent for other jurisdictions), and official contact details.</em>
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">2. Website Hosting</h2>
          <p class="text-gray-700 mb-4">
            This website uses the following hosting infrastructure:
          </p>
          <div class="bg-gray-50 p-4 rounded-lg mb-4">
            <p class="text-gray-700"><strong>Web Application Hosting:</strong> VPS (Virtual Private Server) with Docker containerization</p>
            <p class="text-gray-700"><strong>Database Hosting:</strong> Supabase (PostgreSQL managed database service)</p>
            <p class="text-gray-700 mt-2">Supabase Inc.<br>
            970 Toa Payoh North, #07-04<br>
            Singapore 318992</p>
            <p class="text-gray-700 mt-2">Supabase is SOC 2 Type II compliant and provides secure, managed PostgreSQL database services.</p>
          </div>
          <p class="text-gray-700 mb-4">
            <em>Note: Please add your specific VPS hosting provider information (name, address, contact) as required by applicable law in your jurisdiction.</em>
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">3. Intellectual Property</h2>
          <p class="text-gray-700 mb-4">
            All content on this website, including but not limited to:
          </p>
          <ul class="list-disc list-inside text-gray-700 mb-4 ml-4">
            <li>Source code (Go backend, Vue.js frontend)</li>
            <li>User interface design and components (PrimeVue, TailwindCSS)</li>
            <li>SQL parsing and generation algorithms</li>
            <li>Levenshtein distance matching implementation</li>
            <li>Documentation, text, and graphics</li>
            <li>Logos and branding elements</li>
            <li>Database schema and architecture</li>
          </ul>
          <p class="text-gray-700 mb-4">
            is the property of SQL Data Importer and is protected by international copyright laws.
          </p>
          <p class="text-gray-700 mb-4">
            <strong>Open Source Components:</strong> This service uses open-source libraries and frameworks (Go, Vue.js, PrimeVue, etc.) which retain their respective licenses. The service's proprietary code and implementation remain the exclusive property of SQL Data Importer.
          </p>
          <p class="text-gray-700 mb-4">
            <strong>Your Data:</strong> You retain all intellectual property rights to your uploaded files and data. The Service does not claim any ownership over your SQL schemas or data files.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">4. Trademarks</h2>
          <p class="text-gray-700 mb-4">
            "SQL Data Importer" and "SQL Importer" and all related logos and service marks are trademarks of SQL Data Importer.
          </p>
          <p class="text-gray-700 mb-4">
            Third-party trademarks referenced on this site:
          </p>
          <ul class="list-disc list-inside text-gray-700 mb-4 ml-4">
            <li>MySQL, MariaDB are trademarks of Oracle Corporation and MariaDB Foundation respectively</li>
            <li>PostgreSQL is a trademark of the PostgreSQL Global Development Group</li>
            <li>Vue.js, Vite are trademarks of their respective owners</li>
            <li>Supabase is a trademark of Supabase Inc.</li>
            <li>Go (Golang) is a trademark of Google LLC</li>
            <li>PrimeVue is a trademark of PrimeTek Informatics</li>
          </ul>
          <p class="text-gray-700 mb-4">
            All other trademarks, service marks, and trade names referenced are the property of their respective owners.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">5. Website Director</h2>
          <p class="text-gray-700 mb-4">
            <em>Note: Please add publication director information as required by applicable law in your jurisdiction.</em>
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">6. Personal Data Protection</h2>
          <p class="text-gray-700 mb-4">
            SQL Importer is committed to protecting your personal data. For detailed information about how we collect, use, and protect your data, please refer to our <router-link to="/privacy-policy" class="text-blue-600 hover:text-blue-800 underline">Privacy Policy</router-link>.
          </p>
          <p class="text-gray-700 mb-4">
            In accordance with applicable data protection regulations (including GDPR for EU users), you have the right to access, rectify, delete, and port your personal data. You can exercise these rights by contacting us.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">7. Cookies</h2>
          <p class="text-gray-700 mb-4">
            This website uses cookies to improve user experience and analyze website traffic. By continuing to use this website, you consent to our use of cookies in accordance with our Privacy Policy.
          </p>
          <p class="text-gray-700 mb-4">
            You can configure your browser to refuse cookies or to alert you when cookies are being sent. However, some features of the website may not function properly without cookies.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">8. Limitation of Liability</h2>
          <p class="text-gray-700 mb-4">
            SQL Importer strives to ensure the accuracy and reliability of information provided on this website. However, we cannot guarantee:
          </p>
          <ul class="list-disc list-inside text-gray-700 mb-4 ml-4">
            <li>The accuracy, completeness, or timeliness of the information</li>
            <li>That the website will be uninterrupted or error-free</li>
            <li>That defects will be corrected</li>
            <li>That the website or servers are free from viruses or harmful components</li>
          </ul>
          <p class="text-gray-700 mb-4">
            SQL Importer shall not be liable for any direct, indirect, incidental, consequential, or punitive damages arising from your use of or inability to use the website.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">9. External Links</h2>
          <p class="text-gray-700 mb-4">
            This website may contain links to external websites. These links are provided for your convenience. SQL Importer has no control over the content of these external sites and accepts no responsibility for them or for any loss or damage that may arise from your use of them.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">10. Applicable Law</h2>
          <p class="text-gray-700 mb-4">
            This website and these legal notices are governed by and construed in accordance with applicable laws. Any disputes relating to this website shall be subject to the exclusive jurisdiction of the competent courts.
          </p>
          <p class="text-gray-700 mb-4">
            <em>Note: Please specify the applicable jurisdiction and governing law for your service.</em>
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">11. Report Illegal Content</h2>
          <p class="text-gray-700 mb-4">
            If you believe that content on this website is illegal or infringes your rights, please contact us immediately with:
          </p>
          <ul class="list-disc list-inside text-gray-700 mb-4 ml-4">
            <li>Your contact information</li>
            <li>Description of the content in question</li>
            <li>Location (URL) of the content</li>
            <li>Reason for the complaint</li>
            <li>Supporting evidence (if applicable)</li>
          </ul>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">12. Modification of Legal Notice</h2>
          <p class="text-gray-700 mb-4">
            SQL Importer reserves the right to modify this legal notice at any time. Any changes will be effective immediately upon posting on this page. Your continued use of the website after changes constitutes acceptance of the modified legal notice.
          </p>
        </section>

        <section class="mb-8">
          <h2 class="text-2xl font-semibold text-gray-900 mb-4">13. Contact</h2>
          <p class="text-gray-700 mb-4">
            For any questions regarding this legal notice or the website, please contact us.
          </p>
          <p class="text-gray-700 mb-4">
            <em>Note: Please add specific contact information (email, phone, postal address) as required by law.</em>
          </p>
        </section>

        <div class="bg-yellow-50 border-l-4 border-yellow-400 p-4 mt-8">
          <div class="flex">
            <div class="flex-shrink-0">
              <i class="pi pi-exclamation-triangle text-yellow-400"></i>
            </div>
            <div class="ml-3">
              <h3 class="text-sm font-medium text-yellow-800">Important Notice</h3>
              <div class="mt-2 text-sm text-yellow-700">
                <p>This legal notice template should be customized with your actual company information and reviewed by legal counsel to ensure compliance with applicable laws in your jurisdiction. Areas requiring customization are marked with <em>italic notes</em>.</p>
              </div>
            </div>
          </div>
        </div>
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
