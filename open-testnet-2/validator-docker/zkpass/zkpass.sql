-- zkpass.sql (minimal)
CREATE TABLE IF NOT EXISTS public.zkpass(
    address text NOT NULL,
    identifier text NOT NULL,
    provider text NOT NULL,
    is_real boolean NOT NULL DEFAULT false
);
CREATE UNIQUE INDEX zkpass_address_key ON public.zkpass USING btree (address);
CREATE UNIQUE INDEX idx_zkpass_unique ON public.zkpass USING btree (address, provider);


CREATE TABLE IF NOT EXISTS public.selfcheck (
  attestationId text NOT NULL,
  proof         text NOT NULL
);

ALTER DATABASE zkpass SET timezone TO 'UTC';


CREATE TABLE IF NOT EXISTS public.addresses (
    address VARCHAR(255) PRIMARY KEY,
    lastusedNyks TIMESTAMP,
    lastusedSats TIMESTAMP
);

CREATE TABLE IF NOT EXISTS public.AddressMappings (
    twilightAddress VARCHAR(255) PRIMARY KEY,
    ethAddress VARCHAR(255) UNIQUE NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);