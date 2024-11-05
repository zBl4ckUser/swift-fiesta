const supabase = require('../util/init');

// 1. Rota para buscar todas as espécies
exports.getSpecies = async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('specie')
            .select('id, name');

        if (error) throw error;

        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ message: 'Erro ao buscar espécies', error: error.message });
    }
};

// 2. Rota para buscar uma espécie pelo ID
exports.getSpecieById = async (req, res) => {
    const { specieId } = req.params;
    try {
        const { data, error } = await supabase
            .from('specie')
            .select('id, name')
            .eq('id', specieId)
            .single();

        if (error) throw error;

        res.status(200).json({ specie: data });
    } catch (error) {
        res.status(500).json({ message: 'Erro ao buscar espécie', error: error.message });
    }
};

// 3. Rota para buscar todas as raças de uma espécie
exports.getBreedsFromSpecie = async (req, res) => {
    const { specie_id } = req.query;

    try {
        const { data, error } = await supabase
            .from('breed')
            .select('id, name, specie_id')
            .eq('specie_id', specie_id);

        if (error) throw error;

        res.status(200).json(data);
    } catch (error) {
        res.status(500).json(error);
    }
};

// 4. Rota para buscar uma raça pelo ID
exports.getBreedById = async (req, res) => {
    const { breed_id } = req.query;
    console.log(breed_id)
    try {
        const { data, error } = await supabase
            .from('breed')
            .select('id, name, specie_id') // Inclui specie_id no retorno
            .eq('id', breed_id); // Filtra pela raça com o ID correspondente

        if (error) throw error;

        res.status(200).json({ breed: data });
    } catch (error) {
        res.status(500).json({ message: 'Erro ao buscar raça', error: error.message });
    }
};
exports.search = async (req, res) => {

}
