BEGIN;
CREATE TABLE IF NOT EXISTS units (
  id SERIAL PRIMARY KEY,
  name TEXT UNIQUE NOT NULL
);
CREATE TABLE IF NOT EXISTS lines (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  unit_id INTEGER REFERENCES units(id) ON DELETE CASCADE,
  UNIQUE (name, unit_id)
);
CREATE TABLE IF NOT EXISTS machines (
  id SERIAL PRIMARY KEY,
  code TEXT,
  name TEXT NOT NULL,
  unit_id INTEGER REFERENCES units(id) ON DELETE SET NULL,
  line_id INTEGER REFERENCES lines(id) ON DELETE SET NULL,
  mttr_base NUMERIC,
  mttr_target NUMERIC,
  mtbf_base NUMERIC,
  mtbf_target NUMERIC
);
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL,
  unit TEXT
);
CREATE TABLE IF NOT EXISTS permissions (
  id SERIAL PRIMARY KEY,
  key TEXT UNIQUE NOT NULL
);
CREATE TABLE IF NOT EXISTS user_permissions (
  user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
  permission_id INTEGER REFERENCES permissions(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, permission_id)
);
CREATE TABLE IF NOT EXISTS user_actions (
  id SERIAL PRIMARY KEY,
  user_id TEXT REFERENCES users(id) ON DELETE SET NULL,
  action TEXT NOT NULL,
  entity TEXT,
  entity_id TEXT,
  payload JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS stoppages (
  id SERIAL PRIMARY KEY,
  row_index INTEGER,
  unit_id INTEGER REFERENCES units(id) ON DELETE SET NULL,
  line_id INTEGER REFERENCES lines(id) ON DELETE SET NULL,
  machine_id INTEGER REFERENCES machines(id) ON DELETE SET NULL,
  code TEXT,
  type TEXT,
  description TEXT,
  start_date TEXT,
  start_time TEXT,
  end_date TEXT,
  end_time TEXT,
  shift TEXT,
  status TEXT,
  created_by TEXT REFERENCES users(id) ON DELETE SET NULL,
  approved_by TEXT REFERENCES users(id) ON DELETE SET NULL
);
INSERT INTO units (name) VALUES ('سالن تولید رول کاغذ حرارتی') ON CONFLICT (name) DO NOTHING;
INSERT INTO units (name) VALUES ('سالن  تولید تجهیزات الکترونیکی') ON CONFLICT (name) DO NOTHING;
INSERT INTO units (name) VALUES ('زیر ساخت') ON CONFLICT (name) DO NOTHING;
INSERT INTO units (name) VALUES ('سالن تولید بردهای الکترونیکی') ON CONFLICT (name) DO NOTHING;
INSERT INTO units (name) VALUES ('سالن تزریق پلاستیک') ON CONFLICT (name) DO NOTHING;
INSERT INTO units (name) VALUES ('سالن مونتاژ بردهای الکترونیکی') ON CONFLICT (name) DO NOTHING;
INSERT INTO lines (name, unit_id)
VALUES (
  'سالن تولید رول کاغذ حرارتی',
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1)
) ON CONFLICT (name, unit_id) DO NOTHING;
INSERT INTO lines (name, unit_id)
VALUES (
  'سالن  تولید تجهیزات الکترونیکی',
  (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1)
) ON CONFLICT (name, unit_id) DO NOTHING;
INSERT INTO lines (name, unit_id)
VALUES (
  'زیر ساخت',
  (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1)
) ON CONFLICT (name, unit_id) DO NOTHING;
INSERT INTO lines (name, unit_id)
VALUES (
  'سالن تولید بردهای الکترونیکی',
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1)
) ON CONFLICT (name, unit_id) DO NOTHING;
INSERT INTO lines (name, unit_id)
VALUES (
  'سالن تزریق پلاستیک',
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1)
) ON CONFLICT (name, unit_id) DO NOTHING;
INSERT INTO users (id, name, username, password, role, unit)
VALUES (
  'usr1771320978048',
  'تست',
  'تست',
  '123',
  'operator',
  'واحد تولید ۱'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO users (id, name, username, password, role, unit)
VALUES (
  'usr6',
  'سعید حسینی',
  'admin',
  'admin123',
  'admin',
  'همه واحدها'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO users (id, name, username, password, role, unit)
VALUES (
  'usr3',
  'حسن محمدی',
  'supervisor',
  '123456',
  'supervisor',
  'واحد تولید ۱'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO users (id, name, username, password, role, unit)
VALUES (
  'usr4',
  'مهدی نوری',
  'inspector',
  '123456',
  'inspector',
  'واحد تولید ۱'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO users (id, name, username, password, role, unit)
VALUES (
  'usr1',
  'علی احمدی',
  'operator',
  '123456',
  'operator',
  'واحد تولید ۱'
) ON CONFLICT (id) DO NOTHING;
INSERT INTO permissions (key) VALUES ('stoppages:create') ON CONFLICT (key) DO NOTHING;
INSERT INTO permissions (key) VALUES ('dashboard:read') ON CONFLICT (key) DO NOTHING;
INSERT INTO permissions (key) VALUES ('stoppages:approve') ON CONFLICT (key) DO NOTHING;
INSERT INTO permissions (key) VALUES ('reports:read') ON CONFLICT (key) DO NOTHING;
INSERT INTO permissions (key) VALUES ('settings:manage') ON CONFLICT (key) DO NOTHING;
INSERT INTO permissions (key) VALUES ('users:manage') ON CONFLICT (key) DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr1771320978048',
  (SELECT id FROM permissions WHERE key = 'stoppages:create' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr6',
  (SELECT id FROM permissions WHERE key = 'dashboard:read' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr6',
  (SELECT id FROM permissions WHERE key = 'stoppages:create' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr6',
  (SELECT id FROM permissions WHERE key = 'stoppages:approve' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr6',
  (SELECT id FROM permissions WHERE key = 'reports:read' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr6',
  (SELECT id FROM permissions WHERE key = 'settings:manage' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr6',
  (SELECT id FROM permissions WHERE key = 'users:manage' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr3',
  (SELECT id FROM permissions WHERE key = 'dashboard:read' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr3',
  (SELECT id FROM permissions WHERE key = 'stoppages:create' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr3',
  (SELECT id FROM permissions WHERE key = 'stoppages:approve' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr3',
  (SELECT id FROM permissions WHERE key = 'reports:read' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr4',
  (SELECT id FROM permissions WHERE key = 'dashboard:read' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr4',
  (SELECT id FROM permissions WHERE key = 'stoppages:approve' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr4',
  (SELECT id FROM permissions WHERE key = 'reports:read' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO user_permissions (user_id, permission_id)
VALUES (
  'usr1',
  (SELECT id FROM permissions WHERE key = 'stoppages:create' LIMIT 1)
) ON CONFLICT DO NOTHING;
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-UL-01',
  'دستگاه تخلیه کننده',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-LD-01',
  'دستگاه بارگیر',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-PR-01',
  'دستگاه پرینتر',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-AS-01',
  'لحیم کاری هوا (Oven)',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-PP-01',
  'دستگاه قطعه گذاری',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-PP-02',
  'دستگاه قطعه گذاری',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-IV-01',
  'اینورتر سامسونگ',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-AS-01',
  'دوش هوا',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-IC-01',
  'کانوایر',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-CM-01',
  'سیستم تست برد الکترونیکی',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-TC-01',
  'سینی تغییردهنده',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-KN-01',
  'خمیرزن',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-RG-01',
  'یخچال',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-RG-02',
  'یخچال',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-ML-01',
  'بارگذار برد خام1',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-CN-02',
  'خط انتقال/نوار نقاله واسط2',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-VSP-01',
  'چاپگر چسب/خمیر قلع',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-IM-01',
  'ماشین بازرسی چسب/ خمیر قلع',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-CN-03',
  'خط انتقال/نوار نقاله واسط3',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-PP-03',
  'ماشین قطعه گذاری1',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-PP-04',
  'ماشین قطعه گذاری2',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-CN-04',
  'خط انتقال/نوار نقاله واسط4',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-AOI-01',
  'ماشین بازرسی اتوماتیک  برد1',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-RC-01',
  'خط انتقال/نوار نقاله تفکیک معیوبی1',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-PP-05',
  'ماشین قطعه گذاری3',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-TC-01',
  'ماشین تعویض سینی قطعات',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-IC-01',
  'خط انتقال/نوار نقاله بازرسی',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-NO-01',
  'ماشین لحیم کاری هوای داغ',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-NG-01',
  'دستگاه نیتروژن ساز',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-CN-05',
  'خط انتقال/نوار نقاله واسط5',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-SI-01',
  'ماشین بازرسی اتوماتیک  برد2',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-RC-02',
  'خط انتقال/نوار نقاله تفکیک معیوبی2',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-MU-01',
  'باربردار برد خام2',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-RL-01',
  'بارگذار حلقه ی قطعه1',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-UP-01',
  'منبع تغذیه بدون وقفه',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-MF-01',
  'دستگاه کاورکفش اتوماتیک',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-DM-01',
  'میکروسکوپ دیجیتالی',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-SC-01',
  'دستگاه کاورکفش اتوماتیک',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-EP-01',
  'تابلوبرق ایستاده  1',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-EP-02',
  'تابلوبرق ایستاده  2',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO machines (code, name, unit_id, line_id, mttr_base, mttr_target, mtbf_base, mtbf_target)
VALUES (
  'AB-EP-03',
  'تابلوبرق ایستاده 3',
  (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن مونتاژ بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن مونتاژ بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  0.2,
  24,
  360,
  720
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  1,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-01' LIMIT 1),
  'TR-CM-01',
  'حین تولید',
  'ثبت نشده',
  '1403/05/01',
  NULL,
  '1403/09/19',
  '19:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  2,
  (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن  تولید تجهیزات الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-GI-02' LIMIT 1),
  'EDP-GI-02',
  'حین تولید',
  'خرابی رله',
  '1403/07/17',
  NULL,
  '1403/07/17',
  '12:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  3,
  (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'زیر ساخت' AND unit_id = (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'SS-WC-01' LIMIT 1),
  'SS-WC-01',
  'حین تولید',
  'سوراخ شدن لوله گالوانیزه آب',
  '1403/08/08',
  NULL,
  '1403/08/08',
  '21:07',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  4,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-02' LIMIT 1),
  'TR-SH-02',
  'حین تولید',
  'خرابی گیربکس موتور به دلیل کمبود روغن',
  '1403/08/10',
  NULL,
  '1403/08/12',
  '09:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  5,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'خرابی گیربکس موتور به دلیل کمبود روغن',
  '1403/08/16',
  NULL,
  '1403/08/16',
  '17:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  6,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'برنامه ریزی شده',
  'استفاده از قطعه جهت دستگاهی دیگر',
  '1403/08/18',
  NULL,
  '1403/09/17',
  '17:53',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  7,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'شکستن شفت بادی',
  '1403/09/04',
  NULL,
  '1403/09/09',
  '15:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  8,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'ثبت نشده',
  '1403/09/05',
  NULL,
  '1403/09/18',
  '13:48',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  12,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'خرابی شفت ها فولی وچرخ دندها',
  '1403/09/14',
  NULL,
  '1403/09/17',
  '12:02',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  13,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-NG-01' LIMIT 1),
  'AB-NG-01',
  'حین تولید',
  'نامعلوم',
  '1403/09/14',
  NULL,
  '1403/09/14',
  '11:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  14,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-NO-01' LIMIT 1),
  'AB-NO-01',
  'حین تولید',
  'در حال بررسی مشکل با گراندیل',
  '1403/09/17',
  NULL,
  '1403/09/17',
  '11:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  15,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-TC-01' LIMIT 1),
  'AB-TC-01',
  'حین تولید',
  'نامعلوم - با چندبار روشن و خاموش کردن دستگاه مشکل برطرف شد',
  '1403/09/19',
  NULL,
  '1403/09/19',
  '02:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  16,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-TC-02' LIMIT 1),
  'AB-TC-02',
  'حین تولید',
  'ثبت نشده',
  '1403/09/19',
  NULL,
  '1403/09/19',
  '08:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  17,
  (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن  تولید تجهیزات الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'خرابی بلبرینگ شفت',
  '1403/09/26',
  NULL,
  '1403/09/27',
  '09:45',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  18,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-VSP-01' LIMIT 1),
  'AB-VSP-01',
  'حین تولید',
  'ازتنظیم خارج شدن سنسور',
  '1403/09/29',
  NULL,
  '1403/09/30',
  '01:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  19,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-TC-01' LIMIT 1),
  'AB-TC-01',
  'حین تولید',
  'نامعلوم- با ریست و جدا ووصل ماژول مشکل برطرف شد و هماهنگی لازم انجام شده جهت حضور شرکت گراندیل در 2آذر و رفع ایراد این دستگاه',
  '1403/09/30',
  NULL,
  '1403/09/30',
  '21:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  20,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-03' LIMIT 1),
  'AB-PP-03',
  'حین تولید',
  'شکستن یکی از نازل ماژول 1',
  '1403/10/03',
  NULL,
  '1403/10/03',
  '12:52',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  21,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-04' LIMIT 1),
  'AB-PP-04',
  'حین تولید',
  'هد دستگاه pick&place گیر کردن میل راهنمای یکی از نازل های هد ماژول 1',
  '1403/10/04',
  NULL,
  '1403/10/05',
  '11:27',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  22,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-04' LIMIT 1),
  'AB-PP-04',
  'حین تولید',
  'ما ژول 2 -مشکل هد دستگاه -یکی از نازل ها شکسته که باید تعویض بشه',
  '1403/10/09',
  NULL,
  '1403/10/10',
  '00:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  23,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-04' LIMIT 1),
  'AB-PP-04',
  'حین تولید',
  'ما ژول 2 -مشکل هد دستگاه',
  '1403/10/10',
  NULL,
  '1403/10/10',
  '02:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  24,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-04' LIMIT 1),
  'AB-PP-04',
  'حین تولید',
  'هولدر نازل دستگاه ۱ ماژول ۲ مشکل داشتن (یکی گیر داره، ۳ تا دوران موقعیت دارن) 
مشکل   رفع شد(با skip کردن هولدر های معیوب)',
  '1403/10/10',
  NULL,
  '1403/10/10',
  '15:47',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  25,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-AS-01' LIMIT 1),
  'AB-AS-01',
  'حین تولید',
  'مشکل در کانوایر و ریل آن',
  '1403/10/10',
  NULL,
  '1403/10/10',
  '15:48',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  26,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-04' LIMIT 1),
  'AB-PP-04',
  'حین تولید',
  'ما ژول 2 -مشکل هد دستگاه / با تعویض هد و‌کالیبره ی دستگاه مشکل حل شد',
  '1403/10/10',
  NULL,
  '1403/10/12',
  '14:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  27,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-05' LIMIT 1),
  'AB-PP-05',
  'حین تولید',
  'مشکل نرم افزاری دستگاه pick&place ماشین ۲ ماژول ۲-) کارت ماژول خراب شده بود، تهیه و پروگرم و‌جایگزین شد',
  '1403/10/18',
  NULL,
  '1403/10/19',
  '17:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  28,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'X2' LIMIT 1),
  'X2',
  'حین تولید',
  'آسیب دیدگی رویه قالب 9200',
  '1403/10/18',
  NULL,
  '1403/10/19',
  '16:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  29,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'X3' LIMIT 1),
  'X3',
  'حین تولید',
  'ثبت نشده',
  '1403/11/24',
  NULL,
  '1403/11/24',
  '12:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  30,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE name = 'قالب کفی 9200' LIMIT 1),
  NULL,
  'حین تولید',
  'گیر کردن کشویی 9200',
  '1403/11/24',
  NULL,
  '1403/11/25',
  '14:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  31,
  (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن  تولید تجهیزات الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'X5' LIMIT 1),
  'X5',
  'حین تولید',
  'خرابی کانوایر',
  '1403/11/27',
  NULL,
  '1403/11/27',
  '08:17',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  32,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'بریدن تسمه دستگاه برش',
  '1403/12/04',
  NULL,
  '1403/12/05',
  '01:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  33,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-02' LIMIT 1),
  'TR-SH-02',
  'حین تولید',
  'ثبت نشده',
  '1403/12/05',
  NULL,
  '1403/12/05',
  '15:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  34,
  (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن  تولید تجهیزات الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-CL-09' LIMIT 1),
  'EDP-CL-09',
  'حین تولید',
  'یک لامپ کانوایر 5 سوخته و باعث پریدن فیوز می شود',
  '1403/12/07',
  NULL,
  '1403/12/07',
  '13:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  35,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی بلبرینگ',
  '1403/12/07',
  NULL,
  '1403/12/07',
  '20:34',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  36,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-01' LIMIT 1),
  'TR-CM-01',
  'حین تولید',
  'توقف برش۱ به علت خرابی شفت فولی',
  '1403/12/08',
  NULL,
  '1403/12/08',
  '22:56',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  37,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-VSP-01' LIMIT 1),
  'AB-VSP-01',
  'حین تولید',
  'خرابی پرینتر (مشکل سنسور)',
  '1403/12/09',
  NULL,
  '1403/12/11',
  '19:07',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  38,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'تعویض شفت چرخ دندها',
  '1403/12/09',
  NULL,
  '1403/12/09',
  '21:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  39,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'پریدن تیغه ها',
  '1403/12/10',
  NULL,
  '1403/12/10',
  '13:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  40,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-NG-01' LIMIT 1),
  'AB-NG-01',
  'حین تولید',
  'بالا رفتن دمای کمپرسور هوا',
  '1403/12/11',
  NULL,
  '1403/12/12',
  '01:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  41,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'بالا رفتن دمای کمپرسور هوا',
  '1403/12/11',
  NULL,
  '1403/12/12',
  '01:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  42,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'بالا رفتن دمای کمپرسور هوا',
  '1403/12/11',
  NULL,
  '1403/12/12',
  '01:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  43,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'بالا رفتن دمای کمپرسور هوا',
  '1403/12/11',
  NULL,
  '1403/12/12',
  '01:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  44,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'بالا رفتن دمای کمپرسور هوا',
  '1403/12/12',
  NULL,
  '1403/12/12',
  '17:50',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  45,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'بالا رفتن دمای کمپرسور هوا',
  '1403/12/12',
  NULL,
  '1403/12/12',
  '17:50',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  46,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'بالا رفتن دمای کمپرسور هوا',
  '1403/12/12',
  NULL,
  '1403/12/12',
  '17:50',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  47,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-NG-01' LIMIT 1),
  'AB-NG-01',
  'حین تولید',
  'بالا رفتن دمای کمپرسور هوا',
  '1403/12/12',
  NULL,
  '1403/12/12',
  '17:55',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  48,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی بلبرینگ چرخ دنده دوبل و خرابی بلبرینگ چرخ دنده مورب',
  '1403/12/14',
  NULL,
  '1403/12/14',
  '15:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  49,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خرابی بلبرینگ شفت تیغه',
  '1403/12/15',
  NULL,
  '1403/12/15',
  '01:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  50,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-NG-01' LIMIT 1),
  'AB-NG-01',
  'حین تولید',
  'خرابی کمپرسور هوا',
  '1403/12/15',
  NULL,
  '1403/12/15',
  '08:26',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  51,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-IM-03' LIMIT 1),
  'PP-IM-03',
  'حین تولید',
  'مشکل  در قالب',
  '1403/12/15',
  NULL,
  '1403/12/16',
  '13:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  52,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'پارگی تسمه',
  '1403/12/16',
  NULL,
  '1403/12/16',
  '20:45',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  53,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی شفت رولر',
  '1403/12/18',
  NULL,
  '1403/12/18',
  '11:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  54,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'شکستگی تیغه کاتر- فعلا با این شرایط همچنان فعال است',
  '1403/12/20',
  NULL,
  '1403/12/21',
  '10:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  55,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'خرابی فولی وشفت فولی',
  '1403/12/22',
  NULL,
  '1403/12/22',
  '03:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  56,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خرابی رولربرش',
  '1403/12/25',
  NULL,
  '1403/12/25',
  '11:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  57,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'به علت قطعی سیم المنت تیغه برش نایلون',
  '1403/12/26',
  NULL,
  '1403/12/26',
  '14:21',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  58,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'به علت قطع شدن تسمه رولر',
  '1403/12/27',
  NULL,
  '1404/01/17',
  '15:13',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  59,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'تعویض تیغه تاکر',
  '1404/01/18',
  NULL,
  '1404/01/18',
  '11:39',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  60,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-IS-01' LIMIT 1),
  'PP-IS-01',
  'حین تولید',
  'خرابی اینسرت جای بند کفی 9200',
  '1404/01/20',
  NULL,
  '1404/01/31',
  '12:50',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  61,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'قطعی سیم شصتی استراری',
  '1404/01/21',
  NULL,
  '1404/01/21',
  '08:59',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  62,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'شکستگی بلبرینگ شفت تیغه',
  '1404/01/25',
  NULL,
  '1404/01/25',
  '19:01',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  63,
  (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن  تولید تجهیزات الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-04' LIMIT 1),
  'TR-SH-04',
  'حین تولید',
  'خرابی سنسور تشخیص ساعت',
  '1404/01/26',
  NULL,
  '1404/01/26',
  '10:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  64,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'قطع شدن پی در پی برق و پاره شدن کاغذ',
  '1404/01/26',
  NULL,
  '1404/01/26',
  '20:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  65,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'تعویض بلبرینگ',
  '1404/01/26',
  NULL,
  '1404/01/26',
  '20:35',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  66,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CV-01' LIMIT 1),
  'TR-CV-01',
  'حین تولید',
  'خرابی موتور کانوایر',
  '1404/01/27',
  NULL,
  '1404/01/27',
  '11:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  67,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خرابی رولر و نبود قطعه جایگزین',
  '1404/01/31',
  NULL,
  '1404/02/01',
  '16:59',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  68,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'خرابی رولر و نبود قطعه جایگزین',
  '1404/01/31',
  NULL,
  '1404/02/02',
  '16:08',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  69,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-01' LIMIT 1),
  'TR-CM-01',
  'حین تولید',
  'خرابی شفت فولی',
  '1404/01/31',
  NULL,
  '1404/02/02',
  '16:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  70,
  (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'زیر ساخت' AND unit_id = (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'SS-WC-01' LIMIT 1),
  'SS-WC-01',
  'حین تولید',
  'عدم چرخش آب چیلر',
  '1404/01/31',
  NULL,
  '1404/01/31',
  '16:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  71,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'توقف بر اثر احتراق کنتاکتور',
  '1404/02/02',
  NULL,
  '1404/02/03',
  '08:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  72,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'خرابی رولر شل بودن بیش از حد رول ها',
  '1404/02/03',
  NULL,
  '1404/02/06',
  '18:53',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  73,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خرابی رولر',
  '1404/02/06',
  NULL,
  '1404/02/07',
  '21:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  74,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'پارگی تسمه',
  '1404/02/10',
  NULL,
  '1404/02/10',
  '11:58',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  75,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'پارگی تسمه',
  '1404/02/10',
  NULL,
  '1404/02/10',
  '13:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  76,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی و شل بودن تسمه ها',
  '1404/02/10',
  NULL,
  '1404/02/10',
  '22:07',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  77,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'توقف در حین کار و جابجا کردن کنتاکت های کمکی',
  '1404/02/13',
  NULL,
  '1404/02/13',
  '08:43',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  78,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'خرابی سنسور القایی',
  '1404/02/14',
  NULL,
  '1404/02/14',
  '23:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  79,
  (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'زیر ساخت' AND unit_id = (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'LE-SE-01' LIMIT 1),
  'LE-SE-01',
  'حین تولید',
  'توقف دستگاه به دلیل قطعی مکرر برق',
  '1404/02/15',
  NULL,
  '1404/02/15',
  '00:33',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  80,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'یک لاین از کلید منیاتوری خراب شد',
  '1404/02/16',
  NULL,
  '1404/02/16',
  '09:08',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  81,
  (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن  تولید تجهیزات الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-CL-02' LIMIT 1),
  'EDP-CL-02',
  'حین تولید',
  'اتصال کوتا یکی از اداکتور ها',
  '1404/02/16',
  NULL,
  '1404/02/16',
  '14:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  82,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'خرابی جک نگهدارنده تیغه',
  '1404/02/19',
  NULL,
  '1404/02/19',
  '10:23',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  83,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'خرابی بلبرینگ 6006',
  '1404/02/20',
  NULL,
  '1404/02/20',
  '11:26',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  84,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خراب تسمه 450L',
  '1404/02/21',
  NULL,
  '1404/02/21',
  '08:46',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  85,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'تعویض غلطک هرز گرد کاغذ',
  '1404/02/21',
  NULL,
  '1404/02/21',
  '17:52',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  86,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خراب غلطک سیلیکونی',
  '1404/02/21',
  NULL,
  '1404/02/21',
  '20:06',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  87,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی سرشفت سیلندر جمع کن',
  '1404/02/22',
  NULL,
  '1404/02/22',
  '23:52',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  88,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-02' LIMIT 1),
  'TR-SH-02',
  'حین تولید',
  'به دلیل از جا در رفتن موتور کف از محل نصب خود',
  '1404/02/23',
  NULL,
  '1404/02/23',
  '16:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  89,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خرابی شفت فولی و بلبرینگ 6006',
  '1404/02/23',
  NULL,
  '1404/02/23',
  '19:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  90,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'جدا شدن سیم فرمان از رله plc',
  '1404/02/24',
  NULL,
  '1404/02/24',
  '12:45',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  91,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خرابی ولوم دستگاه',
  '1404/02/27',
  NULL,
  '1404/02/27',
  '18:28',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  92,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-02' LIMIT 1),
  'TR-SH-02',
  'حین تولید',
  'خرابی سنسور تیغه و لاستیک /راه اندازی موقت',
  '1404/02/30',
  NULL,
  '1404/02/30',
  '09:45',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  93,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-IC-01' LIMIT 1),
  'AB-IC-01',
  'حین تولید',
  'خرابی ریجکت کانوایر/بردهای داخل دستگاه با هدر متصل شده اند، احتمالا اتصالشون شل شده بوده',
  '1404/02/31',
  NULL,
  '1404/03/01',
  '08:31',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  94,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-RC-02' LIMIT 1),
  'AB-RC-02',
  'حین تولید',
  'شل شدن برد درون دستگاه',
  '1404/02/31',
  NULL,
  '1404/02/31',
  '21:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  95,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-02' LIMIT 1),
  'TR-SH-02',
  'حین تولید',
  'خرابی سنسور تیغه و لاستیک',
  '1404/03/01',
  NULL,
  '1404/03/01',
  '10:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  96,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-01' LIMIT 1),
  'TR-CM-01',
  'حین تولید',
  'به علت خرابی مغزی پرکن وعدم اتصال برق مغزی پرکن/راه اندازی برش۱ وتعمیر ونصب کابل برق دستگا',
  '1404/03/02',
  NULL,
  '1404/03/05',
  '00:16',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  97,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-02' LIMIT 1),
  'TR-SH-02',
  'حین تولید',
  'قطع شدن سنسور وخاموشی خط به صورت کامل',
  '1404/03/05',
  NULL,
  '1404/03/06',
  '08:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  98,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CV-01' LIMIT 1),
  'TR-CV-01',
  'حین تولید',
  'خرابی گیربکس/تعویض کامل الکتروموتور و گیربکس',
  '1404/03/06',
  NULL,
  '1404/03/06',
  '15:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  99,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'علت :خرابی سیلندر/ راه انداز ی موقت',
  '1404/03/06',
  NULL,
  '1404/03/06',
  '18:48',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  100,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'شفت بادی برش ۳ خراب است و باد خالی میکند /سوزن  تعویض شد',
  '1404/03/06',
  NULL,
  '1404/03/07',
  '18:51',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  101,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'بریدن پیچ جک تاکر /جک پنوماتیکی تاکر تعویض و کورس جک تنظیم شد',
  '1404/03/07',
  NULL,
  '1404/03/07',
  '15:45',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  102,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-01' LIMIT 1),
  'TR-CM-01',
  'حین تولید',
  'شل بودن رول -خرابی رولر/سفت کردن پیچ رولر',
  '1404/03/07',
  NULL,
  '1404/03/08',
  '18:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  103,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-NO-01' LIMIT 1),
  'AB-NO-01',
  'حین تولید',
  'علت خطایی 
conveyor width limit over',
  '1404/03/08',
  NULL,
  '1404/03/08',
  '10:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  104,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-RC-01' LIMIT 1),
  'AB-RC-01',
  'حین تولید',
  'علت خرابی قطعی سیم تغذیه dc',
  '1404/03/08',
  NULL,
  '1404/03/08',
  '08:26',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  105,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'رها شدن موتور مغزی پرکن توقف برش وخاموشی/جابجایی مغزی پرکن1و2',
  '1404/03/09',
  NULL,
  '1404/03/10',
  '10:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  106,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'خرابی کلید استارت/تعویض کلید استارت',
  '1404/03/10',
  NULL,
  '1404/03/10',
  '11:44',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  107,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی کلید استارت/تعویض کلید استارت',
  '1404/03/10',
  NULL,
  '1404/03/10',
  '12:04',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  108,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی فن میانچاپ',
  '1404/03/11',
  NULL,
  '1404/03/11',
  '11:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  109,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'بازکردن و نصب مجدد بعد از رفع ایراد از فن میانچاپ',
  '1404/03/11',
  NULL,
  '1404/03/11',
  '13:09',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  110,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'خرابی انکودر-تعویض انکودر از دستگاه5',
  '1404/03/11',
  NULL,
  '1404/03/11',
  '16:04',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  111,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی کلید بالابرنده رولر',
  '1404/03/13',
  NULL,
  '1404/03/13',
  '08:31',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  112,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'خرابی جک بوم',
  '1404/03/17',
  NULL,
  '1404/03/17',
  '10:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  113,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-01' LIMIT 1),
  'TR-CM-01',
  'حین تولید',
  'خرابی تیغه تاکر',
  '1404/03/17',
  NULL,
  '1404/03/17',
  '16:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  114,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'اتصال سیم های زیر شیرینگ',
  '1404/03/21',
  NULL,
  '1404/03/21',
  '10:13',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  115,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'تعویض سیلندر جمع کن دستگاه چاپ',
  '1404/03/21',
  NULL,
  '1404/03/21',
  '14:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  116,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'تعویض سیلندر جمع کن دستگاه چاپ',
  '1404/03/21',
  NULL,
  '1404/03/21',
  '19:18',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  117,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-DF-01' LIMIT 1),
  'PP-DF-01',
  'حین تولید',
  'پوسیدگی و نشتی کویته سه قالب سردریچه',
  '1404/03/21',
  NULL,
  '1404/03/22',
  '03:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  118,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-AS-01' LIMIT 1),
  'AB-AS-01',
  'حین تولید',
  'خرابی فن',
  '1404/03/21',
  NULL,
  '1404/03/22',
  '21:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  119,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'خارج شدن لیمیت سوییچ از تنظیم',
  '1404/03/24',
  NULL,
  '1404/03/24',
  '22:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  120,
  (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن  تولید تجهیزات الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'ریل دستگاه کوره شیرینک به صدا افتاده؛یازمنده گریس نسوز',
  '1404/03/26',
  NULL,
  '1404/03/26',
  '14:51',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  121,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'تویض برخی قطعات مکانیکی معیوب',
  '1404/03/25',
  NULL,
  '1404/03/27',
  '15:32',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  122,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی بلبرینگ قفلی',
  '1404/03/28',
  NULL,
  '1404/04/02',
  '15:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  123,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی کلید روشن و خاموش',
  '1404/04/07',
  NULL,
  '1404/04/07',
  '08:46',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  124,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CV-01' LIMIT 1),
  'TR-CV-01',
  'حین تولید',
  'خرابی در سیمکشی شصتی استوپ و خرابی خود استوپ در 3 قسمت',
  '1404/04/07',
  NULL,
  '1404/04/07',
  '18:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  125,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'توقف دستگاه برش ۲ شکستن چر خ دنده رولر',
  '1404/04/17',
  NULL,
  '1404/04/18',
  '11:12',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  126,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'شکسته شدن جک تیغه تاکر درساعت6:45 توقف برش4',
  '1404/04/18',
  NULL,
  '1404/04/18',
  '09:39',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  127,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-04' LIMIT 1),
  'AB-PP-04',
  'حین تولید',
  'خطای nozzle station دستگاه pick & place
خطای مذکور پس از سرویس انجام شده برطرف گردید',
  '1404/04/18',
  NULL,
  '1404/04/18',
  '08:50',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  128,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'بریدگی تسمه 600',
  '1404/04/18',
  NULL,
  '1404/04/18',
  '20:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  129,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'تعویض تیغه های برش',
  '1404/04/19',
  NULL,
  '1404/04/19',
  '04:58',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  130,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'پریدن تیغه های برش',
  '1404/04/23',
  NULL,
  '1404/04/23',
  '19:34',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  131,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-04' LIMIT 1),
  'AB-PP-04',
  'حین تولید',
  'خطا در قرار دادن قطعه دستگاه pick&place 
مشکل ذکر شده با اصلاح برنامه دستگاه برطرف شد',
  '1404/04/25',
  NULL,
  '1404/04/25',
  '18:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  132,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-NO-01' LIMIT 1),
  'AB-NO-01',
  'حین تولید',
  'توقف تولید به علت بالا بودن دمای FRONT ZONE',
  '1404/04/25',
  NULL,
  '1404/04/25',
  '07:22',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  133,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-NO-01' LIMIT 1),
  'AB-NO-01',
  'حین تولید',
  'به دلیل دمای بالای front zone',
  '1404/04/25',
  NULL,
  '1404/04/25',
  '14:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  134,
  (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'زیر ساخت' AND unit_id = (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'SS-WC-01' LIMIT 1),
  'SS-WC-01',
  'حین تولید',
  'ارور چیلر آب سرد و تعویض آب چیلر-خرابی رگولاتور فشار آب',
  '1404/04/28',
  NULL,
  '1404/04/28',
  '15:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  135,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CN-01' LIMIT 1),
  'TR-CN-01',
  'حین تولید',
  'شکستگی خط جدا کننده رول',
  '1404/04/29',
  NULL,
  '1404/04/29',
  '09:35',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  136,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'تعویض بوم دستگاه 4 به علت گشادشدن پایه جک63',
  '1404/05/01',
  NULL,
  '1404/05/01',
  '14:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  137,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'تعویض تاکر دستگاه برش 2',
  '1404/05/02',
  NULL,
  '1404/05/02',
  '08:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  138,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-DF-01' LIMIT 1),
  'PP-DF-01',
  'حین تولید',
  'خرابی و سوختن اتصال یکی از المنت های قالب سردریچه(این قالب برای فناپ نیست)',
  '1404/05/04',
  NULL,
  '1404/05/05',
  '13:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  139,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'شل شدن اتصالات به علت چکش زدن بر روی دستگاه',
  '1404/05/05',
  NULL,
  '1404/05/05',
  '11:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  140,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-DF-01' LIMIT 1),
  'PP-DF-01',
  'حین تولید',
  'خرابی المنت قالب',
  '1404/05/05',
  NULL,
  '1404/05/06',
  '13:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  141,
  (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'زیر ساخت' AND unit_id = (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'SS-WC-01' LIMIT 1),
  'SS-WC-01',
  'حین تولید',
  'خرابی چیلر اب',
  '1404/05/06',
  NULL,
  '1404/06/06',
  '17:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  142,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-01' LIMIT 1),
  'AB-PP-01',
  'حین تولید',
  'خطای افت فشار هوای نازل',
  '1404/05/06',
  NULL,
  '1404/05/06',
  '21:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  143,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-DF-01' LIMIT 1),
  'PP-DF-01',
  'حین تولید',
  'خرابی المنت قالب - تعویض المنت قالب سردریچه و فیوزهای هات رانر',
  '1404/05/05',
  NULL,
  '1404/05/06',
  '13:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  144,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'SS-CL-01' LIMIT 1),
  'SS-CL-01',
  'حین تولید',
  'خرابی چیلر آب سرد',
  '1404/05/06',
  NULL,
  '1404/05/06',
  '17:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  145,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-04' LIMIT 1),
  'AB-PP-04',
  'حین تولید',
  'خطای افت فشار هوای نازل -سرویس انجام شد و فعلا مشکل مرتفع شده',
  '1404/05/05',
  NULL,
  '1404/05/05',
  '21:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  146,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-SV-01' LIMIT 1),
  'AB-SV-01',
  'حین تولید',
  'قطع شدن سرور',
  '1404/05/06',
  NULL,
  '1404/05/06',
  '00:33',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  147,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-SV-01' LIMIT 1),
  'AB-SV-01',
  'حین تولید',
  'قطع شدن سرور',
  '1404/05/06',
  NULL,
  '1404/05/06',
  '14:02',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  148,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-SV-01' LIMIT 1),
  'AB-SV-01',
  'حین تولید',
  'قطع شدن سرور',
  '1404/05/06',
  NULL,
  '1404/05/06',
  '15:35',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  149,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-AOI-01' LIMIT 1),
  'AB-AOI-01',
  'حین تولید',
  'خطای دستگاه AOI- با نظر آقای غلام پور داخل دستگاه رو هوا گرفتن',
  '1404/05/08',
  NULL,
  '1404/05/08',
  '08:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  150,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-IM-04' LIMIT 1),
  'PP-IM-04',
  'حین تولید',
  'توقف دستگاه 4 بعلت خرابی سوکت هاترانر  سردریچه',
  '1404/05/09',
  NULL,
  '1404/05/09',
  '12:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  151,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-AOI-01' LIMIT 1),
  'AB-AOI-01',
  'حین تولید',
  'خطای دستگاه AOI - طبق آخرین صحبتی که با آقای غلام پور شدقرار بر این شد که اگر خطای مجدد رخ دهد باید pc دستگاه رو تمیز کاری کنیم',
  '1404/05/09',
  NULL,
  '1404/05/09',
  '10:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  152,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-02' LIMIT 1),
  'TR-SH-02',
  'حین تولید',
  'خرابی شفت',
  '1404/05/10',
  NULL,
  '1404/05/10',
  '16:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  153,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'ثبت نشده',
  '1404/05/11',
  NULL,
  '1404/05/11',
  '14:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  154,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'ثبت نشده',
  '1404/05/11',
  NULL,
  '1404/05/11',
  '15:55',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  155,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'قطع شدن سیم اتو',
  '1404/05/12',
  NULL,
  '1404/05/12',
  '00:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  156,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-03' LIMIT 1),
  'TR-SH-03',
  'حین تولید',
  'ثبت نشده',
  '1404/05/12',
  NULL,
  '1404/05/13',
  '09:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  157,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی تسمه مادر',
  '1404/05/15',
  NULL,
  '1404/05/19',
  '13:03',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  158,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'جهت تعمیر و تعویض اسپیسر',
  '1404/05/18',
  NULL,
  '1404/05/18',
  '09:51',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  159,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'تعویض غلطک آنیلوکس',
  '1404/05/18',
  NULL,
  '1404/05/18',
  '15:42',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  160,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی بلبرینگ رولر برش 4',
  '1404/05/19',
  NULL,
  '1404/05/19',
  '20:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  161,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'قطعی تسمه 450L',
  '1404/05/19',
  NULL,
  '1404/05/19',
  '13:03',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  162,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'پارگی تسمه 450L - دلیل آن گشاد شدن پایه نگه دارنده شفت چرخدنده تسمه',
  '1404/05/19',
  NULL,
  '1404/05/19',
  '16:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  163,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'SS-CL-01' LIMIT 1),
  'SS-CL-01',
  'برنامه ریزی شده',
  'تعویض رگولاتور اب چیلر',
  '1404/05/25',
  NULL,
  '1404/05/25',
  '09:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  164,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'از کار افتادن هیدرو موتوردستگاه',
  '1404/05/25',
  NULL,
  '1404/05/25',
  '09:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  165,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'بدلیل رطوبت بالای هوا اختلال در عملکرد تجهیزات',
  '1404/05/25',
  NULL,
  '1404/05/25',
  '09:47',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  166,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-02' LIMIT 1),
  'EDP-SH-02',
  'حین تولید',
  'خرابی میکروسوییچ',
  '1404/05/27',
  NULL,
  '1404/05/27',
  '13:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  167,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'خرابی میکروسوییچ',
  '1404/05/28',
  NULL,
  '1404/05/28',
  '09:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  168,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-02' LIMIT 1),
  'EDP-SH-02',
  'حین تولید',
  'ثبت نشده',
  '1404/05/29',
  NULL,
  '1404/05/29',
  '08:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  169,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-M0-01' LIMIT 1),
  'PP-M0-01',
  'حین تولید',
  'خرابی قالب',
  '1404/06/03',
  NULL,
  '1404/06/03',
  '14:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  170,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی کاسه نمد گیربکس موتور بالایی دستگاه چاپ ( روغن ریزی زیاد دارد وباعث میشود روی کاغذ ریخته شود)',
  '1404/06/03',
  NULL,
  '1404/06/05',
  '16:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  171,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-04' LIMIT 1),
  'TR-SH-04',
  'حین تولید',
  'ثبت نشده',
  '1404/06/05',
  NULL,
  '1404/06/05',
  '08:55',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  172,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-04' LIMIT 1),
  'TR-SH-04',
  'حین تولید',
  'ثبت نشده',
  '1404/06/05',
  NULL,
  '1404/06/05',
  '10:35',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  173,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'ثبت نشده',
  '1404/06/06',
  NULL,
  '1404/06/06',
  '11:26',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  174,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-02' LIMIT 1),
  'TR-SH-02',
  'حین تولید',
  'ثبت نشده',
  '1404/06/08',
  NULL,
  '1404/06/08',
  '08:31',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  175,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'ثبت نشده',
  '1404/06/08',
  NULL,
  '1404/06/08',
  '14:45',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  176,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی بلبرینگ قفلی 35 واحد چاپ3',
  '1404/06/09',
  NULL,
  '1404/06/09',
  '11:55',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  177,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-VSP-01' LIMIT 1),
  'AB-VSP-01',
  'حین تولید',
  'توقف دستگاه پرینتر به دلیل خطای mask y2',
  '1404/06/11',
  NULL,
  '1404/06/11',
  '09:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  178,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-03' LIMIT 1),
  'EDP-SH-03',
  'حین تولید',
  'خرابی پایه تیغه شرینک',
  '1404/06/11',
  NULL,
  '1404/07/12',
  '10:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  179,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'خرابی شیر باد جک شیرینگ',
  '1404/06/17',
  NULL,
  '1404/06/17',
  '22:48',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  180,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'خرابی جک نگهدارنده رول',
  '1404/06/18',
  NULL,
  '1404/06/18',
  '11:35',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  181,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-VSP-01' LIMIT 1),
  'AB-VSP-01',
  'حین تولید',
  'توقف تولید به مدت ۳۰ دقیقه، 
