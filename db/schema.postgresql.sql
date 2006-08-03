-- tables 

CREATE TABLE users (
  "id" serial primary key,
  "name" character varying(255),
  "login" character varying(255),
  "email" character varying(255),
  "jabber" character varying(255),
  "notify_via_jabber" boolean DEFAULT 'f',
  "notify_on_comments" boolean DEFAULT 't',
  "notify_on_my_torrents" boolean DEFAULT 't',
  "picture_url" character varying(255)
);

CREATE TABLE comments (
  "id" serial primary key,
  "torrent_id" integer,
  "user_id" integer,
  "content" text,
  "created_at" timestamp
);

CREATE TABLE torrents (
  "id" serial primary key,
  "user_id" integer,
  "title" character varying(255),
  "description" text,
  "size" integer,
  "filename" character varying(255),
  "percent_done" float,
  "rate_up" float,
  "rate_down" float,
  "transferred_up" integer,
  "transferred_down" integer,
  "peers" integer,
  "seeds" integer,
  "distributed_copies" float,
  "hidden" boolean DEFAULT 'f',
  "command" text,
  "statusmsg" text,
  "errormsg" text,
  "created_at" timestamp,
  "updated_at" timestamp
);


-- indexes 

CREATE INDEX comments_content_index ON comments(content);
CREATE INDEX torrents_filename_index ON torrents(filename);
CREATE INDEX torrents_title_index ON torrents(title);
CREATE INDEX torrents_description_index ON torrents(description);

-- data 

INSERT INTO users ("name","login","email") VALUES ('Niklas','niklas','niklas@lanpartei.de');
INSERT INTO users ("name","login","email") VALUES ('Mathis','mathis','mathis@lanpartei.de');
