CREATE TABLE IF NOT EXISTS ps_cs_payment_modes_tbl (
    id INT GENERATED ALWAYS AS IDENTITY,
    mode_name VARCHAR(33) PRIMARY KEY
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Audit fields
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(35) NOT NULL,
    version INT DEFAULT 1 NOT NULL,
);

CREATE TABLE IF NOT EXISTS ps_cs_customers_tbl (
    id VARCHAR(10) PRIMARY KEY CONSTRAINT chk_id_length CHECK (id ~ '^[0-9]{10}$'),
    username VARCHAR(55) NOT NULL),
    given_name VARCHAR(35) NOT NULL CONSTRAINT chk_given_name_no_numbers CHECK (given_name ~ '^[A-Za-z ]+$'),
    sur_name VARCHAR(35) NOT NULL CONSTRAINT chk_sur_name_no_numbers CHECK (sur_name ~ '^[A-Za-z ]+$'),
    date_of_birth DATE NOT NULL,
    email VARCHAR(55) NOT NULL,
    alternate_mobile VARCHAR(10) CONSTRAINT chk_alt_mobile_length CHECK (alternate_mobile ~ '^[0-9]{10}$'),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Audit fields
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(35) NOT NULL,
    version INT DEFAULT 1 NOT NULL
);

CREATE TABLE IF NOT EXISTS ps_cs_credentials_tbl (
    customer INT PRIMARY KEY REFERENCES ps_cs_customers_tbl(id) ON DELETE CASCADE,
    password_hash VARCHAR(255) NOT NULL,
    cred_type VARCHAR(25) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Audit fields
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(35) NOT NULL,
    version INT DEFAULT 1 NOT NULL,
);

CREATE TABLE IF NOT EXISTS ps_cs_customers_profile_tbl (
    id SERIAL PRIMARY KEY,
    customer INT PRIMARY KEY REFERENCES ps_cs_customers_tbl(id) ON DELETE CASCADE,
    profile_picture_url VARCHAR(2048),
    passport_photo_url VARCHAR(2048),
    aadhar_url VARCHAR(2048),
    headline VARCHAR(20),
    website_url VARCHAR(2048),
    location VARCHAR(100),
    gender VARCHAR(20) CONSTRAINT chk_gender CHECK (gender IN ('Male', 'Female', 'Prefer not to say')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Audit fields
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(35) NOT NULL,
    version INT DEFAULT 1 NOT NULL,
);

CREATE TABLE IF NOT EXISTS ps_cs_customers_offer_tbl (
    id SERIAL PRIMARY KEY,
    customer INT PRIMARY KEY REFERENCES ps_cs_customers_tbl(id) ON DELETE CASCADE,
    discount SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Audit fields
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(35) NOT NULL,
    version INT DEFAULT 1 NOT NULL,

CREATE TABLE IF NOT EXISTS ps_cs_eb_services_tbl (
    id SERIAL PRIMARY KEY,
    customer INT PRIMARY KEY REFERENCES ps_cs_customers_tbl(id) ON DELETE CASCADE,
    ebservice VARCHAR(18) NOT NULL,
    name_on_service VARCHAR(80) NOT NULL,
    description VARCHAR(15),
    payment_cycle SMALLINT NOT NULL,
    eb_documents_url VARCHAR(2048),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Audit fields
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(35) NOT NULL,
    version INT DEFAULT 1 NOT NULL,

    CONSTRAINT chk_ebservice CHECK (ebservice LIKE '0%'),
);


CREATE TABLE IF NOT EXISTS ps_cs_eb_payments_tbl (
    id SERIAL PRIMARY KEY,
    customer INT PRIMARY KEY REFERENCES ps_cs_customers_tbl(id) ON DELETE CASCADE,
    service_no VARCHAR(20) NOT NULL,
    name_on_service VARCHAR(80) NOT NULL,
    payment_amount NUMERIC(10, 2) NOT NULL,
    paid_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_mode VARCHAR(33) NOT NULL,
    transaction_note TEXT,
    transaction_id VARCHAR(80),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Audit fields
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    version INT DEFAULT 1 NOT NULL,,
    updated_by VARCHAR(35) NOT NULL,

    CONSTRAINT fk_payment_mode FOREIGN KEY (payment_mode) REFERENCES ps_cs_payment_modes_tbl(mode_name)
);


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

