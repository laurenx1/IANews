-- CREATE DATABASE archive_tv_news;
-- USE archive_tv_news;

-- Main table for shows
CREATE TABLE shows (
    -- primary key, unique show identifer from internet archive
    identifier VARCHAR(255) PRIMARY KEY,

    -- the network that the show aired on
    channel VARCHAR(100),

    -- scheduled start time of the show
    start_time TIME,

    -- the scheduled end time of the show
    -- @TODO come back, decide real vs. scheduled
    stop_time TIME,

    -- the date that the show aired
    date DATE,

    -- name of the show
    show_name VARCHAR(255),

    -- closed captioning of the show
    transcript TEXT,

    -- an estimated words per second for the show based on the start + stop times
    -- and the number of words in the transcript
    words_per_second FLOAT GENERATED ALWAYS AS (
        CASE 
            WHEN TIMESTAMPDIFF(SECOND, TIMESTAMP(date, start_time), TIMESTAMP(date, stop_time)) > 0 
            THEN LENGTH(transcript) - LENGTH(REPLACE(transcript, ' ', '')) + 1 / 
                 TIMESTAMPDIFF(SECOND, TIMESTAMP(date, start_time), TIMESTAMP(date, stop_time))
            ELSE 0
        END
    ) STORED
);


-- Table for blocks (the transcript of a show broken up 
-- into distinct number of words or specified amount of time 
-- ex. 15 minute blocks using words_per_second attribute 
-- from shows_table 
CREATE TABLE blocks (

    --- a combination of show identifier and block index within the show
    block_id VARCHAR(300) PRIMARY KEY,
    show_identifier VARCHAR(255),

    -- the ordering of the block within  the show
    block_index INT,
    channel VARCHAR(100),

    -- block's start and stop time based on assumed words per second
    start_time TIME,
    stop_time TIME,

    -- date that the show aired
    date DATE,

    -- the chunk of text for this particular block
    transcript_chunk TEXT,
    FOREIGN KEY (show_identifier) REFERENCES shows(identifier)
);