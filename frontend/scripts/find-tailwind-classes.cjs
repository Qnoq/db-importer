#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Pattern pour détecter les classes Tailwind
const tailwindPattern = /\b(bg|text|border|shadow|rounded|p|m|flex|font|hover|dark|space|gap|grid|col|row|h|w|min|max|inline|block|hidden|visible|absolute|relative|fixed|sticky|z|opacity|transition|transform|scale|rotate|translate|duration|ease|cursor|select|outline|ring|divide|placeholder|resize|fill|stroke|sr-only)-[\w-]+/g;

function scanFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const matches = content.match(tailwindPattern);

  if (matches && matches.length > 0) {
    const uniqueClasses = [...new Set(matches)];
    return {
      file: filePath.replace(process.cwd() + '/', ''),
      count: uniqueClasses.length,
      classes: uniqueClasses.slice(0, 10) // Premiers 10 exemples
    };
  }
  return null;
}

function scanDirectory(dir) {
  const results = [];
  const files = fs.readdirSync(dir);

  files.forEach(file => {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory() && !file.includes('node_modules')) {
      results.push(...scanDirectory(fullPath));
    } else if (file.endsWith('.vue') || file.endsWith('.ts') || file.endsWith('.js')) {
      const result = scanFile(fullPath);
      if (result) results.push(result);
    }
  });

  return results;
}

// Scanner le projet
console.log('🔍 Recherche des classes Tailwind...\n');
const results = scanDirectory('./src');

if (results.length === 0) {
  console.log('✅ Aucune classe Tailwind trouvée !');
} else {
  console.log(`📊 ${results.length} fichiers contiennent des classes Tailwind:\n`);

  results.sort((a, b) => b.count - a.count).forEach(r => {
    console.log(`📄 ${r.file}`);
    console.log(`   ${r.count} classes détectées`);
    console.log(`   Exemples: ${r.classes.slice(0, 5).join(', ')}`);
    console.log('');
  });

  console.log('\n💡 Utilisez les mappings dans ce guide pour remplacer ces classes.');
}
