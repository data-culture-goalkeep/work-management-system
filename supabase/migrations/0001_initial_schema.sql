--
-- PostgreSQL database dump
--

-- Dumped from database version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.4)
-- Dumped by pg_dump version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.4)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: people-management; Type: SCHEMA; Schema: -; Owner: goalkeep_db_admin
--

CREATE SCHEMA "people-management";

--
-- Name: pgagent; Type: SCHEMA; Schema: -; Owner: goalkeep_db_admin
--

--
-- Name: SCHEMA pgagent; Type: COMMENT; Schema: -; Owner: goalkeep_db_admin
--

--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;

--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';

--
-- Name: trigger_set_timestamp(); Type: FUNCTION; Schema: public; Owner: goalkeep_db_admin
--

CREATE FUNCTION public.trigger_set_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: questions; Type: TABLE; Schema: people-management; Owner: goalkeep_db_admin
--

CREATE TABLE "people-management".questions (
    question_number integer,
    column_name character varying,
    short_form character varying,
    long_form character varying
);

--
-- Name: review_for_individual; Type: TABLE; Schema: people-management; Owner: goalkeep_db_admin
--

CREATE TABLE "people-management".review_for_individual (
    id character varying NOT NULL,
    year_and_quarter character varying,
    review_type character varying,
    filled_for integer,
    filled_by integer,
    created_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    q1_data_driven integer,
    q2_people_focused integer,
    q3_achieve_mission integer,
    q4_given_headsup integer,
    q5_open_to_feedback integer,
    q6_willingness_to_learn integer,
    q7_delivered_high_quality integer,
    q8_relationships integer,
    q9_pm_skills integer,
    q10_problem_solution integer,
    q11_delivering_output integer,
    q12_fun_doing character varying,
    q13_instance_willingness character varying,
    q14_instance_value_added character varying,
    q15_done_better character varying,
    q16_difficult_to_access character varying,
    q17_evidences_examples character varying,
    q18_strengths character varying,
    q19_area_developement character varying,
    q20_there_when_needed integer,
    q21_solutions_provided integer,
    q22_tech_knowledge_support integer,
    q23_timely_responsible_feedback integer,
    q24_feel_respected integer,
    q25_values_input integer,
    q26_give_motivation integer,
    q27_give_freedom integer,
    q28_facilitated_growth integer,
    q29_instance_help character varying,
    q30_instance_did_differently character varying,
    q31_instance_memorable character varying,
    status character varying,
    next_steps character varying,
    q32_value_of_data integer,
    q33_shared_accountability integer,
    q34_strategic_impact integer,
    q35_operational_excellence integer,
    q36_leadership integer,
    q37_relationship_management integer
);

--
-- Name: avg_ratings_by_review_type; Type: VIEW; Schema: people-management; Owner: goalkeep_db_admin
--

