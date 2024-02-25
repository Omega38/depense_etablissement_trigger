const Pool = require('pg').Pool
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'depense_etab',
    password: "tsarafara'2688",
    port: 5432,
})

const getAction = (request, response) => {
    pool.query(
        "SELECT COUNT(CASE WHEN type_action = 'ajout' THEN 1 END) AS nombre_insertions, COUNT(CASE WHEN type_action = 'modification' THEN 1 END) AS nombre_modifications, COUNT(CASE WHEN type_action = 'suppression' THEN 1 END) AS nombre_suppressions FROM audit_depense",
        (error, results) => {
            if (error) {
                throw error
            }
            response.status(200).json(results.rows)
        })
}

module.exports = {
    getAction,
}