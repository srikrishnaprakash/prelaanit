CREATE TRIGGER ps_cs_cust_profil_ts_ver_up_trg
BEFORE UPDATE ON ps_cs_customers_profile_tbl
FOR EACH ROW
EXECUTE FUNCTION update_profile_timestamp_and_version();


CREATE TRIGGER ps_cs_customers_ts_ver_up_trg
BEFORE UPDATE ON ps_cs_customers_tbl
FOR EACH ROW
EXECUTE FUNCTION update_profile_timestamp_and_version();