علت بررسی مشکل کلینر دستگاه پرینتر، 
مشکل در عدم پاشش الکل با فشار جهت تمیز کاری استنسیل می باشد.
طبق مشورت با شرکت گراندیل و بررسی های  صورت گرفته، به احتمال زیاد فشار پمپ کاهش پیدا کرده است',
  '1404/06/19',
  NULL,
  '1404/06/19',
  '09:50',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  182,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-M0-01' LIMIT 1),
  'PP-M0-01',
  'حین تولید',
  'بریدن پیچ نگهدارنده پین قالب در قیمت راهگاه',
  '1404/06/23',
  NULL,
  '1404/06/23',
  '21:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  183,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-03' LIMIT 1),
  'TR-SH-03',
  'حین تولید',
  'ثبت نشده',
  '1404/06/24',
  NULL,
  '1404/06/24',
  '16:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  184,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-M0-01' LIMIT 1),
  'PP-M0-01',
  'حین تولید',
  'خرابی پران قالب',
  '1404/06/24',
  NULL,
  '1404/06/24',
  '10:55',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  185,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی شفت بادی - با تعویض شفت بادی مشکل برطرف شد',
  '1404/06/24',
  NULL,
  '1404/06/24',
  '19:08',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  186,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'هرز بودن جای پیچ والف باد',
  '1404/06/24',
  NULL,
  '1404/06/25',
  '00:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  187,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'شکستن چرخ دنده شفت بادی',
  '1404/06/26',
  NULL,
  '1404/06/26',
  '20:58',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  188,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-01' LIMIT 1),
  'AB-PP-01',
  'حین تولید',
  'خرابی کانکتور اسپ موتور',
  '1404/06/27',
  NULL,
  '1404/06/27',
  '11:25',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  189,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-03' LIMIT 1),
  'TR-SH-03',
  'حین تولید',
  'خرابی کنترل فاز',
  '1404/06/27',
  NULL,
  '1404/06/27',
  '10:17',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  190,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی شفت بادی',
  '1404/06/27',
  NULL,
  '1404/06/27',
  '15:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  191,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'بریدن تسمه رولر',
  '1404/06/27',
  NULL,
  '1404/06/27',
  '17:45',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  192,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'ثبت نشده',
  '1404/06/28',
  NULL,
  '1404/06/28',
  '10:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  193,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-03' LIMIT 1),
  'AB-PP-03',
  'حین تولید',
  'دلیل نشتی هوا کلمپ هد
