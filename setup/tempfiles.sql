CREATE FUNCTION tempfiles() RETURNS void
AS
    'BEGIN
        PERFORM *
        FROM generate_series(1, 1000000)
        ORDER BY 1;
        RETURN;
    END;'
    LANGUAGE plpgsql;