CREATE VIEW "people-management".avg_ratings_by_review_type AS
 WITH unpivot_ratings AS (
         SELECT review_for_individual.id AS review_id,
            review_for_individual.filled_for,
            review_for_individual.year_and_quarter,
            review_for_individual.review_type,
            unpivoted.rating,
            unpivoted.question
           FROM ("people-management".review_for_individual
             CROSS JOIN LATERAL ( VALUES (review_for_individual.q1_data_driven,'q1_data_driven'::text), (review_for_individual.q2_people_focused,'q2_people_focused'::text), (review_for_individual.q3_achieve_mission,'q3_achieve_mission'::text), (review_for_individual.q4_given_headsup,'q4_given_headsup'::text), (review_for_individual.q5_open_to_feedback,'q5_open_to_feedback'::text), (review_for_individual.q6_willingness_to_learn,'q6_willingness_to_learn'::text), (review_for_individual.q7_delivered_high_quality,'q7_delivered_high_quality'::text), (review_for_individual.q8_relationships,'q8_relationships'::text), (review_for_individual.q9_pm_skills,'q9_pm_skills'::text), (review_for_individual.q10_problem_solution,'q10_problem_solution'::text), (review_for_individual.q11_delivering_output,'q11_delivering_output'::text), (review_for_individual.q20_there_when_needed,'q20_there_when_needed'::text), (review_for_individual.q21_solutions_provided,'q21_solutions_provided'::text), (review_for_individual.q22_tech_knowledge_support,'q22_tech_knowledge_support'::text), (review_for_individual.q23_timely_responsible_feedback,'q23_timely_responsible_feedback'::text), (review_for_individual.q24_feel_respected,'q24_feel_respected'::text), (review_for_individual.q25_values_input,'q25_values_input'::text), (review_for_individual.q26_give_motivation,'q26_give_motivation'::text), (review_for_individual.q27_give_freedom,'q27_give_freedom'::text), (review_for_individual.q28_facilitated_growth,'q28_facilitated_growth'::text)) unpivoted(rating, question))
          WHERE ((unpivoted.rating IS NOT NULL) AND ((review_for_individual.status)::text = 'Complete'::text))
        ), average_ratings AS (
         SELECT unpivot_ratings.filled_for,
            unpivot_ratings.year_and_quarter,
            unpivot_ratings.review_type,
            unpivot_ratings.question,
            ((((unpivot_ratings.filled_for || '--'::text) || (unpivot_ratings.year_and_quarter)::text) || '--'::text) || unpivot_ratings.question) AS concat_id,
            avg(unpivot_ratings.rating) AS avg_rating,
            count(DISTINCT unpivot_ratings.review_id) AS count_of_responses
           FROM unpivot_ratings
          GROUP BY unpivot_ratings.filled_for, unpivot_ratings.year_and_quarter, unpivot_ratings.review_type, unpivot_ratings.question
          ORDER BY unpivot_ratings.filled_for, unpivot_ratings.year_and_quarter, unpivot_ratings.review_type, unpivot_ratings.question
        ), aggregate_by_question AS (
         SELECT unpivot_ratings.filled_for,
            unpivot_ratings.year_and_quarter,
            (ltrim(split_part(unpivot_ratings.question, '_'::text, 1), 'q'::text))::integer AS question_number,
            avg(unpivot_ratings.rating) AS overall_avg_rating,
            count(DISTINCT unpivot_ratings.review_id) AS count_of_responses
           FROM unpivot_ratings
          GROUP BY unpivot_ratings.filled_for, unpivot_ratings.year_and_quarter, (ltrim(split_part(unpivot_ratings.question, '_'::text, 1), 'q'::text))::integer
          ORDER BY unpivot_ratings.filled_for, unpivot_ratings.year_and_quarter, (ltrim(split_part(unpivot_ratings.question, '_'::text, 1), 'q'::text))::integer
        ), pivot_by_review_type AS (
         SELECT average_ratings.filled_for,
            average_ratings.year_and_quarter,
            (ltrim(split_part(average_ratings.question, '_'::text, 1), 'q'::text))::integer AS question_number,
            max(
                CASE
                    WHEN ((average_ratings.review_type)::text = '1 - For Self'::text) THEN average_ratings.avg_rating
                    ELSE NULL::numeric
                END) AS self_rating,
            max(
                CASE
                    WHEN ((average_ratings.review_type)::text = '2 - For Peer'::text) THEN average_ratings.avg_rating
                    ELSE NULL::numeric
                END) AS peer_rating,
            max(
                CASE
                    WHEN ((average_ratings.review_type)::text = '3 - For Managee'::text) THEN average_ratings.avg_rating
                    ELSE NULL::numeric
                END) AS managee_rating,
            max(
                CASE
                    WHEN ((average_ratings.review_type)::text = '4 - For Manager'::text) THEN average_ratings.avg_rating
                    ELSE NULL::numeric
                END) AS manager_rating
           FROM average_ratings
          GROUP BY average_ratings.filled_for, average_ratings.year_and_quarter, (ltrim(split_part(average_ratings.question, '_'::text, 1), 'q'::text))::integer
          ORDER BY average_ratings.filled_for, average_ratings.year_and_quarter, (ltrim(split_part(average_ratings.question, '_'::text, 1), 'q'::text))::integer
        ), aggregate_by_review_type AS (
         SELECT unpivot_ratings.filled_for,
            unpivot_ratings.year_and_quarter,
            NULL::integer AS question_number,
            NULL::numeric AS self_rating,
            NULL::numeric AS peer_rating,
            NULL::numeric AS managee_rating,
            NULL::numeric AS manager_rating,
            ('Review Type = '::text || (unpivot_ratings.review_type)::text) AS short_form,
                CASE
                    WHEN ((unpivot_ratings.review_type)::text = '1 - For Self'::text) THEN '1 - Overall Rating From Self'::text
                    WHEN ((unpivot_ratings.review_type)::text = '2 - For Peer'::text) THEN '2 - Overall Rating From Peer'::text
                    WHEN ((unpivot_ratings.review_type)::text = '4 - For Manager'::text) THEN '3 - Overall Rating From Managee'::text
                    WHEN ((unpivot_ratings.review_type)::text = '3 - For Managee'::text) THEN '4 - Overall Rating From Manager'::text
                    ELSE NULL::text
                END AS long_form,
            avg(unpivot_ratings.rating) AS overall_rating_by_review_type
           FROM unpivot_ratings
          GROUP BY unpivot_ratings.filled_for, unpivot_ratings.year_and_quarter, NULL::integer, NULL::numeric, ('Review Type = '::text || (unpivot_ratings.review_type)::text),
                CASE
                    WHEN ((unpivot_ratings.review_type)::text = '1 - For Self'::text) THEN '1 - Overall Rating From Self'::text
                    WHEN ((unpivot_ratings.review_type)::text = '2 - For Peer'::text) THEN '2 - Overall Rating From Peer'::text
                    WHEN ((unpivot_ratings.review_type)::text = '4 - For Manager'::text) THEN '3 - Overall Rating From Managee'::text
                    WHEN ((unpivot_ratings.review_type)::text = '3 - For Managee'::text) THEN '4 - Overall Rating From Manager'::text
                    ELSE NULL::text
                END
        ), joined_tables AS (
         SELECT pivot_by_review_type.filled_for,
            pivot_by_review_type.year_and_quarter,
            pivot_by_review_type.question_number,
            pivot_by_review_type.self_rating,
            pivot_by_review_type.peer_rating,
            pivot_by_review_type.managee_rating,
            pivot_by_review_type.manager_rating,
            questions.short_form,
            questions.long_form,
            aggregate_by_question.overall_avg_rating
           FROM ((pivot_by_review_type
             LEFT JOIN "people-management".questions USING (question_number))
             LEFT JOIN aggregate_by_question USING (filled_for, year_and_quarter, question_number))
        )
 SELECT joined_tables.filled_for,
    joined_tables.year_and_quarter,
    joined_tables.question_number,
    joined_tables.self_rating,
    joined_tables.peer_rating,
    joined_tables.managee_rating,
    joined_tables.manager_rating,
    joined_tables.short_form,
    joined_tables.long_form,
    joined_tables.overall_avg_rating
   FROM joined_tables