با تعویض اورینگ',
  '1404/06/30',
  NULL,
  '1404/06/30',
  '08:46',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  194,
  (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن  تولید تجهیزات الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن  تولید تجهیزات الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی استارت',
  '1404/07/01',
  NULL,
  '1404/07/01',
  '20:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  195,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'خرابی برق تیغه  و سپس خرابی ریل تیغه و عدم موجودی (سفارش خرید دارد) جهت جهت جایگزینی',
  '1404/07/02',
  NULL,
  '1404/07/03',
  '11:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  196,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-M0-01' LIMIT 1),
  'PP-M0-01',
  'حین تولید',
  'شکستن پین پران قالب رویه مودم ONT',
  '1404/07/03',
  NULL,
  '1404/07/04',
  '14:55',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  197,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'خرابی سنسور نوری کانوایر متصل به شرینک',
  '1404/07/05',
  NULL,
  '1404/07/05',
  '20:58',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  198,
  (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'زیر ساخت' AND unit_id = (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'SS-WC-01' LIMIT 1),
  'SS-WC-01',
  'حین تولید',
  'سوراخ شدن لوله گالوانیزه آب',
  '1404/07/05',
  NULL,
  '1404/07/05',
  '23:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  199,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-M0-01' LIMIT 1),
  'PP-M0-01',
  'حین تولید',
  'شکستن پین پران قالب رویه مودم ONT',
  '1404/07/07',
  NULL,
  '1404/07/07',
  '12:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  200,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-M0-01' LIMIT 1),
  'PP-M0-01',
  'حین تولید',
  'شکستن پین پران قالب رویه مودم ONT - ارسال به تهران جهت تعمیر',
  '1404/07/09',
  NULL,
  '1404/10/02',
  '10:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  201,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی بلبرینگ شفت رولر',
  '1404/07/10',
  NULL,
  '1404/07/10',
  '20:35',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  202,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی سوزن شفت بادی',
  '1404/07/11',
  NULL,
  '1404/07/11',
  '13:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  203,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خرابی دکمه استارت',
  '1404/07/14',
  NULL,
  '1404/07/14',
  '10:12',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  204,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'خرابی سنسور  تیغه',
  '1404/07/14',
  NULL,
  '1404/07/14',
  '10:51',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  205,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'EDP-SH-01' LIMIT 1),
  'EDP-SH-01',
  'حین تولید',
  'د
