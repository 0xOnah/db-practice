CREATE TABLE users(
	username VARCHAR(100) UNIQUE,
	age INT,
    CONSTRAINT uc_duplicate_username UNIQUE (username)
);

ALTER TABLE users ADD CONSTRAINT users_duplicate_name UNIQUE (username);


INSERT INTO users(username, age) VALUES('booby', 70);


DELIMITER $$

CREATE TRIGGER must_be_adult
     BEFORE INSERT ON users FOR EACH ROW
     BEGIN
          IF NEW.age < 18
          THEN
              SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Must be an adult!';
          END IF;
     END;
$$

DELIMITER ;


--WORKING WITH THE INSTAGRAM DATA 
--preventing self follows
DELIMITER $$

CREATE TRIGGER example_cannot_follow_self
     BEFORE INSERT ON follows FOR EACH ROW
     BEGIN
          IF NEW.follower_id = NEW.following_id
          THEN
               SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Cannot follow yourself, silly';
          END IF;
     END;
$$

DELIMITER ;



--Logging unfollows
DELIMITER $$

CREATE TRIGGER create_unfollow
    AFTER DELETE ON follows FOR EACH ROW 
BEGIN
    INSERT INTO unfollows
    SET follower_id = OLD.follower_id,
        followee_id = OLD.followee_id;
END$$

DELIMITER ;

--or

--THIS IS ALSO POSSIBLE
DELIMITER $$

CREATE TRIGGER create_unfollow
    AFTER DELETE ON follows FOR EACH ROW 
BEGIN
    INSERT INTO unfollows(follower_id, followee_id) 
    VALUES(OLD.follower_id, OLD.followee_id);
END$$

DELIMITER ;
