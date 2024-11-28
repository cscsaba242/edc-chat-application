/*
 * Copyright (c)  2024 smartSense Consulting Solutions Pvt. Ltd.
 */

-- sql-lease
CREATE TABLE IF NOT EXISTS edc_lease
(
    leased_by      VARCHAR NOT NULL,
    leased_at      BIGINT,
    lease_duration INTEGER NOT NULL,
    lease_id       VARCHAR NOT NULL
        CONSTRAINT lease_pk
            PRIMARY KEY
);

COMMENT ON COLUMN edc_lease.leased_at IS 'posix timestamp of lease';

COMMENT ON COLUMN edc_lease.lease_duration IS 'duration of lease in milliseconds';

CREATE UNIQUE INDEX IF NOT EXISTS lease_lease_id_uindex
    ON edc_lease (lease_id);


-- test entity
CREATE TABLE IF NOT EXISTS edc_test_entity
(
    id       VARCHAR NOT NULL
        CONSTRAINT test_id_pk PRIMARY KEY,
    lease_id VARCHAR
        CONSTRAINT test_entity_lease_id_fk
            REFERENCES edc_lease
            ON DELETE SET NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS test_entity_id_uindex
    ON edc_test_entity (id);

-- edr-index

CREATE TABLE IF NOT EXISTS edc_edr_entry
(
    transfer_process_id     VARCHAR NOT NULL PRIMARY KEY,
    agreement_id            VARCHAR NOT NULL,
    asset_id                VARCHAR NOT NULL,
    provider_id             VARCHAR NOT NULL,
    contract_negotiation_id VARCHAR,
    created_at              BIGINT  NOT NULL
);


-- sts
-- THIS SCHEMA HAS BEEN WRITTEN AND TESTED ONLY FOR POSTGRES

-- table: edc_sts_client

CREATE TABLE IF NOT EXISTS edc_sts_client
(
    id                   VARCHAR NOT NULL PRIMARY KEY,
    client_id            VARCHAR NOT NULL,
    did                  VARCHAR NOT NULL,
    name                 VARCHAR NOT NULL,
    secret_alias         VARCHAR NOT NULL,
    private_key_alias    VARCHAR NOT NULL,
    public_key_reference VARCHAR NOT NULL,
    created_at           BIGINT  NOT NULL
);


CREATE UNIQUE INDEX IF NOT EXISTS sts_client_client_id_index ON edc_sts_client (client_id);

-- assets
CREATE TABLE IF NOT EXISTS edc_asset
(
    asset_id           VARCHAR NOT NULL,
    created_at         BIGINT  NOT NULL,
    properties         JSON DEFAULT '{}',
    private_properties JSON DEFAULT '{}',
    data_address       JSON DEFAULT '{}',
    PRIMARY KEY (asset_id)
);

COMMENT ON COLUMN edc_asset.properties IS 'Asset properties serialized as JSON';
COMMENT ON COLUMN edc_asset.private_properties IS 'Asset private properties serialized as JSON';
COMMENT ON COLUMN edc_asset.data_address IS 'Asset DataAddress serialized as JSON';

-- dataplane
-- Statements are designed for and tested with Postgres only!

CREATE TABLE IF NOT EXISTS edc_lease
(
    leased_by      VARCHAR NOT NULL,
    leased_at      BIGINT,
    lease_duration INTEGER NOT NULL,
    lease_id       VARCHAR NOT NULL
        CONSTRAINT lease_pk
            PRIMARY KEY
);

COMMENT ON COLUMN edc_lease.leased_at IS 'posix timestamp of lease';
COMMENT ON COLUMN edc_lease.lease_duration IS 'duration of lease in milliseconds';

CREATE TABLE IF NOT EXISTS edc_data_plane
(
    process_id                VARCHAR           NOT NULL PRIMARY KEY,
    state                     INTEGER           NOT NULL,
    created_at                BIGINT            NOT NULL,
    updated_at                BIGINT            NOT NULL,
    state_count               INTEGER DEFAULT 0 NOT NULL,
    state_time_stamp          BIGINT,
    trace_context             JSON,
    error_detail              VARCHAR,
    callback_address          VARCHAR,
    lease_id                  VARCHAR
        CONSTRAINT data_plane_lease_lease_id_fk
            REFERENCES edc_lease
            ON DELETE SET NULL,
    source                    JSON,
    destination               JSON,
    properties                JSON,
    flow_type                 VARCHAR,
    transfer_type_destination VARCHAR
);

COMMENT ON COLUMN edc_data_plane.trace_context IS 'Java Map serialized as JSON';
COMMENT ON COLUMN edc_data_plane.source IS 'DataAddress serialized as JSON';
COMMENT ON COLUMN edc_data_plane.destination IS 'DataAddress serialized as JSON';
COMMENT ON COLUMN edc_data_plane.properties IS 'Java Map serialized as JSON';

-- This will help to identify states that need to be transitioned without a table scan when the entries grow
CREATE INDEX IF NOT EXISTS data_plane_state ON edc_data_plane (state, state_time_stamp);

-- jti-validation

CREATE TABLE IF NOT EXISTS edc_jti_validation
(
    token_id   VARCHAR NOT NULL PRIMARY KEY,
    expires_at BIGINT -- expiry time in epoch millis
);

-- access-token-schema

CREATE TABLE IF NOT EXISTS edc_accesstokendata
(
    id                    VARCHAR NOT NULL PRIMARY KEY,
    claim_token           JSON    NOT NULL,
    data_address          JSON    NOT NULL,
    additional_properties JSON DEFAULT '{}'
);

COMMENT ON COLUMN edc_accesstokendata.claim_token IS 'ClaimToken serialized as JSON map';
COMMENT ON COLUMN edc_accesstokendata.data_address IS 'DataAddress serialized as JSON map';
COMMENT ON COLUMN edc_accesstokendata.additional_properties IS 'Optional Additional properties serialized as JSON map';

-- policy monitor
CREATE TABLE IF NOT EXISTS edc_accesstokendata
(
    id                    VARCHAR NOT NULL PRIMARY KEY,
    claim_token           JSON    NOT NULL,
    data_address          JSON    NOT NULL,
    additional_properties JSON DEFAULT '{}'
);

COMMENT ON COLUMN edc_accesstokendata.claim_token IS 'ClaimToken serialized as JSON map';
COMMENT ON COLUMN edc_accesstokendata.data_address IS 'DataAddress serialized as JSON map';
COMMENT ON COLUMN edc_accesstokendata.additional_properties IS 'Optional Additional properties serialized as JSON map';

-- transferprocess
-- Statements are designed for and tested with Postgres only!

CREATE TABLE IF NOT EXISTS edc_lease
(
    leased_by      VARCHAR NOT NULL,
    leased_at      BIGINT,
    lease_duration INTEGER NOT NULL,
    lease_id       VARCHAR NOT NULL
        CONSTRAINT lease_pk
            PRIMARY KEY
);

COMMENT ON COLUMN edc_lease.leased_at IS 'posix timestamp of lease';

COMMENT ON COLUMN edc_lease.lease_duration IS 'duration of lease in milliseconds';

CREATE TABLE IF NOT EXISTS edc_transfer_process
(
    transferprocess_id       VARCHAR           NOT NULL
        CONSTRAINT transfer_process_pk
            PRIMARY KEY,
    type                     VARCHAR           NOT NULL,
    state                    INTEGER           NOT NULL,
    state_count              INTEGER DEFAULT 0 NOT NULL,
    state_time_stamp         BIGINT,
    created_at               BIGINT            NOT NULL,
    updated_at               BIGINT            NOT NULL,
    trace_context            JSON,
    error_detail             VARCHAR,
    resource_manifest        JSON,
    provisioned_resource_set JSON,
    content_data_address     JSON,
    deprovisioned_resources  JSON,
    private_properties       JSON,
    callback_addresses       JSON,
    pending                  BOOLEAN DEFAULT FALSE,
    transfer_type            VARCHAR,
    protocol_messages        JSON,
    data_plane_id            VARCHAR,
    correlation_id           VARCHAR,
    counter_party_address    VARCHAR,
    protocol                 VARCHAR,
    asset_id                 VARCHAR,
    contract_id              VARCHAR,
    data_destination         JSON,
    lease_id                 VARCHAR
        CONSTRAINT transfer_process_lease_lease_id_fk
            REFERENCES edc_lease
            ON DELETE SET NULL
);

COMMENT ON COLUMN edc_transfer_process.trace_context IS 'Java Map serialized as JSON';

COMMENT ON COLUMN edc_transfer_process.resource_manifest IS 'java ResourceManifest serialized as JSON';

COMMENT ON COLUMN edc_transfer_process.provisioned_resource_set IS 'ProvisionedResourceSet serialized as JSON';

COMMENT ON COLUMN edc_transfer_process.content_data_address IS 'DataAddress serialized as JSON';

COMMENT ON COLUMN edc_transfer_process.deprovisioned_resources IS 'List of deprovisioned resources, serialized as JSON';


CREATE UNIQUE INDEX IF NOT EXISTS transfer_process_id_uindex
    ON edc_transfer_process (transferprocess_id);

CREATE UNIQUE INDEX IF NOT EXISTS lease_lease_id_uindex
    ON edc_lease (lease_id);

-- This will help to identify states that need to be transitioned without a table scan when the entries grow
CREATE INDEX IF NOT EXISTS transfer_process_state ON edc_transfer_process (state, state_time_stamp);

-- policy definition

CREATE TABLE IF NOT EXISTS edc_policydefinitions
(
    policy_id             VARCHAR NOT NULL,
    created_at            BIGINT  NOT NULL,
    permissions           JSON,
    prohibitions          JSON,
    duties                JSON,
    profiles              JSON,
    extensible_properties JSON,
    inherits_from         VARCHAR,
    assigner              VARCHAR,
    assignee              VARCHAR,
    target                VARCHAR,
    policy_type           VARCHAR NOT NULL,
    private_properties    JSON,
    PRIMARY KEY (policy_id)
);

COMMENT ON COLUMN edc_policydefinitions.permissions IS 'Java List<Permission> serialized as JSON';
COMMENT ON COLUMN edc_policydefinitions.prohibitions IS 'Java List<Prohibition> serialized as JSON';
COMMENT ON COLUMN edc_policydefinitions.duties IS 'Java List<Duty> serialized as JSON';
COMMENT ON COLUMN edc_policydefinitions.profiles IS 'Java List<String> serialized as JSON';
COMMENT ON COLUMN edc_policydefinitions.extensible_properties IS 'Java Map<String, Object> serialized as JSON';
COMMENT ON COLUMN edc_policydefinitions.policy_type IS 'Java PolicyType serialized as JSON';

CREATE UNIQUE INDEX IF NOT EXISTS edc_policydefinitions_id_uindex
    ON edc_policydefinitions (policy_id);

-- cd

CREATE TABLE IF NOT EXISTS edc_contract_definitions
(
    created_at             BIGINT  NOT NULL,
    contract_definition_id VARCHAR NOT NULL,
    access_policy_id       VARCHAR NOT NULL,
    contract_policy_id     VARCHAR NOT NULL,
    assets_selector        JSON    NOT NULL,
    private_properties     JSON,
    PRIMARY KEY (contract_definition_id)
);

-- negotiation
-- Statements are designed for and tested with Postgres only!

CREATE TABLE IF NOT EXISTS edc_lease
(
    leased_by      VARCHAR               NOT NULL,
    leased_at      BIGINT,
    lease_duration INTEGER DEFAULT 60000 NOT NULL,
    lease_id       VARCHAR               NOT NULL
        CONSTRAINT lease_pk
            PRIMARY KEY
);

COMMENT ON COLUMN edc_lease.leased_at IS 'posix timestamp of lease';

COMMENT ON COLUMN edc_lease.lease_duration IS 'duration of lease in milliseconds';


CREATE UNIQUE INDEX IF NOT EXISTS lease_lease_id_uindex
    ON edc_lease (lease_id);



CREATE TABLE IF NOT EXISTS edc_contract_agreement
(
    agr_id            VARCHAR NOT NULL
        CONSTRAINT contract_agreement_pk
            PRIMARY KEY,
    provider_agent_id VARCHAR,
    consumer_agent_id VARCHAR,
    signing_date      BIGINT,
    start_date        BIGINT,
    end_date          INTEGER,
    asset_id          VARCHAR NOT NULL,
    policy            JSON
);


CREATE TABLE IF NOT EXISTS edc_contract_negotiation
(
    id                   VARCHAR           NOT NULL
        CONSTRAINT contract_negotiation_pk
            PRIMARY KEY,
    created_at           BIGINT            NOT NULL,
    updated_at           BIGINT            NOT NULL,
    correlation_id       VARCHAR,
    counterparty_id      VARCHAR           NOT NULL,
    counterparty_address VARCHAR           NOT NULL,
    protocol             VARCHAR           NOT NULL,
    type                 VARCHAR           NOT NULL,
    state                INTEGER DEFAULT 0 NOT NULL,
    state_count          INTEGER DEFAULT 0,
    state_timestamp      BIGINT,
    error_detail         VARCHAR,
    agreement_id         VARCHAR
        CONSTRAINT contract_negotiation_contract_agreement_id_fk
            REFERENCES edc_contract_agreement,
    contract_offers      JSON,
    callback_addresses   JSON,
    trace_context        JSON,
    pending              BOOLEAN DEFAULT FALSE,
    protocol_messages    JSON,
    lease_id             VARCHAR
        CONSTRAINT contract_negotiation_lease_lease_id_fk
            REFERENCES edc_lease
            ON DELETE SET NULL
);

COMMENT ON COLUMN edc_contract_negotiation.agreement_id IS 'ContractAgreement serialized as JSON';

COMMENT ON COLUMN edc_contract_negotiation.contract_offers IS 'List<ContractOffer> serialized as JSON';

COMMENT ON COLUMN edc_contract_negotiation.trace_context IS 'Map<String,String> serialized as JSON';


CREATE INDEX IF NOT EXISTS contract_negotiation_correlationid_index
    ON edc_contract_negotiation (correlation_id);

CREATE UNIQUE INDEX IF NOT EXISTS contract_negotiation_id_uindex
    ON edc_contract_negotiation (id);

CREATE UNIQUE INDEX IF NOT EXISTS contract_agreement_id_uindex
    ON edc_contract_agreement (agr_id);


-- This will help to identify states that need to be transitioned without a table scan when the entries grow
CREATE INDEX IF NOT EXISTS contract_negotiation_state ON edc_contract_negotiation (state, state_timestamp);

-- dp instance

CREATE TABLE IF NOT EXISTS edc_lease
(
    leased_by      VARCHAR NOT NULL,
    leased_at      BIGINT,
    lease_duration INTEGER NOT NULL,
    lease_id       VARCHAR NOT NULL
        CONSTRAINT lease_pk
            PRIMARY KEY
);


CREATE TABLE IF NOT EXISTS edc_data_plane_instance
(
    id       VARCHAR NOT NULL PRIMARY KEY,
    data     JSON,
    lease_id VARCHAR
        CONSTRAINT data_plane_instance_lease_id_fk
            REFERENCES edc_lease
            ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS edc_policy_monitor
(
    entry_id         VARCHAR           NOT NULL PRIMARY KEY,
    state            INTEGER           NOT NULL,
    created_at       BIGINT            NOT NULL,
    updated_at       BIGINT            NOT NULL,
    state_count      INTEGER DEFAULT 0 NOT NULL,
    state_time_stamp BIGINT,
    trace_context    JSON,
    error_detail     VARCHAR,
    lease_id         VARCHAR
        CONSTRAINT policy_monitor_lease_lease_id_fk
            REFERENCES edc_lease
            ON DELETE SET NULL,
    properties       JSON,
    contract_id      VARCHAR
);


CREATE TABLE IF NOT EXISTS edc_data_plane
(
    process_id       VARCHAR           NOT NULL PRIMARY KEY,
    state            INTEGER           NOT NULL,
    created_at       BIGINT            NOT NULL,
    updated_at       BIGINT            NOT NULL,
    state_count      INTEGER DEFAULT 0 NOT NULL,
    state_time_stamp BIGINT,
    trace_context    JSON,
    error_detail     VARCHAR,
    callback_address VARCHAR,
    lease_id         VARCHAR
        CONSTRAINT data_plane_lease_lease_id_fk
            REFERENCES edc_lease
            ON DELETE SET NULL,
    source           JSON,
    destination      JSON,
    properties       JSON,
    flow_type        VARCHAR
);

COMMENT ON COLUMN edc_data_plane.trace_context IS 'Java Map serialized as JSON';
COMMENT ON COLUMN edc_data_plane.source IS 'DataAddress serialized as JSON';
COMMENT ON COLUMN edc_data_plane.destination IS 'DataAddress serialized as JSON';
COMMENT ON COLUMN edc_data_plane.properties IS 'Java Map serialized as JSON';



CREATE TABLE IF NOT EXISTS edc_accesstokendata
(
    id                    VARCHAR NOT NULL PRIMARY KEY,
    claim_token           JSON    NOT NULL,
    data_address          JSON    NOT NULL,
    additional_properties JSON DEFAULT '{}'
);

COMMENT ON COLUMN edc_accesstokendata.claim_token IS 'ClaimToken serialized as JSON map';
COMMENT ON COLUMN edc_accesstokendata.data_address IS 'DataAddress serialized as JSON map';
COMMENT ON COLUMN edc_accesstokendata.additional_properties IS 'Optional Additional properties serialized as JSON map';