UNION ALL
 SELECT aggregate_by_review_type.filled_for,
    aggregate_by_review_type.year_and_quarter,
    aggregate_by_review_type.question_number,
    aggregate_by_review_type.self_rating,
    aggregate_by_review_type.peer_rating,
    aggregate_by_review_type.managee_rating,
    aggregate_by_review_type.manager_rating,
    aggregate_by_review_type.short_form,
    aggregate_by_review_type.long_form,
    aggregate_by_review_type.overall_rating_by_review_type AS overall_avg_rating
   FROM aggregate_by_review_type;

--
-- Name: next_steps; Type: TABLE; Schema: people-management; Owner: people_management_user
--

CREATE TABLE "people-management".next_steps (
    id character varying,
    team_member_id integer,
    date date,
    meeting_type character varying,
    meeting_with integer,
    next_steps character varying,
    created_on timestamp with time zone,
    updated_on timestamp with time zone
);

--
-- Name: q12_questions; Type: TABLE; Schema: people-management; Owner: goalkeep_db_admin
--

CREATE TABLE "people-management".q12_questions (
    question_number integer,
    column_name character varying,
    short_form character varying,
    long_form character varying
);

--
-- Name: q12_survey; Type: TABLE; Schema: people-management; Owner: goalkeep_db_admin
--

CREATE TABLE "people-management".q12_survey (
    id character varying NOT NULL,
    year_and_quarter character varying,
    q1_expected_work integer,
    q2_right_materials integer,
    q3_opporunity_do_best integer,
    q4_recieved_recognition integer,
    q5_care_about_me integer,
    q6_encourages_development integer,
    q7_opinions_count integer,
    q8_mission_job_important integer,
    q9_committed_quality_work integer,
    q10_best_friend integer,
    q11_talk_about_progress integer,
    q12_learn_grow integer,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    status character varying,
    q13_anything_else character varying
);

--
-- Name: effort; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.effort (
    id integer NOT NULL,
    team_member_id integer,
    deliverable_id integer,
    week_start_date date,
    "1_monday" numeric,
    "2_tuesday" numeric,
    "3_wednesday" numeric,
    "4_thursday" numeric,
    "5_friday" numeric,
    "6_saturday" numeric,
    "7_sunday" numeric,
    notes character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    billable boolean DEFAULT true,
    team_member_level integer NOT NULL,
    team_member_hourly_rate numeric NOT NULL
);

--
-- Name: airbyte_load_effort_table; Type: VIEW; Schema: public; Owner: goalkeep_db_admin
--

CREATE VIEW public.airbyte_load_effort_table AS
 SELECT effort.id,
    effort.team_member_id,
    effort.deliverable_id,
    effort.week_start_date,
    effort."1_monday",
    effort."2_tuesday",
    effort."3_wednesday",
    effort."4_thursday",
    effort."5_friday",
    effort."6_saturday",
    effort."7_sunday",
    effort.notes,
    effort.created_at,
    effort.updated_at,
    effort.billable
   FROM public.effort;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.clients (
    id integer NOT NULL,
    name character varying,
    type character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    category character varying,
    lead boolean,
    website character varying,
    linkedin_page character varying,
    annual_report character varying,
    annual_budget character varying,
    team_size character varying,
    sector character varying,
    key_metrics_available_on_website boolean,
    ownership_type character varying
);

