--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.7 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

--
-- Name: address; Type: TABLE; Schema: public; Owner: forkscanner
--

Create Database judge;
\c judge;

CREATE TABLE public.address (
    address character varying(62) NOT NULL,
    script bytea NOT NULL,
    preimage bytea NOT NULL,
    unlock_height bigint,
    parent_address character varying(62),
    signed_sweep boolean DEFAULT false,
    signed_refund boolean DEFAULT false,
    archived boolean DEFAULT false
);


ALTER TABLE public.address OWNER TO forkscanner;

--
-- Name: notification; Type: TABLE; Schema: public; Owner: forkscanner
--

CREATE TABLE public.notification (
    block character varying(64) NOT NULL,
    receiving character varying(65) NOT NULL,
    satoshis bigint NOT NULL,
    height bigint NOT NULL,
    txid character varying(64) NOT NULL,
    archived boolean DEFAULT false,
    sending character varying(65),
    receiving_vout bigint,
    sending_vout bigint
);


ALTER TABLE public.notification OWNER TO forkscanner;

--
-- Name: proposed_address; Type: TABLE; Schema: public; Owner: forkscanner
--

CREATE TABLE public.proposed_address (
    current character varying(62) NOT NULL,
    proposed character varying(62) NOT NULL,
    unlock_height bigint,
    "reserveId" bigint,
    "roundId" bigint
);


ALTER TABLE public.proposed_address OWNER TO forkscanner;

--
-- Name: signed_tx; Type: TABLE; Schema: public; Owner: forkscanner
--

CREATE TABLE public.signed_tx (
    tx bytea NOT NULL,
    unlock_height bigint
);


ALTER TABLE public.signed_tx OWNER TO forkscanner;

--
-- Name: transaction; Type: TABLE; Schema: public; Owner: forkscanner
--

CREATE TABLE public.transaction (
    txid character varying(64) NOT NULL,
    address character varying(65),
    reserve bigint,
    watched boolean DEFAULT true,
    round bigint
);


ALTER TABLE public.transaction OWNER TO forkscanner;

--
-- Name: address address_pkey; Type: CONSTRAINT; Schema: public; Owner: forkscanner
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address);


--
-- Name: signed_tx signed_tx_pkey; Type: CONSTRAINT; Schema: public; Owner: forkscanner
--

ALTER TABLE ONLY public.signed_tx
    ADD CONSTRAINT signed_tx_pkey PRIMARY KEY (tx);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: forkscanner
--

ALTER TABLE ONLY public.transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (txid);


--
-- Name: notification watched_txid_vout_key; Type: CONSTRAINT; Schema: public; Owner: forkscanner
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT watched_txid_vout_key UNIQUE (txid, receiving_vout);


--
-- PostgreSQL database dump complete
--

