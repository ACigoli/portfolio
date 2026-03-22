const bcrypt = require('bcryptjs');
const { getDb } = require('./connection');

function seedDatabase() {
  const db = getDb();

  // Admin
  const adminEmail = process.env.ADMIN_EMAIL;
  const adminPassword = process.env.ADMIN_PASSWORD;

  if (!adminEmail || !adminPassword) {
    console.warn('⚠️  ADMIN_EMAIL e ADMIN_PASSWORD não definidos no .env — admin não criado.');
    return;
  }

  const adminExists = db.prepare('SELECT id FROM admins WHERE email = ?').get(adminEmail);

  if (!adminExists) {
    const hash = bcrypt.hashSync(adminPassword, 10);
    db.prepare('INSERT INTO admins (email, password) VALUES (?, ?)').run(adminEmail, hash);
    console.log('✅ Admin criado');
  }

  // About
  const aboutExists = db.prepare('SELECT id FROM about WHERE id = 1').get();
  if (!aboutExists) {
    db.prepare(`
      INSERT INTO about (id, name, role, bio, location, email, github_url, linkedin_url, instagram_url, available)
      VALUES (1, ?, ?, ?, ?, ?, ?, ?, ?, 1)
    `).run(
      'Alexsandro Cigoli',
      'Flutter & Mobile Developer',
      'Desenvolvedor mobile com mais de 5 anos de experiência construindo aplicações Flutter de alta qualidade.',
      'São Paulo, Brasil',
      'contato.alekisgg@gmail.com',
      'https://github.com/ACigoli',
      'https://www.linkedin.com/in/alexsandro-cigoli-2b64b8224/',
      'https://www.instagram.com/alekisgg/'
    );
  }

  // Projects
  const projectsExist = db.prepare('SELECT COUNT(*) as count FROM projects').get();
  if (projectsExist.count === 0) {
    const insertProject = db.prepare(`
      INSERT INTO projects (title, description, category, technologies, github_url, featured, order_index)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `);
    insertProject.run('App de Finanças', 'Aplicativo mobile para controle financeiro pessoal com gráficos e relatórios.', 'Mobile', JSON.stringify(['Flutter', 'Dart', 'Firebase', 'Hive']), 'https://github.com/ACigoli', 1, 1);
    insertProject.run('E-commerce App', 'App de compras com carrinho, pagamentos e rastreamento de pedidos.', 'Mobile', JSON.stringify(['Flutter', 'Dart', 'REST API', 'GetX']), 'https://github.com/ACigoli', 1, 2);
    insertProject.run('API de Integração', 'API REST para integração entre sistemas com autenticação JWT e documentação.', 'Backend', JSON.stringify(['Node.js', 'Express', 'SQLite', 'JWT']), 'https://github.com/ACigoli', 0, 3);
    console.log('✅ Projetos de exemplo criados');
  }

  // Skills
  const skillsExist = db.prepare('SELECT COUNT(*) as count FROM skills').get();
  if (skillsExist.count === 0) {
    const insertSkill = db.prepare('INSERT INTO skills (name, level, category, order_index) VALUES (?, ?, ?, ?)');
    insertSkill.run('Flutter', 92, 'Mobile', 1);
    insertSkill.run('Dart', 88, 'Mobile', 2);
    insertSkill.run('Firebase', 75, 'Backend', 3);
    insertSkill.run('REST API', 80, 'Backend', 4);
    insertSkill.run('Node.js', 70, 'Backend', 5);
    insertSkill.run('Git', 85, 'Ferramentas', 6);
    console.log('✅ Skills de exemplo criadas');
  }

  // Services
  const servicesExist = db.prepare('SELECT COUNT(*) as count FROM services').get();
  if (servicesExist.count === 0) {
    const insertService = db.prepare(`
      INSERT INTO services (title, description, icon_name, gradient_start, gradient_end, features, order_index)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `);
    insertService.run(
      'Desenvolvimento de App Mobile',
      'Criação de aplicativos iOS e Android com Flutter, entregando experiências nativas com código único, alta performance e design moderno.',
      'phone_android',
      '#915EFF',
      '#6366F1',
      'UI/UX moderna e responsiva|Integração com Firebase|Publicação na App Store e Google Play|Performance nativa com Dart',
      1
    );
    insertService.run(
      'Integração com API REST',
      'Consumo e integração de APIs RESTful no app, com autenticação segura, tratamento de erros e sincronização eficiente de dados.',
      'api',
      '#00D4AA',
      '#06B6D4',
      'Autenticação JWT e OAuth|Integração com serviços externos|Cache e gerenciamento de estado|Tratamento de erros robusto',
      2
    );
    console.log('✅ Serviços de exemplo criados');
  }

  // Experience
  const expExist = db.prepare('SELECT COUNT(*) as count FROM experience').get();
  if (expExist.count === 0) {
    const insertExp = db.prepare(`
      INSERT INTO experience (company, role, description, start_date, end_date, current, technologies, order_index)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `);
    insertExp.run(
      'Empresa Atual',
      'Flutter Developer',
      'Desenvolvimento de aplicativos mobile com Flutter, integração com APIs REST e Firebase.',
      '2022-01',
      null,
      1,
      JSON.stringify(['Flutter', 'Dart', 'Firebase', 'REST API']),
      1
    );
    insertExp.run(
      'Empresa Anterior',
      'Mobile Developer Jr',
      'Desenvolvimento e manutenção de aplicativos mobile, implementação de novas features.',
      '2020-06',
      '2021-12',
      0,
      JSON.stringify(['Flutter', 'Dart', 'Git']),
      2
    );
    console.log('✅ Experiências de exemplo criadas');
  }
}

module.exports = { seedDatabase };
