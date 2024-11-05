const supabase = require('../../util/init')

exports.getSpecie = async (specie_id) =>  {
    const { data, error } = await supabase
        .from('specie')
        .select('*')
        .eq('id', specie_id)
        .single()

    return { data, error }
}

exports.getBreed = async (breed_id) => {
    const { data, error } = await supabase
        .from('breed')
        .select('*')
        .eq('id', breed_id)
        .single()

    if (error) {
        throw new Error("fudeu")
    }

    return { data, error }
}

module.exports