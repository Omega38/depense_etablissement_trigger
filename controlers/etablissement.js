const Pool = require('pg').Pool
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'depense_etab',
    password: "tsarafara'2688",
    port: 5432,
})

const getEtab = (request, response) => {
    pool.query('SELECT * FROM etablissement', (error, results) => {
        if (error) {
            throw error
        }
        response.status(200).json(results.rows)
    })
}

const createEtab = (request, response) => {
    const { nom_etab, montant_budget } = request.body

    pool.query("INSERT INTO etablissement (nom_etab, montant_budget ) VALUES ($1, $2)",
        [nom_etab, montant_budget],
        (error, results) => {
            if (error) {
                throw error
            }
            response.status(201).send(`Etablissement ajouter avec ID: ${results.num_etab}`)
        })
}

const updateEtab = (request, response) => {
    const num_etab = parseInt(request.params.num_etab)
    const { nom_etab, montant_budget } = request.body
    pool.query(
        "UPDATE etablissement SET nom_etab = $1, montant_budget = $2 WHERE num_etab = $3",
        [nom_etab, montant_budget, num_etab],
        (error, results) => {
            if (error) {
                throw error
            }
            response.status(200).send(`Etablissement modifier avec ID: ${num_etab}`)
        }
    )
}

const deleteEtab = (request, response) => {
    const num_etab = parseInt(request.params.num_etab)

    pool.query('DELETE FROM etablissement WHERE num_etab = $1',
        [num_etab], (error, results) => {
            if (error) {
                throw error
            }
            response.status(200).send(`Etablissement supprimer avec ID: ${num_etab}`)
        })
}

module.exports = {
    getEtab,
    createEtab,
    updateEtab,
    deleteEtab,
}