PGDMP                         |            depense_etab    15.1    15.1                0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false                       0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false                       1262    16398    depense_etab    DATABASE        CREATE DATABASE depense_etab WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'French_France.1252';
    DROP DATABASE depense_etab;
                postgres    false            �            1255    24600    audit_depense_trigger()    FUNCTION     �  CREATE FUNCTION public.audit_depense_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE
nouv_nom_etablissement VARCHAR;
ancien_nom_etablissement VARCHAR;

BEGIN
    SELECT DISTINCT etablissement.nom_etab INTO nouv_nom_etablissement
    FROM etablissement INNER JOIN depense ON etablissement.num_etab = depense.num_etab
    WHERE depense.num_etab = NEW.num_etab;

    SELECT DISTINCT etablissement.nom_etab INTO ancien_nom_etablissement
    FROM etablissement INNER JOIN depense ON etablissement.num_etab = depense.num_etab
    WHERE depense.num_etab = OLD.num_etab;

    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_depense(type_action, date_operation, num_dep, nom_etab, nouv_liste_depense, utilisateur)
        VALUES ('ajout', CURRENT_TIMESTAMP, NEW.num_dep, nouv_nom_etablissement, NEW.liste_depense, current_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_depense(type_action, date_operation, num_dep, nom_etab, ancien_liste_depense, nouv_liste_depense, utilisateur)
        VALUES ('modification', CURRENT_TIMESTAMP, NEW.num_dep, nouv_nom_etablissement, OLD.liste_depense, NEW.liste_depense, current_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_depense(type_action, date_operation, num_dep, nom_etab, ancien_liste_depense, utilisateur)
        VALUES ('suppression', CURRENT_TIMESTAMP, OLD.num_dep, ancien_nom_etablissement, OLD.liste_depense, current_user);
    END IF;
    RETURN NULL;
END;
$$;
 .   DROP FUNCTION public.audit_depense_trigger();
       public          postgres    false            �            1255    24598    maj_budget_insert_trigger()    FUNCTION     �  CREATE FUNCTION public.maj_budget_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    ancienne_depense INT;
BEGIN
    SELECT COALESCE(SUM(liste_depense), 0) INTO ancienne_depense
    FROM depense
    WHERE num_etab = NEW.num_etab;

    UPDATE etablissement
    SET montant_budget = montant_budget + NEW.liste_depense - ancienne_depense
    WHERE num_etab = NEW.num_etab;

    RETURN NEW;
END;
$$;
 2   DROP FUNCTION public.maj_budget_insert_trigger();
       public          postgres    false            �            1259    16425    audit_depense    TABLE       CREATE TABLE public.audit_depense (
    type_action character varying NOT NULL,
    date_operation date,
    num_dep integer,
    nom_etab character varying,
    ancien_liste_depense integer,
    nouv_liste_depense integer,
    utilisateur character varying
);
 !   DROP TABLE public.audit_depense;
       public         heap    postgres    false            �            1259    16414    depense    TABLE     o   CREATE TABLE public.depense (
    num_dep integer NOT NULL,
    num_etab integer,
    liste_depense integer
);
    DROP TABLE public.depense;
       public         heap    postgres    false            �            1259    16413    depense_num_dep_seq    SEQUENCE     �   CREATE SEQUENCE public.depense_num_dep_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.depense_num_dep_seq;
       public          postgres    false    217                       0    0    depense_num_dep_seq    SEQUENCE OWNED BY     K   ALTER SEQUENCE public.depense_num_dep_seq OWNED BY public.depense.num_dep;
          public          postgres    false    216            �            1259    16400    etablissement    TABLE     �   CREATE TABLE public.etablissement (
    num_etab integer NOT NULL,
    nom_etab character varying(150) NOT NULL,
    montant_budget integer NOT NULL
);
 !   DROP TABLE public.etablissement;
       public         heap    postgres    false            �            1259    16399    etablissement_num_etab_seq    SEQUENCE     �   CREATE SEQUENCE public.etablissement_num_etab_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.etablissement_num_etab_seq;
       public          postgres    false    215                       0    0    etablissement_num_etab_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public.etablissement_num_etab_seq OWNED BY public.etablissement.num_etab;
          public          postgres    false    214            q           2604    24614    depense num_dep    DEFAULT     r   ALTER TABLE ONLY public.depense ALTER COLUMN num_dep SET DEFAULT nextval('public.depense_num_dep_seq'::regclass);
 >   ALTER TABLE public.depense ALTER COLUMN num_dep DROP DEFAULT;
       public          postgres    false    217    216    217            p           2604    16403    etablissement num_etab    DEFAULT     �   ALTER TABLE ONLY public.etablissement ALTER COLUMN num_etab SET DEFAULT nextval('public.etablissement_num_etab_seq'::regclass);
 E   ALTER TABLE public.etablissement ALTER COLUMN num_etab DROP DEFAULT;
       public          postgres    false    215    214    215                      0    16425    audit_depense 
   TABLE DATA           �   COPY public.audit_depense (type_action, date_operation, num_dep, nom_etab, ancien_liste_depense, nouv_liste_depense, utilisateur) FROM stdin;
    public          postgres    false    218   �"       
          0    16414    depense 
   TABLE DATA           C   COPY public.depense (num_dep, num_etab, liste_depense) FROM stdin;
    public          postgres    false    217   g#                 0    16400    etablissement 
   TABLE DATA           K   COPY public.etablissement (num_etab, nom_etab, montant_budget) FROM stdin;
    public          postgres    false    215   �#                  0    0    depense_num_dep_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.depense_num_dep_seq', 26, true);
          public          postgres    false    216                       0    0    etablissement_num_etab_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.etablissement_num_etab_seq', 3, true);
          public          postgres    false    214            u           2606    24616    depense depense_pkey 
   CONSTRAINT     W   ALTER TABLE ONLY public.depense
    ADD CONSTRAINT depense_pkey PRIMARY KEY (num_dep);
 >   ALTER TABLE ONLY public.depense DROP CONSTRAINT depense_pkey;
       public            postgres    false    217            s           2606    16405     etablissement etablissement_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.etablissement
    ADD CONSTRAINT etablissement_pkey PRIMARY KEY (num_etab);
 J   ALTER TABLE ONLY public.etablissement DROP CONSTRAINT etablissement_pkey;
       public            postgres    false    215            w           2620    24601    depense audit_depense    TRIGGER     �   CREATE TRIGGER audit_depense AFTER INSERT OR DELETE OR UPDATE ON public.depense FOR EACH ROW EXECUTE FUNCTION public.audit_depense_trigger();
 .   DROP TRIGGER audit_depense ON public.depense;
       public          postgres    false    217    231            x           2620    24599    depense update_budget_insert    TRIGGER     �   CREATE TRIGGER update_budget_insert AFTER INSERT ON public.depense FOR EACH ROW EXECUTE FUNCTION public.maj_budget_insert_trigger();
 5   DROP TRIGGER update_budget_insert ON public.depense;
       public          postgres    false    217    219            v           2606    16420    depense depense_num_etab_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.depense
    ADD CONSTRAINT depense_num_etab_fkey FOREIGN KEY (num_etab) REFERENCES public.etablissement(num_etab);
 G   ALTER TABLE ONLY public.depense DROP CONSTRAINT depense_num_etab_fkey;
       public          postgres    false    215    3187    217               |   x�K��/-�4202�50�52�"ϐP�?NS �,�/.I/J-�J�PiSibjbb��47?%3-39�$3?Y�1X�%�TKd��K
�t1�jCNW?ONC#�;���`
�`naibj��!F��� �>j      
   >   x����@�o�M�K����|=+7�nӐ`_g
���P�b�P]�g���= ~"�         *   x�3�t���441�4�031�2��	�4��45 �=... ��     