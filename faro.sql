-- =============================================
-- سیستەمی بەڕێوەبردنی ناوەرۆک (CMS)
-- هەموو پێکهاتەکان لە یەک فایلی SQL دا
-- Created by: Kurdish AI Assistant
-- =============================================

-- 1. دروستکردنی داتابەیس
DROP DATABASE IF EXISTS kurdish_cms;
CREATE DATABASE kurdish_cms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE kurdish_cms;

-- =============================================
-- خشتەی بەکارهێنەران
-- =============================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'editor', 'author', 'subscriber') DEFAULT 'subscriber',
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    avatar_url VARCHAR(255),
    bio TEXT,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- خشتەی بەشی ناوەرۆک
-- =============================================
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE CASCADE,
    INDEX idx_slug (slug),
    INDEX idx_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- خشتەی بابەتەکان (پۆستەکان)
-- =============================================
CREATE TABLE posts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    excerpt TEXT,
    content LONGTEXT NOT NULL,
    author_id INT NOT NULL,
    status ENUM('draft', 'published', 'archived') DEFAULT 'draft',
    featured_image VARCHAR(255),
    views_count INT DEFAULT 0,
    comment_status ENUM('open', 'closed') DEFAULT 'open',
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_slug (slug),
    INDEX idx_status (status),
    INDEX idx_author (author_id),
    INDEX idx_published (published_at),
    FULLTEXT idx_search (title, content, excerpt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- خشتەی پەیوەندی بابەت و بەش
-- =============================================
CREATE TABLE post_categories (
    post_id INT NOT NULL,
    category_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (post_id, category_id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    INDEX idx_category (category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- خشتەی تاگەکان
-- =============================================
CREATE TABLE tags (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- خشتەی پەیوەندی بابەت و تاگ
-- =============================================
CREATE TABLE post_tags (
    post_id INT NOT NULL,
    tag_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (post_id, tag_id),
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE,
    INDEX idx_tag (tag_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================
-- خشتەی کۆمێنتەکان
-- =============================================
CREATE TABLE comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT NOT NULL,
    user_id INT NULL,
    parent_id INT NULL,
    author_name VARCHAR(100),
    author_email VARCHAR(100),
    author_ip VARCHAR(45),
    content TEXT NOT NULL,
    status ENUM('approved', 'pending', 'spam') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE,
    INDEX idx_post (post_id),
    INDEX idx_status (status),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- خشتەی فایڵەکان (میدیا)
-- =============================================
CREATE TABLE media (
    id INT PRIMARY KEY AUTO_INCREMENT,
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255),
    mime_type VARCHAR(100),
    file_size INT,
    file_path VARCHAR(500) NOT NULL,
    uploaded_by INT NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    alt_text VARCHAR(255),
    description TEXT,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_uploaded_by (uploaded_by),
    INDEX idx_mime_type (mime_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- خشتەی ڕێکخستنەکان
-- =============================================
CREATE TABLE settings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type ENUM('text', 'number', 'boolean', 'json', 'html') DEFAULT 'text',
    category VARCHAR(50) DEFAULT 'general',
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_key (setting_key),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- خشتەی لاگی کردارەکان
-- =============================================
CREATE TABLE activity_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    action VARCHAR(100) NOT NULL,
    description TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_action (action),
    INDEX idx_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- دروستکردنی تریجەرەکان
-- =============================================
DELIMITER $$

-- ترێجەری لاگی چاکسازی بابەتەکان
CREATE TRIGGER log_post_update
AFTER UPDATE ON posts
FOR EACH ROW
BEGIN
    INSERT INTO activity_logs (user_id, action, description)
    VALUES (
        NEW.author_id,
        'post_updated',
        CONCAT('Post "', NEW.title, '" was updated')
    );
END$$

-- ترێجەری زیادکردنی بینەر
CREATE TRIGGER increment_post_views
AFTER INSERT ON activity_logs
FOR EACH ROW
BEGIN
    IF NEW.action = 'post_viewed' THEN
        UPDATE posts 
        SET views_count = views_count + 1 
        WHERE id = NEW.description;
    END IF;
END$$

-- ترێجەری خۆکارسازی تازەکاری updated_at
CREATE TRIGGER update_post_timestamp
BEFORE UPDATE ON posts
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END$$

DELIMITER ;

-- =============================================
-- دروستکردنی پرۆسیدژەرەکان
-- =============================================
DELIMITER $$

-- پرۆسیدژەری گەڕان بە دوای بابەتەکان
CREATE PROCEDURE search_posts(
    IN search_query TEXT,
    IN category_id INT,
    IN tag_id INT,
    IN status_filter VARCHAR(20)
)
BEGIN
    SELECT 
        p.*,
        u.username as author_name,
        GROUP_CONCAT(DISTINCT c.name) as categories,
        GROUP_CONCAT(DISTINCT t.name) as tags
    FROM posts p
    LEFT JOIN users u ON p.author_id = u.id
    LEFT JOIN post_categories pc ON p.id = pc.post_id
    LEFT JOIN categories c ON pc.category_id = c.id
    LEFT JOIN post_tags pt ON p.id = pt.post_id
    LEFT JOIN tags t ON pt.tag_id = t.id
    WHERE 
        (search_query IS NULL OR MATCH(p.title, p.content, p.excerpt) AGAINST(search_query IN NATURAL LANGUAGE MODE))
        AND (category_id IS NULL OR c.id = category_id)
        AND (tag_id IS NULL OR t.id = tag_id)
        AND (status_filter IS NULL OR p.status = status_filter)
    GROUP BY p.id
    ORDER BY p.published_at DESC;
END$$

-- پرۆسیدژەری کۆکردنەوەی ئامارەکان
CREATE PROCEDURE get_statistics()
BEGIN
    DECLARE total_posts INT;
    DECLARE total_users INT;
    DECLARE total_comments INT;
    DECLARE today_posts INT;
    
    SELECT COUNT(*) INTO total_posts FROM posts WHERE status = 'published';
    SELECT COUNT(*) INTO total_users FROM users WHERE status = 'active';
    SELECT COUNT(*) INTO total_comments FROM comments WHERE status = 'approved';
    SELECT COUNT(*) INTO today_posts FROM posts 
    WHERE DATE(created_at) = CURDATE();
    
    SELECT 
        total_posts,
        total_users,
        total_comments,
        today_posts,
        (SELECT COUNT(*) FROM categories) as total_categories,
        (SELECT SUM(views_count) FROM posts) as total_views;
END$$

-- پرۆسیدژەری زیادکردنی بەکارهێنەرێکی نوێ
CREATE PROCEDURE create_user(
    IN p_username VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_email VARCHAR(100),
    IN p_full_name VARCHAR(100),
    IN p_role VARCHAR(20)
)
BEGIN
    DECLARE hashed_password VARCHAR(255);
    
    -- لە ڕاستیدا ئێرە پێویستە هەشکردنی وشەی نهێنی تێدا بکرێت
    SET hashed_password = SHA2(p_password, 256);
    
    INSERT INTO users (username, password_hash, email, full_name, role)
    VALUES (p_username, hashed_password, p_email, p_full_name, p_role);
    
    SELECT LAST_INSERT_ID() as new_user_id;
END$$

DELIMITER ;

-- =============================================
-- دروستکردنی فەنکشنەکان
-- =============================================
DELIMITER $$

-- فەنکشنی وەرگرتنی ناوی تەواوی بەکارهێنەر
CREATE FUNCTION get_user_full_name(user_id INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE full_name VARCHAR(100);
    SELECT users.full_name INTO full_name FROM users WHERE id = user_id;
    RETURN full_name;
END$$

-- فەنکشنی کورتکردنەوەی ناوەرۆک
CREATE FUNCTION truncate_text(text_content TEXT, max_length INT)
RETURNS VARCHAR(500)
DETERMINISTIC
BEGIN
    IF LENGTH(text_content) <= max_length THEN
        RETURN text_content;
    ELSE
        RETURN CONCAT(SUBSTRING(text_content, 1, max_length), '...');
    END IF;
END$$

-- فەنکشنی ئاسانکردنی slug
CREATE FUNCTION generate_slug(input_text VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE slug VARCHAR(255);
    SET slug = LOWER(input_text);
    SET slug = REPLACE(slug, ' ', '-');
    SET slug = REGEXP_REPLACE(slug, '[^a-z0-9-]', '');
    SET slug = REGEXP_REPLACE(slug, '-+', '-');
    SET slug = TRIM(BOTH '-' FROM slug);
    RETURN slug;
END$$

DELIMITER ;

-- =============================================
-- دروستکردنی بینەکان
-- =============================================

-- بینای بابەتە بڵاوکراوەکان
CREATE VIEW published_posts AS
SELECT 
    p.id,
    p.title,
    p.slug,
    p.excerpt,
    p.content,
    p.featured_image,
    p.views_count,
    p.published_at,
    u.username as author_username,
    u.full_name as author_full_name
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.status = 'published'
ORDER BY p.published_at DESC;

-- بینای کۆمێنتە پەسەندکراوەکان
CREATE VIEW approved_comments AS
SELECT 
    c.id,
    c.content,
    c.created_at,
    c.author_name,
    p.title as post_title,
    p.slug as post_slug
FROM comments c
JOIN posts p ON c.post_id = p.id
WHERE c.status = 'approved'
ORDER BY c.created_at DESC;

-- بینای ئاماری بابەتەکان
CREATE VIEW post_statistics AS
SELECT 
    p.id,
    p.title,
    p.views_count,
    p.created_at,
    COUNT(DISTINCT c.id) as comment_count,
    COUNT(DISTINCT pc.category_id) as category_count,
    COUNT(DISTINCT pt.tag_id) as tag_count
FROM posts p
LEFT JOIN comments c ON p.id = c.post_id AND c.status = 'approved'
LEFT JOIN post_categories pc ON p.id = pc.post_id
LEFT JOIN post_tags pt ON p.id = pt.post_id
GROUP BY p.id;

-- =============================================
-- تێکردنی داتای نموونەیی
-- =============================================

-- زیادکردنی بەکارهێنەرانی نموونەیی
INSERT INTO users (username, password_hash, email, full_name, role, status) VALUES
('admin', SHA2('admin123', 256), 'admin@example.com', 'بەڕێوەبەری سیستەم', 'admin', 'active'),
('editor1', SHA2('editor123', 256), 'editor@example.com', 'چاڵاکسازێک', 'editor', 'active'),
('writer1', SHA2('writer123', 256), 'writer@example.com', 'نووسەرێک', 'author', 'active'),
('user1', SHA2('user123', 256), 'user@example.com', 'بەکارهێنەرێکی سادە', 'subscriber', 'active');

-- زیادکردنی بەشەکان
INSERT INTO categories (name, slug, description, parent_id) VALUES
('ھەواڵ', 'news', 'ھەواڵە جیاوازەکان', NULL),
('تەکنۆلۆژیا', 'technology', 'نوێترین تەکنۆلۆژیاکان', NULL),
('زانستی', 'science', 'دەستکەوتەکانی زانست', NULL),
('پزیشکی', 'medicine', 'زانستی پزیشکی', 3),
('فەرھەنگ', 'culture', 'فەرھەنگی کوردی', NULL);

-- زیادکردنی تاگەکان
INSERT INTO tags (name, slug) VALUES
('کوردستان', 'kurdistan'),
('زمان', 'language'),
('کۆمپیوتەر', 'computer'),
('ژینگە', 'environment'),
('تاریخ', 'history');

-- زیادکردنی بابەتەکانی نموونەیی
INSERT INTO posts (title, slug, excerpt, content, author_id, status, published_at) VALUES
('سەلامەتی دیجیتاڵی', 'digital-security', 'ڕێنماییەکانی سەلامەتی دیجیتاڵی', '<p>سەلامەتی دیجیتاڵی گرنگە بۆ پاراستنی تایبەتمەندی.</p>', 1, 'published', NOW()),
('فەرھەنگی کوردی', 'kurdish-culture', 'فەرھەنگ و نەریتەکانی کوردی', '<p>فەرھەنگی کوردی دەوڵەمەندە و مێژوویەکی درێژی ھەیە.</p>', 2, 'published', NOW()),
('دروستکردنی وێبسایت', 'website-creation', 'ڕێگا سادەکان بۆ دروستکردنی وێبسایت', '<p>دەتوانیت بە سادەیی وێبسایتێک دروست بکەیت.</p>', 3, 'published', NOW());

-- پەیوەستکردنی بابەتەکان بە بەشەکانەوە
INSERT INTO post_categories (post_id, category_id) VALUES
(1, 2),  -- سەلامەتی دیجیتاڵی → تەکنۆلۆژیا
(2, 5),  -- فەرھەنگی کوردی → فەرھەنگ
(3, 2);  -- دروستکردنی وێبسایت → تەکنۆلۆژیا

-- پەیوەستکردنی بابەتەکان بە تاگەکانەوە
INSERT INTO post_tags (post_id, tag_id) VALUES
(1, 3),  -- سەلامەتی دیجیتاڵی → کۆمپیوتەر
(2, 1),  -- فەرھەنگی کوردی → کوردستان
(2, 5),  -- فەرھەنگی کوردی → تاریخ
(3, 3);  -- دروستکردنی وێبسایت → کۆمپیوتەر

-- زیادکردنی کۆمێنتەکانی نموونەیی
INSERT INTO comments (post_id, user_id, author_name, author_email, content, status) VALUES
(1, 4, 'بەکارهێنەرێک', 'user@test.com', 'بابەتێکی زۆر باشە، سوپاس بۆ ئەم زانیاریانە', 'approved'),
(2, NULL, 'سەردانکەر', 'visitor@test.com', 'زۆر حەز بە فەرھەنگی کوردی دەکەم', 'approved');

-- زیادکردنی ڕێکخستنە سەرەکییەکان
INSERT INTO settings (setting_key, setting_value, setting_type, category, description) VALUES
('site_title', 'سیستەمی بەڕێوەبردنی ناوەرۆکی کوردی', 'text', 'general', 'سەرناوی سەرەکی وێبسایت'),
('site_description', 'سیستەمێکی سادەی بەڕێوەبردنی ناوەرۆک بە زمانی کوردی', 'text', 'general', 'شیکردنەوەی وێبسایت'),
('posts_per_page', '10', 'number', 'reading', 'ژمارەی بابەتەکان لە هەر پەڕەیەکدا'),
('allow_comments', 'true', 'boolean', 'discussion', 'ڕێگادانی کۆمێنت'),
('admin_email', 'admin@example.com', 'text', 'general', 'ئیمەیڵی بەڕێوەبەر'),
('timezone', 'Asia/Baghdad', 'text', 'general', 'ناوچەی کاتی');

-- =============================================
-- دروستکردنی ڕۆڵەکانی چاودێری
-- =============================================

-- دروستکردنی بەکارهێنەرێک بۆ ڕێکخستنەکان
CREATE USER IF NOT EXISTS 'cms_user'@'localhost' IDENTIFIED BY 'SecurePass123!';
GRANT SELECT, INSERT, UPDATE, DELETE ON kurdish_cms.* TO 'cms_user'@'localhost';

-- دروستکردنی بەکارهێنەرێک بۆ بینینەکان تەنها
CREATE USER IF NOT EXISTS 'cms_viewer'@'localhost' IDENTIFIED BY 'ViewOnly456!';
GRANT SELECT ON kurdish_cms.* TO 'cms_viewer'@'localhost';

-- دروستکردنی بەکارهێنەرێک بۆ ڕاپۆرتەکان
CREATE USER IF NOT EXISTS 'cms_reporter'@'localhost' IDTERMINATED BY 'Report789!';
GRANT SELECT ON kurdish_cms.published_posts TO 'cms_reporter'@'localhost';
GRANT SELECT ON kurdish_cms.post_statistics TO 'cms_reporter'@'localhost';

-- =============================================
-- کۆتایی - سیستەمی بەڕێوەبردنی ناوەرۆک
-- =============================================

-- نمایشکردنی زانیارییەکانی سیستەم
SELECT 
    '✅ سیستەمی بەڕێوەبردنی ناوەرۆکی کوردی دروست کراوە!' as message,
    COUNT(*) as total_tables,
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM posts) as total_posts,
    (SELECT COUNT(*) FROM categories) as total_categories
FROM information_schema.tables 
WHERE table_schema = 'kurdish_cms';
