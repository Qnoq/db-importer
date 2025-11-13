#!/usr/bin/env node

/**
 * Script de configuration cross-platform pour DB Importer
 * Compatible Windows, macOS, Linux
 */

import { existsSync, readFileSync, writeFileSync, copyFileSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = join(__dirname, '..');

const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
};

function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

function setupEnvFiles() {
  log('\n📝 Configuration des variables d\'environnement...', colors.blue);

  const envLocalPath = join(rootDir, '.env.local');
  const envExamplePath = join(rootDir, '.env.example');

  // Créer .env.local s'il n'existe pas
  if (!existsSync(envLocalPath)) {
    if (existsSync(envExamplePath)) {
      copyFileSync(envExamplePath, envLocalPath);
      log('✅ .env.local créé depuis .env.example', colors.green);
      log('\n⚠️  IMPORTANT: Édite .env.local avec tes vrais secrets:', colors.yellow);
      log('   - DATABASE_URL (Supabase)', colors.yellow);
      log('   - JWT_ACCESS_SECRET et JWT_REFRESH_SECRET', colors.yellow);
      log('   - SUPABASE_URL et SUPABASE_ANON_KEY\n', colors.yellow);
    } else {
      log('❌ .env.example non trouvé', colors.red);
      return false;
    }
  } else {
    log('✅ .env.local existe déjà', colors.green);
  }

  // Copier .env.local dans backend/.env et frontend/.env
  // Toujours copier pour s'assurer que les configs sont sync
  const backendEnvPath = join(rootDir, 'backend', '.env');
  const frontendEnvPath = join(rootDir, 'frontend', '.env');

  copyFileSync(envLocalPath, backendEnvPath);
  log('✅ backend/.env synchronisé', colors.green);

  copyFileSync(envLocalPath, frontendEnvPath);
  log('✅ frontend/.env synchronisé', colors.green);

  return true;
}

function setupAirConfig() {
  log('\n⚙️  Configuration de Air (hot reload backend)...', colors.blue);

  const airConfigPath = join(rootDir, 'backend', '.air.toml');

  // Détecter l'OS pour ajuster les extensions
  const isWindows = process.platform === 'win32';
  const binExt = isWindows ? '.exe' : '';
  const binPath = `./tmp/main${binExt}`;

  if (!existsSync(airConfigPath)) {
    const airConfig = `root = "."
testdata_dir = "testdata"
tmp_dir = "tmp"

[build]
  args_bin = []
  bin = "${binPath}"
  cmd = "go build -o ${binPath} ./cmd/server"
  delay = 1000
  exclude_dir = ["assets", "tmp", "vendor", "testdata"]
  exclude_file = []
  exclude_regex = ["_test.go"]
  exclude_unchanged = false
  follow_symlink = false
  full_bin = ""
  include_dir = []
  include_ext = ["go", "tpl", "tmpl", "html"]
  include_file = []
  kill_delay = "0s"
  log = "build-errors.log"
  poll = false
  poll_interval = 0
  rerun = false
  rerun_delay = 500
  send_interrupt = false
  stop_on_error = false

[color]
  app = ""
  build = "yellow"
  main = "magenta"
  runner = "green"
  watcher = "cyan"

[log]
  main_only = false
  time = false

[misc]
  clean_on_exit = false

[screen]
  clear_on_rebuild = false
  keep_scroll = true
`;

    writeFileSync(airConfigPath, airConfig, 'utf8');
    log(`✅ Configuration Air créée (${isWindows ? 'Windows' : 'Unix'})`, colors.green);
  } else {
    log('✅ Configuration Air existe déjà', colors.green);
  }
}

function checkDependencies() {
  log('\n🔍 Vérification des dépendances...', colors.blue);

  let allGood = true;

  // Vérifier Node.js
  try {
    const nodeVersion = process.version;
    log(`✅ Node.js ${nodeVersion}`, colors.green);
  } catch (e) {
    log('❌ Node.js non trouvé', colors.red);
    allGood = false;
  }

  // Vérifier Go (via process.env ou en essayant d'exécuter)
  log('⚠️  Assure-toi que Go est installé: https://go.dev/doc/install', colors.yellow);
  log('⚠️  Assure-toi que Air est installé: go install github.com/air-verse/air@latest', colors.yellow);

  return allGood;
}

function main() {
  log('\n================================', colors.blue);
  log('🚀 DB Importer - Setup', colors.blue);
  log('================================\n', colors.blue);

  checkDependencies();

  if (!setupEnvFiles()) {
    process.exit(1);
  }

  setupAirConfig();

  log('\n================================', colors.green);
  log('✅ Setup terminé !', colors.green);
  log('================================\n', colors.green);

  log('Prochaines étapes:', colors.blue);
  log('  1. Édite .env.local avec tes secrets');
  log('  2. Installe les dépendances: npm run install:all');
  log('  3. Lance: npm run dev\n');
}

main();
