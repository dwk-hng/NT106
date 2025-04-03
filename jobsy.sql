CREATE DATABASE jobsy;
USE jobsy;

-- Bảng tài khoản người dùng
CREATE TABLE user_accounts (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('candidate', 'company', 'hr') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng thông tin ứng viên
CREATE TABLE candidates (
    candidate_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    profile_image VARCHAR(255),
    bio TEXT,
    FOREIGN KEY (user_id) REFERENCES user_accounts(user_id)
);

-- Bảng thông tin doanh nghiệp
CREATE TABLE companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    company_name VARCHAR(100) NOT NULL,
    description_company TEXT,
    website VARCHAR(100),
    contact_email VARCHAR(100),
    phone VARCHAR(20),
    logo VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user_accounts(user_id)
);

-- Bảng CV của ứng viên
CREATE TABLE cv (
    cv_id INT AUTO_INCREMENT PRIMARY KEY,
    candidate_id INT NOT NULL,
    title VARCHAR(100),
    content TEXT,
    status ENUM('draft', 'submitted') DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id)
);

-- Bảng đính kèm cho CV (chứng chỉ, card visit, ...)
CREATE TABLE cv_attachments (
    attachment_id INT AUTO_INCREMENT PRIMARY KEY,
    cv_id INT NOT NULL,
    attachment_type ENUM('certificate', 'digital_certificate', 'business_card', 'other') NOT NULL,
    file_url VARCHAR(255) NOT NULL,
    description_cv_attachments VARCHAR(255),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cv_id) REFERENCES cv(cv_id)
);

-- Bảng theo dõi doanh nghiệp (ứng viên theo dõi)
CREATE TABLE company_followers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    candidate_id INT NOT NULL,
    company_id INT NOT NULL,
    followed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (candidate_id, company_id),
    FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

-- Bảng bài đăng tuyển dụng
CREATE TABLE job_recruitments (
    job_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description_job_recruitments TEXT,
    requirements TEXT,
    location VARCHAR(255),
    salary_range VARCHAR(50),
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

-- Bảng ứng tuyển (nộp CV)
CREATE TABLE job_applications (
    application_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    candidate_id INT NOT NULL,
    cv_id INT,
    status ENUM('applied', 'under_review', 'interview', 'rejected', 'hired') DEFAULT 'applied',
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    interview_date DATETIME,
    FOREIGN KEY (job_id) REFERENCES job_recruitments(job_id),
    FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),
    FOREIGN KEY (cv_id) REFERENCES cv(cv_id)
);

-- Bảng tin nhắn giữa ứng viên và HR
CREATE TABLE messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    content TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_sender FOREIGN KEY (sender_id) REFERENCES user_accounts(user_id),
    CONSTRAINT fk_receiver FOREIGN KEY (receiver_id) REFERENCES user_accounts(user_id)
);

-- Bảng diễn đàn của doanh nghiệp
CREATE TABLE forums (
    forum_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    title VARCHAR(100) NOT NULL,
    description_forum TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

-- Bảng bài viết trong diễn đàn (forum_posts)
CREATE TABLE forum_posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    forum_id INT NOT NULL,          -- Liên kết đến diễn đàn cụ thể
    user_id INT NOT NULL,           -- ID người đăng (ứng viên, HR, ...)
    content TEXT NOT NULL,          -- Nội dung bài đăng
    parent_post_id INT DEFAULT NULL, -- Nếu không NULL thì đây là bài trả lời cho bài có post_id tương ứng
    posted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (forum_id) REFERENCES forums(forum_id),
    FOREIGN KEY (user_id) REFERENCES user_accounts(user_id),
    FOREIGN KEY (parent_post_id) REFERENCES forum_posts(post_id)
);

-- Bảng đánh giá ứng viên sau phỏng vấn
CREATE TABLE candidate_evaluations (
    evaluation_id INT AUTO_INCREMENT PRIMARY KEY,
    job_id INT NOT NULL,
    candidate_id INT NOT NULL,
    evaluator_id INT NOT NULL, -- HR hoặc người phỏng vấn
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment_candidate_evaluations TEXT,
    evaluated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES job_recruitments(job_id),
    FOREIGN KEY (candidate_id) REFERENCES candidates(candidate_id),
    FOREIGN KEY (evaluator_id) REFERENCES user_accounts(user_id)
);

-- Bảng thông báo (notifications)
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type_notification VARCHAR(50), -- ví dụ: 'interview', 'message', 'forum'
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES user_accounts(user_id)
);
-- Bảng bài đăng của doanh nghiệp
CREATE TABLE company_posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    title VARCHAR(255),
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

-- Bảng lưu trữ hình ảnh cho bài đăng
CREATE TABLE post_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    caption VARCHAR(255),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES company_posts(post_id)
);

-- Bảng lưu lại lượt "thả tim" của người dùng trên bài đăng
CREATE TABLE post_likes (
    like_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (post_id, user_id),
    FOREIGN KEY (post_id) REFERENCES company_posts(post_id),
    FOREIGN KEY (user_id) REFERENCES user_accounts(user_id)
);

-- Bảng lưu bình luận cho bài đăng
CREATE TABLE post_comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_post TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES company_posts(post_id),
    FOREIGN KEY (user_id) REFERENCES user_accounts(user_id)
);

-- Bảng lưu thông tin share bài đăng
CREATE TABLE post_shares (
    share_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    share_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES company_posts(post_id),
    FOREIGN KEY (user_id) REFERENCES user_accounts(user_id)
);