لیمیت سویچ رو از دستگاه جدا کردیم و سنسور پراکسی میتی جایگزین شد',
  '1404/07/14',
  NULL,
  '1404/07/14',
  '10:58',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  206,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-03' LIMIT 1),
  'TR-SH-03',
  'حین تولید',
  'ثبت نشده',
  '1404/07/15',
  NULL,
  '1404/07/15',
  '12:57',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  207,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'خرابی رولر',
  '1404/07/16',
  NULL,
  '1404/07/16',
  '09:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  208,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی شفت فولی مادر',
  '1404/07/16',
  NULL,
  '1404/07/16',
  '09:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  209,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی روکش گریپ',
  '1404/07/17',
  NULL,
  '1404/07/17',
  '11:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  210,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی بلبرینگ و شفت رولر',
  '1404/07/17',
  NULL,
  '1404/07/17',
  '14:25',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  211,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'ثبت نشده',
  '1404/07/19',
  NULL,
  '1404/07/19',
  '13:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  212,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی زنجیر و خورشیدی ها',
  '1404/7/20',
  NULL,
  '1404/07/20',
  '13:54',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  213,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'خرابی زنجیر و خورشیدی ها',
  '1404/7/20',
  NULL,
  '1404/07/20',
  '15:50',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  214,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-02' LIMIT 1),
  'TR-SH-02',
  'حین تولید',
  'ثبت نشده',
  '1404/07/24',
  NULL,
  '1404/07/24',
  '11:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  215,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'ثبت نشده',
  '1404/07/26',
  NULL,
  '1404/07/26',
  '09:16',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  216,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'تعویض تیغه های برش و بلبرینگهای شفت چرخ دنده اتصال کابل های کنترل تیشن',
  '1404/07/28',
  NULL,
  '1404/07/28',
  '14:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  217,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خرابی تیغه  های فرمان و رله ها',
  '1404/07/29',
  NULL,
  '1404/07/29',
  '12:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  218,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'علت خرابی عدم برش صحیح تیغه ها',
  '1404/07/30',
  NULL,
  '1404/07/30',
  '18:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  219,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'شکسته شدن خار و چرخ دنده رولر وپاره شدن تسمه',
  '1404/08/01',
  NULL,
  '1404/08/01',
  '16:45',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  220,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'مشکل برقی.سیم های فرمان و تیغه های فرمان (کلید سلکتوری)',
  '1404/08/01',
  NULL,
  '1404/08/03',
  '09:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  221,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'جابجایی گیربکس',
  '1404/08/02',
  NULL,
  '1404/08/03',
  '13:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  222,
  (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'زیر ساخت' AND unit_id = (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-EP-01' LIMIT 1),
  'PP-EP-01',
  'حین تولید',
  'تنظیمات کنترل فاز',
  '1404/08/04',
  NULL,
  '1404/08/04',
  '08:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  223,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-BF-03' LIMIT 1),
  'TR-BF-03',
  'حین تولید',
  'ثبت نشده',
  '1404/08/04',
  NULL,
  '1404/08/04',
  '08:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  224,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی رولر دستگاه',
  '1404/08/04',
  NULL,
  '1404/08/04',
  '10:14',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  225,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'ثبت نشده',
  '1404/08/4',
  NULL,
  '1404/0804',
  '23:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  226,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی رولر',
  '1404/08/5',
  NULL,
  '1404/08/05',
  '09:35',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  227,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی رولر',
  '1404/08/5',
  NULL,
  '1404/08/05',
  '11:23',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  228,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'در رفتن زنجیر',
  '1404/08/05',
  NULL,
  '1404/08/05',
  '16:50',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  229,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-AOI-01' LIMIT 1),
  'AB-AOI-01',
  'حین تولید',
  'خطای ارتباط روشنایی',
  '1404/08/06',
  NULL,
  '1404/08/06',
  '18:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  230,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'برق(خرابی رله فرمان و تیغه استارت)',
  '1404/08/07',
  NULL,
  '1404/08/07',
  '18:11',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  231,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'ثبت نشده',
  '1404/08/07',
  NULL,
  '1404/08/07',
  '18:42',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  232,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'خرابی جک دپو',
  '1404/08/10',
  NULL,
  '1404/08/10',
  '15:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  233,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'بردن تسمه چرخدنده',
  '1404/08/11',
  NULL,
  '1404/08/11',
  '11:16',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  234,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'خرابی جک دپو',
  '1404/08/11',
  NULL,
  '1404/08/11',
  '11:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  235,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'نبود فنر  کشی',
  '1404/08/11',
  NULL,
  '1404/08/11',
  '14:10',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  236,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'تعویض تیغه های استارت .کلید سلکتوری.سیمهای فرمان',
  '1404/08/11',
  NULL,
  '1404/08/11',
  '17:45',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  237,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-AOI-01' LIMIT 1),
  'AB-AOI-01',
  'حین تولید',
  'خطای ارتباطی با روشنایی',
  '1404/08/11',
  NULL,
  '1404/08/11',
  '21:35',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  238,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TH-WS-01' LIMIT 1),
  'TH-WS-01',
  'حین تولید',
  'خطای دستگاه فلکس',
  '1404/08/12',
  NULL,
  '1404/08/13',
  '08:50',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  239,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'ثبت نشده',
  '1404/08/12',
  NULL,
  '1404/08/12',
  '19:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  240,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'خرابی تیغه',
  '1404/08/12',
  NULL,
  '1404/08/12',
  '23:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  241,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'قطع شدن کابل المنت',
  '1404/08/13',
  NULL,
  '1404/08/13',
  '02:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  242,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'کمبود دما',
  '1404/08/13',
  NULL,
  '1404/08/13',
  '09:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  243,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'تیغه های فرمان',
  '1404/08/13',
  NULL,
  '1404/08/13',
  '08:55',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  244,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'رها شدن تسمه چرخ دنده شفت اسپیسر و شفت سلیکونی',
  '1404/08/14',
  NULL,
  '1404/08/14',
  '09:12',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  245,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-BF-03' LIMIT 1),
  'TR-BF-03',
  'حین تولید',
  'پیچ بین بدنه و صفحه درگیر شده بود
که باعث توقف الکتروموتور میشد',
  '1404/08/15',
  NULL,
  '1404/08/15',
  '10:55',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  246,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'روغن ریزی دینام خط کانوایر',
  '1404/08/17',
  NULL,
  '1404/08/17',
  '08:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  247,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'ثبت نشده',
  '1404/08/17',
  NULL,
  '1404/08/17',
  '12:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  248,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-TP-01' LIMIT 1),
  'PP-TP-01',
  'حین تولید',
  'لوله کشی',
  '1404/08/17',
  NULL,
  '1404/08/17',
  '12:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  249,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'تعویض جک پنوماتیک قلمی',
  '1404/08/18',
  NULL,
  '1404/08/18',
  '18:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  250,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-01' LIMIT 1),
  'AB-PP-01',
  'حین تولید',
  'توقف دستگاه p&p به دلیل خطای هولدر نازل',
  '1404/08/19',
  NULL,
  '1404/08/19',
  '19:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  251,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خرابی مغزی پرکن',
  '1404/08/19',
  NULL,
  '1404/08/20',
  '12:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  252,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-01' LIMIT 1),
  'AB-PP-01',
  'حین تولید',
  'توقف تولید از ساعت ۹ به علت خرابی ماژول یک دستگاه قطعه گذار',
  '1404/08/20',
  NULL,
  '1404/08/20',
  '09:45',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  253,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'اشکال در ترموستات',
  '1404/08/20',
  NULL,
  '1404/08/20',
  '20:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  254,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'اشکال در ترموستات',
  '1404/08/21',
  NULL,
  '1404/08/21',
  '14:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  255,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TH-WS-01' LIMIT 1),
  'TH-WS-01',
  'حین تولید',
  'اشکال در نازل',
  '1404/08/21',
  NULL,
  '1404/08/21',
  '18:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  256,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-PD-01' LIMIT 1),
  'PP-PD-01',
  'حین تولید',
  'آسیب دیدگی پران قالب درب پرینتر 9200',
  '1404/08/21',
  NULL,
  '1404/08/22',
  '08:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  257,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی جک تاکر',
  '1404/08/26',
  NULL,
  '1404/08/26',
  '10:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  258,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'خرابی سنسور چشمی',
  '1404/08/26',
  NULL,
  '1404/08/26',
  '11:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  259,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-02' LIMIT 1),
  'TR-SH-02',
  'حین تولید',
  'خرابی سنسور و تیغه دوخت پلاستیک',
  '1404/08/27',
  NULL,
  '1404/08/28',
  '08:34',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  260,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خرابی رولر',
  '1404/08/28',
  NULL,
  '1404/08/28',
  '11:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  261,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-BF-03' LIMIT 1),
  'TR-BF-03',
  'حین تولید',
  'ثبت نشده',
  '1404/09/05',
  NULL,
  '1404/09/05',
  '20:18',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  262,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'قطع شدن سیم المنت شیرینگ رول',
  '1404/09/06',
  NULL,
  '1404/09/06',
  '23:35',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  263,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی چرخ دنده تنشن و چرخ دنده شفت بادی',
  '1404/09/08',
  NULL,
  '1404/09/08',
  '11:05',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  264,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-PP-01' LIMIT 1),
  'AB-PP-01',
  'حین تولید',
  'تعویض باتری و کالیبره هد ماژول ۵ دستگاه pick & place',
  '1404/09/09',
  NULL,
  '1404/09/09',
  '10:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  265,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی چرخ دنده - تعویض دو چرخدنده خراب شفت بادی',
  '1404/09/09',
  NULL,
  '1404/09/09',
  '19:20',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  266,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'از کار افتادن دکمه استارت',
  '1404/09/11',
  NULL,
  '1404/09/11',
  '08:21',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  264,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-IS-08' LIMIT 1),
  'PP-IS-08',
  'حین تولید',
  'بریدگی  پیچ اسپیرو',
  '1404/09/12',
  NULL,
  '1404/09/12',
  '08:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  267,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-IS-08' LIMIT 1),
  'PP-IS-08',
  'حین تولید',
  'بریدگی  پیچ اسپیرو',
  '1404/09/12',
  NULL,
  '1404/09/12',
  '08:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  268,
  (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید بردهای الکترونیکی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید بردهای الکترونیکی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'AB-AOI-01' LIMIT 1),
  'AB-AOI-01',
  'حین تولید',
  'ثبت نشده',
  '1404/09/15',
  NULL,
  '1404/10/15',
  '11:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  269,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-BF-03' LIMIT 1),
  'TR-BF-03',
  'حین تولید',
  'ثبت نشده',
  '1404/09/16',
  NULL,
  '1404/10/17',
  '08:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  270,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-IM-01' LIMIT 1),
  'PP-IM-01',
  'حین تولید',
  'ایراد در عملکرد PLC- باتعویض فلت ارتباطی مشکل حل شد',
  '1404/09/17',
  NULL,
  '1404/10/20',
  '09:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  271,
  (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تزریق پلاستیک' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تزریق پلاستیک' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-IS-10' LIMIT 1),
  'PP-IS-10',
  'حین تولید',
  'شکستن پین قالب top cat4',
  '1404/09/23',
  NULL,
  '1404/10/23',
  '20:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  272,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'توقف گیربکس',
  '1404/09/19',
  NULL,
  '1404/10/19',
  '08:39',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  273,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'تعویض فولی.شفت فولی.بلبرینگ های شفت وتسمه ۴۵۰L',
  '1404/09/19',
  NULL,
  '1404/10/19',
  '12:25',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  274,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'تعویض فولی اصلی به همراه شفت و۲ عدد بلبرینگ
تعویض بلبرینگ های شفت چرخ دنده 
تعویض بلبرینگ های چرخنده تسمه ۶۰۰
تنظیم جک بالا بر رول',
  '1404/09/25',
  NULL,
  '1404/09/25',
  '17:59',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  275,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'باز شدن رولر',
  '1404/10/07',
  NULL,
  '1404/10/07',
  '18:59',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  276,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'تعویض زنجیر جمع کن',
  '1404/10/09',
  NULL,
  '1404/10/09',
  '19:59',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  277,
  (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'زیر ساخت' AND unit_id = (SELECT id FROM units WHERE name = 'زیر ساخت' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-AC-02' LIMIT 1),
  'TR-AC-02',
  'حین تولید',
  'تنظیم نبودن کمپرسور متناسب با تولید سالن smt',
  '1404/10/10',
  NULL,
  '1404/10/10',
  '07:50',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  278,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی رولر',
  '1404/10/10',
  NULL,
  '1404/10/10',
  '11:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  279,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'خرابی سنسور',
  '1404/10/17',
  NULL,
  '1404/10/17',
  '12:55',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  280,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-SH-01' LIMIT 1),
  'TR-SH-01',
  'حین تولید',
  'علت روغن ریزی .خارج شدن کاسه نمد از روی گیربکس',
  '1404/10/18',
  NULL,
  '1404/10/18',
  '11:07',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  281,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'قطع شدن تسمه 600L',
  '1404/11/01',
  NULL,
  '1404/11/01',
  '19:42',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  282,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'رفع توقف رولر با تعویض شفت فولی، بلبرینگ ها ورولر وچرخ دنده تسمه',
  '1404/11/02',
  NULL,
  '1404/11/02',
  '16:18',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  282,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خرابی تیغه های بالا و پایین',
  '1404/11/02',
  NULL,
  '1404/11/02',
  '18:55',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  282,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'پارگی تسمه رولر / تعویض تسمه و تنظیم رولر',
  '1404/11/04',
  NULL,
  '1404/11/04',
  '16:26',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  282,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-03' LIMIT 1),
  'TR-CM-03',
  'حین تولید',
  'پاره شدن تسمه رولر- تسمه600L',
  '1404/11/04',
  NULL,
  '1404/11/04',
  '16:26',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  282,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-BF-02' LIMIT 1),
  'TR-BF-02',
  'حین تولید',
  'شکسته شدت صفحه فلزی دوار',
  '1404/11/07',
  NULL,
  '1404/11/07',
  '16:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  282,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-BF-03' LIMIT 1),
  'TR-BF-03',
  'حین تولید',
  'دو فاز شدن موتور  کفی مغزی پرکن',
  '1404/11/08',
  NULL,
  '1404/11/08',
  '10:15',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  282,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-02' LIMIT 1),
  'TR-CM-02',
  'حین تولید',
  'خرابی سوزن شفت بادی',
  '1404/11/09',
  NULL,
  '1404/11/09',
  '15:00',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  282,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-PM-02' LIMIT 1),
  'TR-PM-02',
  'حین تولید',
  'بریده شدن پیچ شفت بادی',
  '1404/11/11',
  NULL,
  '1404/11/11',
  '20:42',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  282,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'PP-IS-08' LIMIT 1),
  'PP-IS-08',
  'حین تولید',
  'شکستن پران قالب btm cat4',
  '1404/11/13',
  NULL,
  '1404/11/14',
  '15:24',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  282,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'قطع شدن تسمه ۶۰۰L',
  '1404/11/14',
  NULL,
  '1404/11/14',
  '20:40',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
INSERT INTO stoppages (row_index, unit_id, line_id, machine_id, code, type, description, start_date, start_time, end_date, end_time, shift, status, created_by, approved_by)
VALUES (
  282,
  (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1),
  (SELECT id FROM lines WHERE name = 'سالن تولید رول کاغذ حرارتی' AND unit_id = (SELECT id FROM units WHERE name = 'سالن تولید رول کاغذ حرارتی' LIMIT 1) LIMIT 1),
  (SELECT id FROM machines WHERE code = 'TR-CM-04' LIMIT 1),
  'TR-CM-04',
  'حین تولید',
  'خرابی دکمه استارت - ایراد در کانکشن ارتباطی',
  '1404/11/16',
  NULL,
  '1404/11/17',
  '16:30',
  'نامشخص',
  'approved',
  NULL,
  NULL
);
COMMIT;
