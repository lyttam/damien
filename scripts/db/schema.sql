/**
 * Copyright ©2022. The Regents of the University of California (Regents). All Rights Reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its documentation
 * for educational, research, and not-for-profit purposes, without fee and without a
 * signed licensing agreement, is hereby granted, provided that the above copyright
 * notice, this paragraph and the following two paragraphs appear in all copies,
 * modifications, and distributions.
 *
 * Contact The Office of Technology Licensing, UC Berkeley, 2150 Shattuck Avenue,
 * Suite 510, Berkeley, CA 94720-1620, (510) 643-7201, otl@berkeley.edu,
 * http://ipira.berkeley.edu/industry-info for commercial licensing opportunities.
 *
 * IN NO EVENT SHALL REGENTS BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL,
 * INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF
 * THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF REGENTS HAS BEEN ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * REGENTS SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
 * SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED
 * "AS IS". REGENTS HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
 * ENHANCEMENTS, OR MODIFICATIONS.
 */

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;
SET search_path = public, pg_catalog;
SET default_tablespace = '';
SET default_with_oids = false;

--

CREATE TABLE department_catalog_listings (
    id integer NOT NULL,
    department_id integer NOT NULL,
    subject_area VARCHAR(255) NOT NULL,
    catalog_id VARCHAR(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL  
);

CREATE SEQUENCE department_catalog_listings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE department_catalog_listings_id_seq OWNED BY department_catalog_listings.id;
ALTER TABLE ONLY department_catalog_listings ALTER COLUMN id SET DEFAULT nextval('department_catalog_listings_id_seq'::regclass);

ALTER TABLE ONLY department_catalog_listings
    ADD CONSTRAINT department_catalog_listings_pkey PRIMARY KEY (id);

CREATE INDEX department_catalog_listings_department_id_idx ON department_catalog_listings USING btree (department_id);
CREATE INDEX department_catalog_listings_subject_area_idx ON department_catalog_listings USING btree (subject_area);

--

CREATE TABLE department_forms (
    id integer NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);

CREATE SEQUENCE department_forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE department_forms_id_seq OWNED BY department_forms.id;
ALTER TABLE ONLY department_forms ALTER COLUMN id SET DEFAULT nextval('department_forms_id_seq'::regclass);

ALTER TABLE ONLY department_forms
    ADD CONSTRAINT department_forms_pkey PRIMARY KEY (id);
ALTER TABLE ONLY department_forms
    ADD CONSTRAINT department_forms_name_unique UNIQUE (name);

--

CREATE TABLE department_members (
    department_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL    
);

ALTER TABLE ONLY department_members
    ADD CONSTRAINT department_members_pkey PRIMARY KEY (department_id, user_id);

--

CREATE TABLE departments (
    id integer NOT NULL,
    dept_name character varying(255) NOT NULL,
    is_enrolled boolean NOT NULL DEFAULT FALSE,
    note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE SEQUENCE departments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE departments_id_seq OWNED BY departments.id;
ALTER TABLE ONLY departments ALTER COLUMN id SET DEFAULT nextval('departments_id_seq'::regclass);

ALTER TABLE ONLY departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (id);

--

CREATE TABLE evaluation_types (
    id integer NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);

CREATE SEQUENCE evaluation_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE evaluation_types_id_seq OWNED BY evaluation_types.id;
ALTER TABLE ONLY evaluation_types ALTER COLUMN id SET DEFAULT nextval('evaluation_types_id_seq'::regclass);

ALTER TABLE ONLY evaluation_types
    ADD CONSTRAINT evaluation_types_pkey PRIMARY KEY (id);
ALTER TABLE ONLY evaluation_types
    ADD CONSTRAINT evaluation_types_name_unique UNIQUE (name);

--

CREATE TYPE evaluation_status AS ENUM ('marked', 'confirmed', 'deleted');

CREATE TABLE evaluations (
    term_id VARCHAR(4) NOT NULL,
    course_number VARCHAR(5) NOT NULL,
    instructor_uid VARCHAR(80),
    status evaluation_status,
    department_form_id INTEGER,
    evaluation_type_id INTEGER,
    start_date DATE,
    end_date DATE,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying(255),
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by character varying(255)
);

ALTER TABLE ONLY evaluations
    ADD CONSTRAINT evaluations_pkey PRIMARY KEY (term_id, course_number, instructor_uid);

--

CREATE TABLE users (
    id integer NOT NULL,
    csid character varying(255) NOT NULL,
    uid character varying(255) NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    is_admin boolean,
    can_receive_communications boolean,
    can_view_response_rates boolean,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE users_id_seq OWNED BY users.id;
ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

--

ALTER TABLE ONLY department_catalog_listings
    ADD CONSTRAINT department_catalog_listings_department_id_fkey FOREIGN KEY (department_id) REFERENCES departments(id);

ALTER TABLE ONLY department_members
    ADD CONSTRAINT department_members_department_id_fkey FOREIGN KEY (department_id) REFERENCES departments(id);
ALTER TABLE ONLY department_members
    ADD CONSTRAINT department_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE ONLY evaluations
    ADD CONSTRAINT evaluations_department_form_id_fkey FOREIGN KEY (department_form_id) REFERENCES department_forms(id);
ALTER TABLE ONLY evaluations
    ADD CONSTRAINT evaluations_evaluation_type_fkey FOREIGN KEY (evaluation_type_id) REFERENCES evaluation_types(id);
