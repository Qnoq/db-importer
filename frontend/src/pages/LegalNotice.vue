<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-950">
    <div class="max-w-7xl mx-auto px-4 py-12">
      <div class="bg-white dark:bg-gray-900 rounded-2xl shadow-2xl overflow-hidden mb-8 border border-gray-200 dark:border-gray-800">
        <!-- Header -->
        <div class="bg-gradient-to-r from-green-600 to-emerald-700 px-8 py-10">
          <h1 class="text-4xl font-extrabold text-white mb-3">Legal Notice</h1>
          <p class="text-white/90 text-lg">SQLSheetr Data Import Service</p>
          <p class="text-white/70 text-sm mt-2">Last updated: {{ lastUpdated }}</p>
        </div>

        <div class="px-8 py-6 max-w-none">
          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">1. Site Publisher</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              This website is published by SQLSheetr.
            </p>
            <div class="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-6 mb-4">
              <p class="text-gray-700 dark:text-gray-300 mb-2"><strong>Service Name:</strong> SQLSheetr</p>
              <p class="text-gray-700 dark:text-gray-300 mb-2"><strong>Type:</strong> Web-based SQL Data Import Tool</p>
              <p class="text-gray-700 dark:text-gray-300 mb-2"><strong>Description:</strong> Secure platform for importing data from Excel/CSV files into SQL databases (MySQL/MariaDB, PostgreSQL)</p>
              <p class="text-gray-700 dark:text-gray-300 mb-2"><strong>Technology Stack:</strong></p>
              <ul class="list-disc list-inside text-gray-600 dark:text-gray-400 ml-4 space-y-1">
                <li>Backend: Go 1.21+</li>
                <li>Frontend: Vue 3 + TypeScript + Vite + Nuxt UI</li>
                <li>Database: Supabase (PostgreSQL)</li>
                <li>Hosting: Docker containerization on VPS</li>
              </ul>
            </div>
            <p class="text-sm italic text-gray-600 dark:text-gray-400">
              Note: Please update this section with your actual company information, including registered business name, business address, company registration number (SIRET/SIREN for France, equivalent for other jurisdictions), and official contact details.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">2. Website Hosting</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              This website uses the following hosting infrastructure:
            </p>
            <div class="bg-gray-50 dark:bg-gray-900 border border-gray-200 dark:border-gray-800 rounded-lg p-6 mb-4">
              <p class="text-gray-700 dark:text-gray-300 mb-2"><strong>Web Application Hosting:</strong> VPS (Virtual Private Server) with Docker containerization</p>
              <p class="text-gray-700 dark:text-gray-300 mb-2"><strong>Database Hosting:</strong> Supabase (PostgreSQL managed database service)</p>
              <p class="text-gray-700 dark:text-gray-300 mb-2">Supabase Inc.<br>970 Toa Payoh North, #07-04<br>Singapore 318992</p>
              <p class="text-gray-700 dark:text-gray-300 text-sm">Supabase is SOC 2 Type II compliant and provides secure, managed PostgreSQL database services.</p>
            </div>
            <p class="text-sm italic text-gray-600 dark:text-gray-400">
              Note: Please add your specific VPS hosting provider information (name, address, contact) as required by applicable law in your jurisdiction.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">3. Intellectual Property</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              All content on this website, including but not limited to:
            </p>
            <ul class="list-disc list-inside text-gray-600 dark:text-gray-400 mb-4 ml-4 space-y-1">
              <li>Source code (Go backend, Vue.js frontend)</li>
              <li>User interface design and components (Nuxt UI, TailwindCSS)</li>
              <li>SQL parsing and generation algorithms</li>
              <li>Levenshtein distance matching implementation</li>
              <li>Documentation, text, and graphics</li>
              <li>Logos and branding elements</li>
              <li>Database schema and architecture</li>
            </ul>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              is the property of SQLSheetr and is protected by international copyright laws.
            </p>
            <p class="text-lg mb-6 text-gray-700 dark:text-gray-300">
              <strong>Open Source Components:</strong> This service uses open-source libraries and frameworks (Go, Vue.js, Nuxt UI, etc.) which retain their respective licenses. The service's proprietary code and implementation remain the exclusive property of SQLSheetr.
            </p>
            <UAlert color="blue" variant="soft">
              <template #description>
                <p class="font-semibold">
                  <strong>Your Data:</strong> You retain all intellectual property rights to your uploaded files and data. The Service does not claim any ownership over your SQL schemas or data files.
                </p>
              </template>
            </UAlert>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">4. Trademarks</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              "SQLSheetr" and all related logos and service marks are trademarks of SQLSheetr.
            </p>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              Third-party trademarks referenced on this site:
            </p>
            <ul class="list-disc list-inside text-gray-600 dark:text-gray-400 mb-4 ml-4 space-y-1">
              <li>MySQL, MariaDB are trademarks of Oracle Corporation and MariaDB Foundation respectively</li>
              <li>PostgreSQL is a trademark of the PostgreSQL Global Development Group</li>
              <li>Vue.js, Vite are trademarks of their respective owners</li>
              <li>Supabase is a trademark of Supabase Inc.</li>
              <li>Go (Golang) is a trademark of Google LLC</li>
              <li>Nuxt UI is a trademark of Nuxt Labs</li>
            </ul>
            <p class="text-lg text-gray-700 dark:text-gray-300">
              All other trademarks, service marks, and trade names referenced are the property of their respective owners.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">5. Website Director</h2>
            <p class="text-sm italic text-gray-600 dark:text-gray-400">
              Note: Please add publication director information as required by applicable law in your jurisdiction.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">6. Personal Data Protection</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              SQL Importer is committed to protecting your personal data. For detailed information about how we collect, use, and protect your data, please refer to our <router-link to="/privacy-policy" class="text-green-600 hover:text-green-800 underline">Privacy Policy</router-link>.
            </p>
            <p class="text-lg text-gray-700 dark:text-gray-300">
              In accordance with applicable data protection regulations (including GDPR for EU users), you have the right to access, rectify, delete, and port your personal data. You can exercise these rights by contacting us.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">7. Cookies</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              This website uses cookies to improve user experience and analyze website traffic. By continuing to use this website, you consent to our use of cookies in accordance with our Privacy Policy.
            </p>
            <p class="text-lg text-gray-700 dark:text-gray-300">
              You can configure your browser to refuse cookies or to alert you when cookies are being sent. However, some features of the website may not function properly without cookies.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">8. Limitation of Liability</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              SQL Importer strives to ensure the accuracy and reliability of information provided on this website. However, we cannot guarantee:
            </p>
            <ul class="list-disc list-inside text-gray-600 dark:text-gray-400 mb-4 ml-4 space-y-1">
              <li>The accuracy, completeness, or timeliness of the information</li>
              <li>That the website will be uninterrupted or error-free</li>
              <li>That defects will be corrected</li>
              <li>That the website or servers are free from viruses or harmful components</li>
            </ul>
            <p class="text-lg text-gray-700 dark:text-gray-300">
              SQL Importer shall not be liable for any direct, indirect, incidental, consequential, or punitive damages arising from your use of or inability to use the website.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">9. External Links</h2>
            <p class="text-lg text-gray-700 dark:text-gray-300">
              This website may contain links to external websites. These links are provided for your convenience. SQL Importer has no control over the content of these external sites and accepts no responsibility for them or for any loss or damage that may arise from your use of them.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">10. Applicable Law</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              This website and these legal notices are governed by and construed in accordance with applicable laws. Any disputes relating to this website shall be subject to the exclusive jurisdiction of the competent courts.
            </p>
            <p class="text-sm italic text-gray-600 dark:text-gray-400">
              Note: Please specify the applicable jurisdiction and governing law for your service.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">11. Report Illegal Content</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              If you believe that content on this website is illegal or infringes your rights, please contact us immediately with:
            </p>
            <ul class="list-disc list-inside text-gray-600 dark:text-gray-400 ml-4 space-y-1">
              <li>Your contact information</li>
              <li>Description of the content in question</li>
              <li>Location (URL) of the content</li>
              <li>Reason for the complaint</li>
              <li>Supporting evidence (if applicable)</li>
            </ul>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">12. Modification of Legal Notice</h2>
            <p class="text-lg text-gray-700 dark:text-gray-300">
              SQLSheetr reserves the right to modify this legal notice at any time. Any changes will be effective immediately upon posting on this page. Your continued use of the website after changes constitutes acceptance of the modified legal notice.
            </p>
          </section>

          <section class="mb-10">
            <h2 class="text-3xl font-bold mb-4 pb-2 border-b-2 border-green-600 text-gray-900 dark:text-gray-100">13. Contact</h2>
            <p class="text-lg mb-4 text-gray-700 dark:text-gray-300">
              For any questions regarding this legal notice or the website, please contact us.
            </p>
            <p class="text-sm italic text-gray-600 dark:text-gray-400">
              Note: Please add specific contact information (email, phone, postal address) as required by law.
            </p>
          </section>

          <UAlert color="yellow" variant="solid" :close-button="null">
            <template #title>Important Notice</template>
            <template #description>
              <p>
                This legal notice template should be customized with your actual company information and reviewed by legal counsel to ensure compliance with applicable laws in your jurisdiction. Areas requiring customization are marked with <em>italic notes</em>.
              </p>
            </template>
          </UAlert>
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
