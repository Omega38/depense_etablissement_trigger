const Pool = require('pg').Pool
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'depense_etab',
    password: "tsarafara'2688",
    port: 5432,
})

const getAudit = (request, response) => {
    pool.query('SELECT * FROM audit_depense', (error, results) => {
        if (error) {
            throw error
        }
        response.status(200).json(results.rows)
    })
}

module.exports = {
    getAudit,
}