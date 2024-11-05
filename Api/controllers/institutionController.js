const supabase = require('../util/init')

exports.getInstitution = (('/'), async (req, res) => {
    const id = req.query.id
    if(!id){
        return res.status(400).json({error: 'id is needed'})
    }
    const { data, error } = await supabase 
        .from('institution')
        .select('*')
        .eq('id', id)
        .single()
    
    if(error){
        return res.status(500).json({error})
    }

    return res.status(200).json(data)
})

exports.getInstitutions = (('/'), async (req, res) => { 
    const n = (req.query.n) ? req.query.n : 50 // número máximo de registros  ; DEFAULT = 50

    const { data, error } = await supabase 
        .from('institution')
        .select('*')
        .limit(n)
    
    if(error){
        return res.status(500).json(error)
    }

    return res.status(200).json(data)
})

exports.createInstitution = (('/'), async (req, res) => {
    const { name, cnpj, description, image_url } = req.body

    if(!name || !cnpj ){
        return res.status(400).json({error: '[name, cnpj] are needed'})
    }
    if(!validaCNPJ(cnpj)){
        return res.status(400).json({error: 'invalid cnpj'})
    }

    const { data, error } = await supabase
        .from('institution')
        .insert({name, cnpj, description, image_url})
        .select()

    if(error){
        return res.status(500).json({error})
    }

    return res.status(200).json({data})
})

exports.patchInstitution = (('/'), async (req, res) => {
    const { name, cnpj, description, image_url } = req.body
    const updateData = {}

    if(!cnpj ){
        return res.status(400).json({error: 'cnpj is needed'})
    }
    if(!validaCNPJ(cnpj)){
        return res.status(400).json({error: 'invalid cnpj'})
    }

    if(name) updateData.name = name 
    if(description) updateData.description = description
    if(image_url) updateData.image_url = image_url
    if(cnpj) updateData.cnpj = cnpj

    {
        const { error } = await supabase
            .from('institution')
            .select('id')
            .eq('cnpj', cnpj)
        
        if(error) return res.status(400).json({error})
    }

    const { data, error } = await supabase
        .from('institution')
        .insert(updateData)
        .select()

    if(error){
        return res.status(500).json({error})
    }

    return res.status(200).json({data})
})

exports.deleteInstitution = (('/'), async (req, res) => {
    const { id } = req.body 
    if(!id){
        return res.status(400).json({error: 'institution id is needed'})
    }

    const { data, error } = await supabase 
        .from('institution')
        .delete()
        .eq('id', id)

    if(error){
        return res.status(500).json({error})
    }

    return res.status(200).json({data})
})

const validaCNPJ = (cnpj) => {
    var b = [ 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 ]
    var c = String(cnpj).replace(/[^\d]/g, '')
    
    if(c.length !== 14)
        return false

    if(/0{14}/.test(c))
        return false

    for (var i = 0, n = 0; i < 12; n += c[i] * b[++i]);
    if(c[12] != (((n %= 11) < 2) ? 0 : 11 - n))
        return false

    for (var i = 0, n = 0; i <= 12; n += c[i] * b[i++]);
    if(c[13] != (((n %= 11) < 2) ? 0 : 11 - n))
        return false

    return true
}