#!/usr/bin/env node
// Generates a bcrypt hash for the admin password from a CLI argument, so the plaintext
// password never has to be committed anywhere. Usage:
//   node scripts/hash-password.mjs "sua_senha_segura"
// Then use the printed hash in the `wrangler d1 execute` command documented in README.md.

import bcrypt from 'bcryptjs';

const password = process.argv[2];

if (!password) {
  console.error('Uso: node scripts/hash-password.mjs "<senha>"');
  process.exit(1);
}

const hash = bcrypt.hashSync(password, 10);
console.log(hash);
