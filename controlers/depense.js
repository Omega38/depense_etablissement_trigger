const Pool = require('pg').Pool
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'depense_etab',
    password: "tsarafara'2688",
    port: 5432,
})

const getDep = (request, response) => {
    pool.query('SELECT * FROM depense', (error, results) => {
        if (error) {
            throw error
        }
        response.status(200).json(results.rows)
    })
}

const createDep = (request, response) => {
    const { num_etab, liste_depense } = request.body

    pool.query("INSERT INTO depense (num_etab, liste_depense ) VALUES ($1, $2)",
        [num_etab, liste_depense],
        (error, results) => {
            if (error) {
                throw error
            }
            response.status(201).send(`Depense ajouter avec ID: ${results.num_dep}`)
        })
}

const updateDep = (request, response) => {
    const num_dep = parseInt(request.params.num_dep)
    const { num_etab, liste_depense } = request.body
    pool.query(
        "UPDATE depense SET num_etab = $1, liste_depense = $2 WHERE num_dep = $3",
        [num_etab, liste_depense, num_dep],
        (error, results) => {
            if (error) {
                throw error
            }
            response.status(200).send(`Etablissement modifier avec ID: ${num_etab}`)
        }
    )
}

const deleteDep = (request, response) => {
    const num_dep = parseInt(request.params.num_dep)

    pool.query('DELETE FROM depense WHERE num_dep = $1',
        [num_dep], (error, results) => {
            if (error) {
                throw error
            }
            response.status(200).send(`Depense supprimer avec ID: ${num_dep}`)
        })
}

module.exports = {
    getDep,
    createDep,
    updateDep,
    deleteDep
}