--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.clients ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.clients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: contact_mappings; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.contact_mappings (
    id integer NOT NULL,
    contact_id integer,
    opportunity_id integer,
    client_id integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: contact_mappings_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.contact_mappings ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.contact_mappings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: contacts; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.contacts (
    name character varying,
    email character varying,
    designation character varying,
    linkedin_page character varying,
    notes character varying,
    org_name character varying,
    opportunity_id integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    id integer NOT NULL
);

--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.contacts ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: deliverables; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.deliverables (
    id integer NOT NULL,
    name character varying,
    project integer,
    start_date_planned date,
    start_date_actual date,
    end_date_planned date,
    end_date_expected_and_actual date,
    status character varying,
    planned_days_level_4 numeric,
    planned_days_level_2 numeric,
    planned_days_level_1 numeric,
    deliverable_type integer,
    next_steps character varying(2048),
    sequence integer,
    review_notes character varying,
    link_to_output character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    planned_days_level_3 numeric,
    deliverable_owner integer,
    mid_sprint_notes character varying,
    end_sprint_notes character varying,
    planned_hours_level_4 numeric,
    planned_hours_level_3 numeric,
    planned_hours_level_2 numeric,
    planned_hours_level_1 numeric,
    planned_hours_level_0 numeric,
    budget_notes character varying,
    reasons_for_budget_or_time_overrun character varying
);

--
-- Name: team_members; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.team_members (
    id integer NOT NULL,
    name character varying,
    join_date date,
    status character varying,
    hours_available_per_week integer,
    email character varying,
    level integer,
    leave_quota integer,
    exit_date date,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    contract_valid_till date,
    reports_to integer,
    hourly_rate numeric,
    current_address character varying,
    pan character varying,
    phone_number_self character varying,
    emergency_contact_info character varying,
    salary_account_info character varying,
    upi_id character varying,
    email_id_personal character varying,
    date_of_birth date
);

--
-- Name: COLUMN team_members.leave_quota; Type: COMMENT; Schema: public; Owner: goalkeep_db_admin
--

COMMENT ON COLUMN public.team_members.leave_quota IS 'Total Leaves Available in Fiscal Year | Adjusted in case of mid-year joins or exits';

--
-- Name: deliverable_days_summary; Type: VIEW; Schema: public; Owner: goalkeep_db_admin
--

CREATE VIEW public.deliverable_days_summary AS
 WITH reported_days_summary AS (
         SELECT deliverables.id,
            team_members.level,
            ((((((((sum(COALESCE(effort."1_monday", (0)::numeric)) + sum(COALESCE(effort."2_tuesday", (0)::numeric))) + sum(COALESCE(effort."3_wednesday", (0)::numeric))) + sum(COALESCE(effort."4_thursday", (0)::numeric))) + sum(COALESCE(effort."5_friday", (0)::numeric))) + sum(COALESCE(effort."6_saturday", (0)::numeric))) + sum(COALESCE(effort."7_sunday", (0)::numeric))))::double precision / (8)::double precision) AS reported_days
           FROM ((public.deliverables
             LEFT JOIN public.effort ON ((deliverables.id = effort.deliverable_id)))
             LEFT JOIN public.team_members ON ((effort.team_member_id = team_members.id)))
          GROUP BY deliverables.id, team_members.level
        ), planned_days_summary AS (
         SELECT deliverables.id,
            planned_days_by_level.planned_days,
            planned_days_by_level.level
           FROM (public.deliverables
             CROSS JOIN LATERAL ( VALUES (deliverables.planned_days_level_4,4), (deliverables.planned_days_level_2,2), (deliverables.planned_days_level_1,1)) planned_days_by_level(planned_days, level))
        )
 SELECT planned_days_summary.id,
    planned_days_summary.level,
    (planned_days_summary.planned_days)::integer AS planned_days,
    reported_days_summary.reported_days,
    ((COALESCE(planned_days_summary.planned_days, (0)::numeric))::double precision - COALESCE(reported_days_summary.reported_days, (0)::double precision)) AS days_remaining,
    (1.0)::double precision AS days_remaining_percent
   FROM (planned_days_summary
     LEFT JOIN reported_days_summary ON (((planned_days_summary.id = reported_days_summary.id) AND (planned_days_summary.level = reported_days_summary.level))));

--
-- Name: deliverable_days_summary_new_test; Type: VIEW; Schema: public; Owner: goalkeep_db_admin
--

CREATE VIEW public.deliverable_days_summary_new_test AS
 WITH reported_days_summary AS (
         SELECT deliverables.id,
            team_members.level,
            ((((((((sum(COALESCE(effort."1_monday", (0)::numeric)) + sum(COALESCE(effort."2_tuesday", (0)::numeric))) + sum(COALESCE(effort."3_wednesday", (0)::numeric))) + sum(COALESCE(effort."4_thursday", (0)::numeric))) + sum(COALESCE(effort."5_friday", (0)::numeric))) + sum(COALESCE(effort."6_saturday", (0)::numeric))) + sum(COALESCE(effort."7_sunday", (0)::numeric))))::double precision / (8)::double precision) AS reported_days
           FROM ((public.deliverables
             LEFT JOIN public.effort ON ((deliverables.id = effort.deliverable_id)))
             LEFT JOIN public.team_members ON ((effort.team_member_id = team_members.id)))
          GROUP BY deliverables.id, team_members.level
        ), planned_days_summary AS (
         SELECT deliverables.id,
            planned_days_by_level.planned_days,
            planned_days_by_level.level
           FROM (public.deliverables
             CROSS JOIN LATERAL ( VALUES (deliverables.planned_days_level_4,4), (deliverables.planned_days_level_2,2), (deliverables.planned_days_level_1,1)) planned_days_by_level(planned_days, level))
        )
 SELECT planned_days_summary.id,
    planned_days_summary.level,
    planned_days_summary.planned_days,
    reported_days_summary.reported_days,
    ((COALESCE(planned_days_summary.planned_days, (0)::numeric))::double precision - COALESCE(reported_days_summary.reported_days, (0)::double precision)) AS days_remaining,
    (1.0)::double precision AS days_remaining_percent
   FROM (planned_days_summary
     LEFT JOIN reported_days_summary ON (((planned_days_summary.id = reported_days_summary.id) AND (planned_days_summary.level = reported_days_summary.level))));

--
-- Name: deliverable_type; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.deliverable_type (
    id integer NOT NULL,
    name character varying,
    status character varying,
    phase character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: deliverables_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.deliverables ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.deliverables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: deliverables_type_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.deliverable_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.deliverables_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: effort_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.effort ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.effort_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: expenses; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.expenses (
    id integer NOT NULL,
    team_member_id integer,
    expense_date date,
    expense_type character varying,
    comments character varying,
    proof_of_expense character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying,
    reimbursement_date character varying,
    reason_if_rejected character varying,
    approved_by integer,
    reimbursement_transferred_by integer,
    amount numeric,
    project_id integer,
    deliverable_id integer,
    paid_by character varying
);

--
-- Name: expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.expenses ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.expenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.invoices (
    id integer NOT NULL,
    invoice_number_on_zoho character varying,
    project_id integer,
    invoice_date_planned date,
    amount_planned numeric,
    invoice_date_actual date,
    amount_actual numeric,
    notes character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    invoice_status character varying,
    new_or_carry_forward character varying
);

--
-- Name: invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.invoices ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: okr_annual_review; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.okr_annual_review (
    id integer NOT NULL,
    kr_id integer,
    reviewed_by integer,
    financial_year text,
    pct_completion numeric,
    grading numeric,
    what_worked_well text,
    what_did_not_work text,
    changes_for_next_year text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

--
-- Name: okr_annual_review_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

CREATE SEQUENCE public.okr_annual_review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: okr_annual_review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: goalkeep_db_admin
--

ALTER SEQUENCE public.okr_annual_review_id_seq OWNED BY public.okr_annual_review.id;

--
-- Name: okr_checkins; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.okr_checkins (
    id integer NOT NULL,
    kr_id integer,
    submitted_by integer,
    quarter text,
    checkin_date date,
    checkin_number integer,
    actual_value character varying,
    bright_spots text,
    dark_spots text,
    what_needs_to_change text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    "start value" character varying,
    target_value character varying
);

--
-- Name: okr_checkins_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

CREATE SEQUENCE public.okr_checkins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: okr_checkins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: goalkeep_db_admin
--

ALTER SEQUENCE public.okr_checkins_id_seq OWNED BY public.okr_checkins.id;

--
-- Name: okr_doers; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.okr_doers (
    id integer NOT NULL,
    kr_id integer NOT NULL,
    team_member_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);

--
-- Name: okr_doers_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

CREATE SEQUENCE public.okr_doers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: okr_doers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: goalkeep_db_admin
--

ALTER SEQUENCE public.okr_doers_id_seq OWNED BY public.okr_doers.id;

--
-- Name: okr_objectives_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

CREATE SEQUENCE public.okr_objectives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: okr_feedback; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.okr_feedback (
    id integer DEFAULT nextval('public.okr_objectives_id_seq'::regclass) NOT NULL,
    feedback_from integer,
    okr_key_result_id integer,
    feedback_text text,
    response_by integer,
    response_text text,
    status text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);

--
-- Name: okr_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

CREATE SEQUENCE public.okr_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: okr_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: goalkeep_db_admin
--

ALTER SEQUENCE public.okr_feedback_id_seq OWNED BY public.okr_feedback.id;

--
-- Name: okr_initiative_staffing; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.okr_initiative_staffing (
    id integer NOT NULL,
    initiative_id integer,
    team_member_id integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    is_owner boolean,
    is_doer boolean,
    is_reviewer boolean,
    is_signoff boolean
);

--
-- Name: okr_initiative_staffing_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

CREATE SEQUENCE public.okr_initiative_staffing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: okr_initiative_staffing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: goalkeep_db_admin
--

ALTER SEQUENCE public.okr_initiative_staffing_id_seq OWNED BY public.okr_initiative_staffing.id;

--
-- Name: okr_initiatives; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.okr_initiatives (
    id integer NOT NULL,
    kr_id integer,
    initiative_name text,
    planned_end_date date,
    status text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    initiative_number character varying,
    objective_id character varying,
    actual_end_date character varying,
    on_track_off_track character varying,
    explain_status character varying
);

--
-- Name: okr_initiatives_v2_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

CREATE SEQUENCE public.okr_initiatives_v2_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: okr_initiatives_v2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: goalkeep_db_admin
--

ALTER SEQUENCE public.okr_initiatives_v2_id_seq OWNED BY public.okr_initiatives.id;

--
-- Name: okr_key_results_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

CREATE SEQUENCE public.okr_key_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: okr_key_results; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.okr_key_results (
    id integer DEFAULT nextval('public.okr_key_results_id_seq'::regclass) NOT NULL,
    kr_number numeric,
    kr_name character varying,
    status character varying,
    target numeric,
    actual numeric,
    unit character varying,
    estimated_hours character varying,
    notes character varying,
    review_1_comments character varying,
    review_2_comments character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    objective_id integer,
    owner_id character varying,
    vertical character varying,
    org_review_comments character varying,
    year_quarter character varying
);

--
-- Name: okr_objectives; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.okr_objectives (
    id integer DEFAULT nextval('public.okr_objectives_id_seq'::regclass) NOT NULL,
    year_quarter character varying,
    objective_name character varying,
    pct_achieved numeric,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    owner_id character varying(50),
    objective_number integer,
    custodian_id character varying,
    objective_narrative character varying
);

--
-- Name: opportunities; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.opportunities (
    id integer NOT NULL,
    org_name character varying,
    opportunity_name character varying,
    contact_name character varying,
    org_website character varying,
    contact_email character varying,
    opportunity_type character varying,
    stage character varying,
    org_type character varying,
    first_contact_date date,
    status character varying,
    closed_date date,
    reason_if_lost character varying,
    opportunity_owner integer,
    referral_type character varying,
    referral_source_internal character varying,
    referral_source_external character varying,
    org_area_of_work character varying,
    opportunity_amount integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    proposal_sent_date date,
    category character varying,
    details character varying,
    qualified_for_project_date date,
    next_follow_up_due_on date,
    rejected_by character varying,
    converted_to_opportunity boolean,
    link_to_slack_notes character varying,
    client_id integer,
    lead_direction character varying,
    potential_revenue character varying,
    other_vendors_involved boolean,
    relationship_with_founder_or_ceo character varying,
    proposal_writing_start_date date,
    goalkeep_offering_pitched character varying,
    link_to_contract character varying
);

--
-- Name: opportunities_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.opportunities ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.opportunities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: projects; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    name character varying,
    client_id integer,
    start_date date,
    start_date_actual date,
    end_date date,
    end_date_actual date,
    status character varying,
    project_manager_id integer,
    contract_status character varying,
    invoice_creation_status character varying,
    opportunity_id integer,
    reviewed_by integer,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    category character varying,
    daily_rate_level_4 integer,
    daily_rate_level_3 integer,
    daily_rate_level_2 integer,
    daily_rate_level_1 integer,
    percent_margin numeric,
    total_invoice_value numeric,
    delivery_method character varying,
    hourly_price_agile numeric,
    effort_ratio_target numeric,
    monthly_billable_hours_reserved numeric,
    effort_ratio_target_analysts numeric,
    upcoming_project_review date,
    upcoming_client_feedback date,
    upcoming_dcr_conversation date,
    hourly_rate_level_4 numeric,
    hourly_rate_level_3 numeric,
    hourly_rate_level_2 numeric,
    hourly_rate_level_1 numeric,
    hourly_rate_level_0 numeric,
    link_to_contract character varying,
    type character varying,
    send_invoices_to character varying,
    budget_for_non_people_costs numeric,
    budget_notes_for_non_people_costs character varying,
    implementation_end_date_planned date,
    implementation_end_date_actual date,
    orgs_reached integer,
    people_trained integer,
    link_to_health_check_doc character varying,
    link_to_oqc_doc character varying
);

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.projects ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: staffing; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.staffing (
    id integer NOT NULL,
    team_member integer,
    project integer,
    status character varying,
    type character varying,
    deliverable integer,
    percent_allocation numeric,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: staffing_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.staffing ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.staffing_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: staffing_monthly; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.staffing_monthly (
    id integer NOT NULL,
    staffing_id integer,
    month_start_date date,
    hours_staffed numeric,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

--
-- Name: staffing_monthly_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.staffing_monthly ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.staffing_monthly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.tasks (
    id integer NOT NULL,
    title character varying,
    due_date date,
    type character varying,
    assigned_to integer,
    opportunity integer,
    project integer,
    deliverable integer,
    description character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    done boolean,
    planned_days_level_4 numeric,
    planned_days_level_3 numeric,
    planned_days_level_2 numeric,
    planned_days_level_1 numeric,
    status character varying,
    date_completed date
);

--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.tasks ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: team_members_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.team_members ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.team_members_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: time_off; Type: TABLE; Schema: public; Owner: goalkeep_db_admin
--

CREATE TABLE public.time_off (
    id integer NOT NULL,
    team_member integer,
    type character varying,
    start_date date,
    end_date date,
    start_was_half_day boolean,
    end_was_half_day boolean,
    comments_if_any character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    team_member_level integer,
    team_member_hourly_rate numeric
);

--
-- Name: time_off_id_seq; Type: SEQUENCE; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE public.time_off ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.time_off_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

--
-- Name: weekly_effort_table_update; Type: VIEW; Schema: public; Owner: goalkeep_db_admin
--

CREATE VIEW public.weekly_effort_table_update AS
 SELECT staffing.team_member AS team_member_id,
    deliverables.id AS deliverable_id,
    (date_trunc('week'::text, now()))::date AS week_start_date,
    team_members.level AS team_member_level,
    team_members.hourly_rate AS team_member_hourly_rate
   FROM (((public.staffing
     LEFT JOIN public.deliverables ON ((deliverables.project = staffing.project)))
     LEFT JOIN public.projects ON ((projects.id = deliverables.project)))
     LEFT JOIN public.team_members ON ((staffing.team_member = team_members.id)))
  WHERE (((staffing.status)::text = 'Active'::text) AND ((deliverables.status)::text = 'In Progress'::text) AND ((projects.status)::text = 'Active'::text) AND ((staffing.type)::text = 'Project'::text) AND ((team_members.status)::text = 'Active'::text))
UNION ALL
 SELECT staffing.team_member AS team_member_id,
    deliverables.id AS deliverable_id,
    (date_trunc('week'::text, now()))::date AS week_start_date,
    team_members.level AS team_member_level,
    team_members.hourly_rate AS team_member_hourly_rate
   FROM (((public.staffing
     LEFT JOIN public.deliverables ON ((deliverables.id = staffing.deliverable)))
     LEFT JOIN public.projects ON ((projects.id = deliverables.project)))
     LEFT JOIN public.team_members ON ((staffing.team_member = team_members.id)))
  WHERE (((staffing.status)::text = 'Active'::text) AND ((deliverables.status)::text = 'In Progress'::text) AND ((projects.status)::text = 'Active'::text) AND ((staffing.type)::text = 'Deliverable'::text) AND ((team_members.status)::text = 'Active'::text));

--
-- Name: okr_annual_review id; Type: DEFAULT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_annual_review ALTER COLUMN id SET DEFAULT nextval('public.okr_annual_review_id_seq'::regclass);

--
-- Name: okr_checkins id; Type: DEFAULT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_checkins ALTER COLUMN id SET DEFAULT nextval('public.okr_checkins_id_seq'::regclass);

--
-- Name: okr_doers id; Type: DEFAULT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_doers ALTER COLUMN id SET DEFAULT nextval('public.okr_doers_id_seq'::regclass);

--
-- Name: okr_initiative_staffing id; Type: DEFAULT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_initiative_staffing ALTER COLUMN id SET DEFAULT nextval('public.okr_initiative_staffing_id_seq'::regclass);

--
-- Name: okr_initiatives id; Type: DEFAULT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_initiatives ALTER COLUMN id SET DEFAULT nextval('public.okr_initiatives_v2_id_seq'::regclass);

--
-- Name: review_for_individual review_for_individual_pk; Type: CONSTRAINT; Schema: people-management; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY "people-management".review_for_individual
    ADD CONSTRAINT review_for_individual_pk PRIMARY KEY (id);

--
-- Name: clients client_name_unique; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT client_name_unique UNIQUE (name);

--
-- Name: clients clients_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pk PRIMARY KEY (id);

--
-- Name: contact_mappings contact_mappings_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.contact_mappings
    ADD CONSTRAINT contact_mappings_pk PRIMARY KEY (id);

--
-- Name: contacts contacts_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pk PRIMARY KEY (id);

--
-- Name: deliverables deliverables_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.deliverables
    ADD CONSTRAINT deliverables_pk PRIMARY KEY (id);

--
-- Name: deliverable_type deliverables_type_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.deliverable_type
    ADD CONSTRAINT deliverables_type_pk PRIMARY KEY (id);

--
-- Name: effort effort_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.effort
    ADD CONSTRAINT effort_pk PRIMARY KEY (id);

--
-- Name: effort effort_unique_key; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.effort
    ADD CONSTRAINT effort_unique_key UNIQUE (team_member_id, deliverable_id, week_start_date);

--
-- Name: expenses expenses_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_pk PRIMARY KEY (id);

--
-- Name: invoices invoices_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pk PRIMARY KEY (id);

--
-- Name: okr_annual_review okr_annual_review_pkey; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_annual_review
    ADD CONSTRAINT okr_annual_review_pkey PRIMARY KEY (id);

--
-- Name: okr_checkins okr_checkins_pkey; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_checkins
    ADD CONSTRAINT okr_checkins_pkey PRIMARY KEY (id);

--
-- Name: okr_doers okr_doers_pkey; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_doers
    ADD CONSTRAINT okr_doers_pkey PRIMARY KEY (id);

--
-- Name: okr_feedback okr_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_feedback
    ADD CONSTRAINT okr_feedback_pkey PRIMARY KEY (id);

--
-- Name: okr_initiative_staffing okr_initiative_staffing_pkey; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_initiative_staffing
    ADD CONSTRAINT okr_initiative_staffing_pkey PRIMARY KEY (id);

--
-- Name: okr_initiatives okr_initiatives_v2_pkey; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_initiatives
    ADD CONSTRAINT okr_initiatives_v2_pkey PRIMARY KEY (id);

--
-- Name: okr_key_results okr_key_results_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_key_results
    ADD CONSTRAINT okr_key_results_pk PRIMARY KEY (id);

--
-- Name: okr_objectives okr_objectives_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_objectives
    ADD CONSTRAINT okr_objectives_pk PRIMARY KEY (id);

--
-- Name: opportunities opportunities_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT opportunities_pk PRIMARY KEY (id);

--
-- Name: projects projects_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pk PRIMARY KEY (id);

--
-- Name: staffing_monthly staffing_monthly_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.staffing_monthly
    ADD CONSTRAINT staffing_monthly_pk PRIMARY KEY (id);

--
-- Name: staffing staffing_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.staffing
    ADD CONSTRAINT staffing_pk PRIMARY KEY (id);

--
-- Name: tasks tasks_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pk PRIMARY KEY (id);

--
-- Name: team_members team_members_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.team_members
    ADD CONSTRAINT team_members_pk PRIMARY KEY (id);

--
-- Name: time_off time_off_pk; Type: CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.time_off
    ADD CONSTRAINT time_off_pk PRIMARY KEY (id);

--
-- Name: okr_doers created_at; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER created_at AFTER INSERT ON public.okr_doers FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: okr_feedback created_at; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER created_at AFTER INSERT ON public.okr_feedback FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: okr_initiative_staffing created_at; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER created_at AFTER INSERT ON public.okr_initiative_staffing FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: okr_initiatives created_at; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER created_at AFTER INSERT ON public.okr_initiatives FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: okr_key_results created_at; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER created_at AFTER INSERT ON public.okr_key_results FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: okr_objectives created_at; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER created_at AFTER INSERT ON public.okr_objectives FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: clients set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.clients FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: contact_mappings set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.contact_mappings FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: contacts set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.contacts FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: deliverable_type set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.deliverable_type FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: deliverables set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.deliverables FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: effort set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.effort FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: expenses set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.expenses FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: invoices set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.invoices FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: opportunities set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.opportunities FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: projects set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: staffing set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.staffing FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: staffing_monthly set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.staffing_monthly FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: tasks set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.tasks FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: team_members set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.team_members FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: time_off set_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON public.time_off FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: deliverables update_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER update_timestamp BEFORE UPDATE ON public.deliverables FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: okr_doers update_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER update_timestamp BEFORE UPDATE ON public.okr_doers FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: okr_feedback update_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER update_timestamp BEFORE UPDATE ON public.okr_feedback FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: okr_initiative_staffing update_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER update_timestamp BEFORE UPDATE ON public.okr_initiative_staffing FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: okr_initiatives update_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER update_timestamp BEFORE UPDATE ON public.okr_initiatives FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: okr_objectives update_timestamp; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER update_timestamp BEFORE UPDATE ON public.okr_objectives FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: okr_key_results updated_at; Type: TRIGGER; Schema: public; Owner: goalkeep_db_admin
--

CREATE TRIGGER updated_at BEFORE UPDATE ON public.okr_key_results FOR EACH ROW EXECUTE FUNCTION public.trigger_set_timestamp();

--
-- Name: deliverables deliverables_fk_deliverable_type; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.deliverables
    ADD CONSTRAINT deliverables_fk_deliverable_type FOREIGN KEY (deliverable_type) REFERENCES public.deliverable_type(id);

--
-- Name: deliverables deliverables_fk_projects; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.deliverables
    ADD CONSTRAINT deliverables_fk_projects FOREIGN KEY (project) REFERENCES public.projects(id);

--
-- Name: deliverables deliverables_fk_team_members; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.deliverables
    ADD CONSTRAINT deliverables_fk_team_members FOREIGN KEY (deliverable_owner) REFERENCES public.team_members(id);

--
-- Name: effort effort_fk_deliverables; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.effort
    ADD CONSTRAINT effort_fk_deliverables FOREIGN KEY (deliverable_id) REFERENCES public.deliverables(id);

--
-- Name: effort effort_fk_team_member; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.effort
    ADD CONSTRAINT effort_fk_team_member FOREIGN KEY (team_member_id) REFERENCES public.team_members(id);

--
-- Name: expenses expenses_fk; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_fk FOREIGN KEY (team_member_id) REFERENCES public.team_members(id);

--
-- Name: okr_doers okr_doers_kr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_doers
    ADD CONSTRAINT okr_doers_kr_id_fkey FOREIGN KEY (kr_id) REFERENCES public.okr_key_results(id);

--
-- Name: okr_doers okr_doers_team_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_doers
    ADD CONSTRAINT okr_doers_team_member_id_fkey FOREIGN KEY (team_member_id) REFERENCES public.team_members(id);

--
-- Name: okr_feedback okr_feedback_feedback_from_fkey; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_feedback
    ADD CONSTRAINT okr_feedback_feedback_from_fkey FOREIGN KEY (feedback_from) REFERENCES public.team_members(id);

--
-- Name: okr_feedback okr_feedback_okr_key_result_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_feedback
    ADD CONSTRAINT okr_feedback_okr_key_result_id_fkey FOREIGN KEY (okr_key_result_id) REFERENCES public.okr_key_results(id);

--
-- Name: okr_feedback okr_feedback_response_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.okr_feedback
    ADD CONSTRAINT okr_feedback_response_by_fkey FOREIGN KEY (response_by) REFERENCES public.team_members(id);

--
-- Name: opportunities opportunities_fk; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT opportunities_fk FOREIGN KEY (opportunity_owner) REFERENCES public.team_members(id);

--
-- Name: projects projects_fk_clients; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_fk_clients FOREIGN KEY (client_id) REFERENCES public.clients(id);

--
-- Name: projects projects_fk_reviewer; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_fk_reviewer FOREIGN KEY (reviewed_by) REFERENCES public.team_members(id);

--
-- Name: projects projects_fk_team_member; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_fk_team_member FOREIGN KEY (project_manager_id) REFERENCES public.team_members(id);

--
-- Name: staffing staffing_fk; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.staffing
    ADD CONSTRAINT staffing_fk FOREIGN KEY (team_member) REFERENCES public.team_members(id);

--
-- Name: tasks tasks_fk; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_fk FOREIGN KEY (opportunity) REFERENCES public.opportunities(id);

--
-- Name: tasks tasks_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_fk_1 FOREIGN KEY (project) REFERENCES public.projects(id);

--
-- Name: tasks tasks_fk_2; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_fk_2 FOREIGN KEY (deliverable) REFERENCES public.deliverables(id);

--
-- Name: tasks tasks_fk_3; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_fk_3 FOREIGN KEY (assigned_to) REFERENCES public.team_members(id);

--
-- Name: time_off time_off_fk; Type: FK CONSTRAINT; Schema: public; Owner: goalkeep_db_admin
--

ALTER TABLE ONLY public.time_off
    ADD CONSTRAINT time_off_fk FOREIGN KEY (team_member) REFERENCES public.team_members(id);

--
-- Name: SCHEMA "people-management"; Type: ACL; Schema: -; Owner: goalkeep_db_admin
--

--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

--
-- Name: TABLE review_for_individual; Type: ACL; Schema: people-management; Owner: goalkeep_db_admin
--

--
-- Name: TABLE next_steps; Type: ACL; Schema: people-management; Owner: people_management_user
--

--
-- Name: TABLE q12_questions; Type: ACL; Schema: people-management; Owner: goalkeep_db_admin
--

--
-- Name: TABLE q12_survey; Type: ACL; Schema: people-management; Owner: goalkeep_db_admin
--

--
-- Name: SEQUENCE clients_id_seq; Type: ACL; Schema: public; Owner: goalkeep_db_admin
--

--
-- Name: TABLE projects; Type: ACL; Schema: public; Owner: goalkeep_db_admin
--

--
-- PostgreSQL database dump complete
--


-- PoC access model: no row-level security yet (filtering happens in trusted
-- Next.js server code using the service_role key). Revoke the default
-- PostgREST grants so the public anon key cannot read/write these tables
-- directly from a browser.
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon, authenticated;
REVOKE ALL ON ALL TABLES IN SCHEMA "people-management" FROM anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon, authenticated;
