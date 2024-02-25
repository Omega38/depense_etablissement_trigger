const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors')
const port = process.env.PORT || 3000
const app = express()

const etablissement = require('./controlers/etablissement')
const depense = require('./controlers/depense')
const audit_depense = require('./controlers/audit_depense')
const action_stat = require('./controlers/action_stat')

app.use(bodyParser.json())
app.use(
    bodyParser.urlencoded({
        extended: true,
    })
)

//Pour écouter des autres port
app.use(cors())

//etablissement
app.get('/etablissement', etablissement.getEtab)
app.post('/etablissement', etablissement.createEtab)
app.put('/etablissement/:num_etab', etablissement.updateEtab)
app.delete('/etablissement/:num_etab', etablissement.deleteEtab)

//depense
app.get('/depense', depense.getDep)
app.post('/depense', depense.createDep)
app.put('/depense/:num_dep', depense.updateDep)
app.delete('/depense/:num_dep', depense.deleteDep)

//audit_depense
app.get('/audit_depense', audit_depense.getAudit)

//action_stat
app.get('/action_stat', action_stat.getAction)

//Ecoute sur le port
app.listen(port, () => {
    console.log(`Ecoute sur le port ${port}.`)
})

