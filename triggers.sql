-- MISE A JOUR DE BUDGET APRES UNE INSERTION DEPENSE
CREATE OR REPLACE FUNCTION maj_budget_insert_trigger() 
RETURNS TRIGGER 
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_budget_insert
AFTER INSERT ON depense
FOR EACH ROW
EXECUTE FUNCTION maj_budget_insert_trigger();

/............................................................./

-- CREATION D-UNE AUDIT_DEPENSE APRES UNE ACTION FAIT
CREATE OR REPLACE FUNCTION audit_depense_trigger() 
RETURNS TRIGGER 
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER audit_depense
AFTER INSERT OR UPDATE OR DELETE ON depense
FOR EACH ROW
EXECUTE FUNCTION audit_depense_trigger();

/............................................................./

-- INSTRUCTION
Ce déclencheur va enregistrer chaque opération d insertion, 
de mise à jour et de suppression sur la table depense dans la table audit_depense. 
Voici comment cela fonctionne :

Pour une opération d insertion (INSERT), 
il enregistre les informations sur la nouvelle dépense ajoutée.

Pour une opération de mise à jour (UPDATE), 
il enregistre à la fois les anciennes et les nouvelles valeurs de la dépense mise à jour.

Pour une opération de suppression (DELETE), 
il enregistre les informations sur la dépense supprimée.

Le déclencheur est configuré pour se déclencher après chaque insertion, 
mise à jour ou suppression sur la table depense, et il appelle la fonction audit_depense_trigger() 
pour enregistrer les détails de l opération dans la table audit_depense.

/............................................................./

-- SELECTION POSSIBLE
SELECT * FROM etablissement;
SELECT * FROM depense;
SELECT * FROM audit_depense;
SELECT 
    COUNT(CASE WHEN type_action = 'ajout' THEN 1 END) AS nombre_insertions,
    COUNT(CASE WHEN type_action = 'modification' THEN 1 END) AS nombre_modifications,
    COUNT(CASE WHEN type_action = 'suppression' THEN 1 END) AS nombre_suppressions
FROM audit_depense;

