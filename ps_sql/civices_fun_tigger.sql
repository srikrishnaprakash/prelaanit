-- Updated trigger function to handle both the timestamp and the version increment
CREATE OR REPLACE FUNCTION version_update()
RETURNS TRIGGER AS $$
BEGIN
    -- Safely handle versioning based on the operation
    IF (TG_OP = 'UPDATE') THEN
        NEW.version = COALESCE(OLD.version, 0) + 1;
    ELSIF (TG_OP = 'INSERT') THEN
        NEW.version = 1;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ps_cs_cust_profil_ts_ver_up_trg
BEFORE UPDATE ON ps_cs_customers_profile_tbl
FOR EACH ROW
EXECUTE FUNCTION update_profile_timestamp_and_version();


CREATE TRIGGER ps_cs_customers_ts_ver_up_trg
BEFORE UPDATE ON ps_cs_customers_tbl
FOR EACH ROW
EXECUTE FUNCTION update_profile_timestamp_and_version();