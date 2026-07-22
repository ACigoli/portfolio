-- Non-sensitive seed data (about/projects/skills/services/experience), same content as the
-- old src/database/seed.js. The admin account is intentionally NOT here — see api/README.md
-- for how to seed it manually with scripts/hash-password.mjs (no plaintext secrets in git).

INSERT INTO about (id, name, role, bio, location, email, github_url, linkedin_url, instagram_url, available)
VALUES (
  1,
  'Alexsandro Cigoli',
  'Flutter & Mobile Developer',
  'Desenvolvedor mobile com mais de 5 anos de experiência construindo aplicações Flutter de alta qualidade.',
  'São Paulo, Brasil',
  'contato.alekisgg@gmail.com',
  'https://github.com/ACigoli',
  'https://www.linkedin.com/in/alexsandro-cigoli-2b64b8224/',
  'https://www.instagram.com/alekisgg/',
  1
);

INSERT INTO projects (title, description, category, technologies, github_url, featured, order_index) VALUES
  ('App de Finanças', 'Aplicativo mobile para controle financeiro pessoal com gráficos e relatórios.', 'Mobile', '["Flutter","Dart","Firebase","Hive"]', 'https://github.com/ACigoli', 1, 1),
  ('E-commerce App', 'App de compras com carrinho, pagamentos e rastreamento de pedidos.', 'Mobile', '["Flutter","Dart","REST API","GetX"]', 'https://github.com/ACigoli', 1, 2),
  ('API de Integração', 'API REST para integração entre sistemas com autenticação JWT e documentação.', 'Backend', '["Node.js","Express","SQLite","JWT"]', 'https://github.com/ACigoli', 0, 3);

INSERT INTO skills (name, level, category, order_index) VALUES
  ('Flutter', 92, 'Mobile', 1),
  ('Dart', 88, 'Mobile', 2),
  ('Firebase', 75, 'Backend', 3),
  ('REST API', 80, 'Backend', 4),
  ('Node.js', 70, 'Backend', 5),
  ('Git', 85, 'Ferramentas', 6);

INSERT INTO services (title, description, icon_name, gradient_start, gradient_end, features, order_index) VALUES
  (
    'Desenvolvimento de App Mobile',
    'Criação de aplicativos iOS e Android com Flutter, entregando experiências nativas com código único, alta performance e design moderno.',
    'phone_android',
    '#915EFF',
    '#6366F1',
    'UI/UX moderna e responsiva|Integração com Firebase|Publicação na App Store e Google Play|Performance nativa com Dart',
    1
  ),
  (
    'Integração com API REST',
    'Consumo e integração de APIs RESTful no app, com autenticação segura, tratamento de erros e sincronização eficiente de dados.',
    'api',
    '#00D4AA',
    '#06B6D4',
    'Autenticação JWT e OAuth|Integração com serviços externos|Cache e gerenciamento de estado|Tratamento de erros robusto',
    2
  );

INSERT INTO experience (company, role, description, start_date, end_date, current, technologies, order_index) VALUES
  (
    'Empresa Atual',
    'Flutter Developer',
    'Desenvolvimento de aplicativos mobile com Flutter, integração com APIs REST e Firebase.',
    '2022-01',
    NULL,
    1,
    '["Flutter","Dart","Firebase","REST API"]',
    1
  ),
  (
    'Empresa Anterior',
    'Mobile Developer Jr',
    'Desenvolvimento e manutenção de aplicativos mobile, implementação de novas features.',
    '2020-06',
    '2021-12',
    0,
    '["Flutter","Dart","Git"]',
    2
  );
