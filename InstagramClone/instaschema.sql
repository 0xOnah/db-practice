DROP DATABASE IF EXISTS instaclone;

CREATE DATABASE instaclone;

USE instaclone;

CREATE TABLE users (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL
);

CREATE TABLE photos (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    image_url TEXT NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE likes (
    user_id INTEGER NOT NULL,
    photo_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE,
    PRIMARY KEY(user_id, photo_id)
);

CREATE TABLE comments (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    comment VARCHAR(255) NOT NULL,
    user_id INTEGER NOT NULL,
    photo_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (photo_id) REFERENCES photos(id) ON DELETE CASCADE
);

CREATE TABLE follows (
    follower_id INTEGER NOT NULL,
    followee_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL,
    PRIMARY KEY (follower_id, followee_id),
    FOREIGN KEY(follower_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY(followee_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT cannot__self_follow CHECK (follower_id != followee_id)
);

CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTO_INCREMENT,
    tag_name VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL
);

CREATE TABLE photo_tags (
    photo_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    FOREIGN KEY(photo_id) REFERENCES photos(id),
    FOREIGN KEY(tag_id) REFERENCES tags(id),
    PRIMARY KEY(photo_id, tag_id)
);

-- Rewarding 5 oldest users
SELECT * FROM users 
ORDER BY created_at LIMIT 5;

-- What day of the week did most users register on
SELECT DAYNAME(created_at) AS week_day, 
COUNT(*) FROM users GROUP BY week_day;

-- Find users who have never posted a photo
SELECT users.username FROM users 
LEFT JOIN photos ON users.id = photos.user_id 
WHERE photos.id IS NULL;

-- Who got the most likes on a single photo
SELECT users.id, users.username, 
    photos.user_id, photos.image_url, 
    likes.photo_id, 
    COUNT(*) AS number_of_likes
FROM likes 
INNER JOIN photos ON likes.photo_id = photos.id 
INNER JOIN users ON users.id = photos.user_id
GROUP BY photos.id ORDER BY number_of_likes DESC;

-- Number of times the average user posts \\ NOT YET SOLVED
SELECT AVG(total_photos) AS average_photo_count 
FROM
(
    SELECT users.username, COUNT(photos.id) AS total_photos 
    FROM users 
    LEFT JOIN photos ON users.id = photos.user_id 
    GROUP BY users.id
) AS total_photo_count;


--top 5 mostly commonly or popular hashtags
SELECT tags.id, tags.tag_name, COUNT(*) AS MOST_USED_TAGS
From tags
INNER JOIN photo_tags ON tags.id=photo_tags.tag_id 
GROUP by tags.id ORDER BY MOST_USED_TAGS DESC LIMIT 5;




--user who have like every single photo on the site

SELECT users.id, users.username, 
COUNT(*) AS Num_likes 
FROM users
INNER JOIN likes ON likes.user_id = users.id
GROUP BY users.id
HAVING Num_likes = 257;







CREATE TABLE IF NOT EXISTS tokens(
    hash bytea PRIMARY KEY,
    user_id bigint NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expiry timestamp(0) with time zone NOT NULL,
    scope text NOT NULL
);

CREATE TABLE IF NOT EXISTS users(
    id bigserial PRIMARY KEY,
    created_at timestamp(0) with time zone NOT NULL DEFAULT NOW(),
    name text NOT NULL,
    email citext UNIQUE NOT NULL,
    password_hash bytea NOT NULL,
    activated bool NOT NULL, 
    version integer NOT NULL DEFAULT 1
);


SELECT * FROM users
INNER JOIN tokens ON uses.id = tokens.user_id

SELECT users.id, users.created_at, user.name, users.email, users.password_hash, users.activated, users.version
FROM users
INNER JOIN tokens
ON users.id = tokens.user_id
WHERE tokens.hash = $1
AND tokens.scope = $2
AND tokens.expiry > $3