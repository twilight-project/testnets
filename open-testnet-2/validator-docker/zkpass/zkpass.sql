-- zkpass.sql (minimal)
CREATE TABLE IF NOT EXISTS public.zkpass (
  address    text NOT NULL UNIQUE,
  identifier text NOT NULL,
  provider   text NOT NULL
);

CREATE TABLE IF NOT EXISTS public.selfcheck (
  attestationId text NOT NULL,
  proof         text NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_zkpass_unique ON public.zkpass (address, provider);
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