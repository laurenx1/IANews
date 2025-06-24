-- show level view
CREATE VIEW show_level AS
SELECT 
    identifier,
    channel,
    date,
    transcript
FROM shows;

-- block level view
CREATE VIEW block_level AS
SELECT 
    block_id,
    show_identifier AS identifier,
    channel,
    start_time,
    stop_time,
    date,
    transcript_chunk AS transcript
FROM blocks;

-- view to see blocks for a specific show
-- parameters: show_identifier 
CREATE VIEW show_blocks AS
SELECT 
    b.block_id,
    b.channel,
    b.start_time,
    b.stop_time,
    b.date,
    b.transcript_chunk,
    s.show_name
FROM blocks b
JOIN shows s ON b.show_identifier = s.identifier;