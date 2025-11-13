#!/usr/bin/env node

/**
 * Script d'arrêt cross-platform pour DB Importer
 * Compatible Windows, macOS, Linux
 */

import { exec } from 'child_process';
import { platform } from 'os';
import { promisify } from 'util';

const execAsync = promisify(exec);

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

async function killProcessByName(processName) {
  const isWindows = platform() === 'win32';

  try {
    if (isWindows) {
      // Windows: utilise taskkill
      const { stdout } = await execAsync(`tasklist /FI "IMAGENAME eq ${processName}.exe" /FO CSV /NH`);
      if (stdout.includes(processName)) {
        await execAsync(`taskkill /F /IM ${processName}.exe /T`);
        return true;
      }
    } else {
      // Unix/Linux/macOS: utilise pkill
      await execAsync(`pkill -f "${processName}"`);
      return true;
    }
  } catch (error) {
    // Processus non trouvé ou déjà arrêté
    return false;
  }

  return false;
}

async function killProcessByPort(port) {
  const isWindows = platform() === 'win32';

  try {
    if (isWindows) {
      // Windows: trouve et tue le processus sur le port
      const { stdout } = await execAsync(`netstat -ano | findstr :${port}`);
      const lines = stdout.split('\n');
      const pids = new Set();

      for (const line of lines) {
        const match = line.trim().match(/LISTENING\s+(\d+)/);
        if (match) {
          pids.add(match[1]);
        }
      }

      for (const pid of pids) {
        await execAsync(`taskkill /F /PID ${pid}`);
      }

      return pids.size > 0;
    } else {
      // Unix/Linux/macOS: utilise lsof
      const { stdout } = await execAsync(`lsof -ti:${port}`);
      const pids = stdout.trim().split('\n').filter(p => p);

      for (const pid of pids) {
        await execAsync(`kill -9 ${pid}`);
      }

      return pids.length > 0;
    }
  } catch (error) {
    return false;
  }
}

async function main() {
  log('\n🛑 Arrêt de tous les serveurs de développement...\n', colors.yellow);

  const processes = ['air', 'vite', 'node'];
  const ports = [3000, 5173];

  // Arrêter les processus par nom
  for (const processName of processes) {
    log(`🔍 Recherche de processus: ${processName}...`, colors.blue);
    const killed = await killProcessByName(processName);
    if (killed) {
      log(`✅ ${processName} arrêté`, colors.green);
    } else {
      log(`⚠️  Aucun processus ${processName} trouvé`, colors.yellow);
    }
  }

  // Arrêter les processus par port
  for (const port of ports) {
    log(`🔍 Libération du port ${port}...`, colors.blue);
    const killed = await killProcessByPort(port);
    if (killed) {
      log(`✅ Port ${port} libéré`, colors.green);
    }
  }

  log('\n✅ Tous les serveurs sont arrêtés\n', colors.green);
}

main().catch(error => {
  log(`❌ Erreur: ${error.message}`, colors.red);
  process.exit(1);
});
