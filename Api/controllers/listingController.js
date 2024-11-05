const supabase = require('../util/init')
const { getBreed, getSpecie } = require('./util/getSpecieBreed')

exports.getListings = (('/', async (req, res) => {
    try {
        // Consulta os 15 listings mais recentes
        const { data: listingsData, error: listingsError } = await supabase
            .from('listing')
            .select('*') // Seleciona todos os campos da tabela
            .order('created_at', { ascending: false }) // Ordena pela data de criação, mais recentes primeiro
            .limit(15); // Limita a 15 registros

        if (listingsError) {
            if (listingsError.code === "PGRST116") { // Se não retornou nenhuma linha
                return res.status(204).json();
            }
            return res.status(500).json(listingsError); // Erro genérico
        }

        // Para cada listagem, busca os dados de specie e breed
        const listingsWithDetails = await Promise.all(listingsData.map(async (listing) => {
            const { data: specieData, error: specieError } = await getSpecie(listing.specie_id);
            const { data: breedData, error: breedError } = await getBreed(listing.breed_id);

            // Adiciona os dados de specie e breed à listagem, se não houver erro
            if (!specieError && !breedError) {
                listing.specie = specieData;
                listing.breed = breedData;
            } else {
                listing.specie = null;
                listing.breed = null;
            }

            return listing;
        }));

        // Retorna os dados dos listings com specie e breed incluídos
        return res.status(200).json({ data: listingsWithDetails });
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao buscar as listagens' });
    }
}));

exports.getListing = (('/'), async (req, res) => {
    const id = req.query.id
    if (!id)
        return res.status(400).json({ message: 'you should provide a listing id' }) // retorna nada

    const { data, error } = await supabase
        .from('listing')
        .select('*')
        .eq('id', id)
        .single()

    if (error) {
        if (error.code == "PGRST116") { // se o código de erro for que "não retornou nenhuma linha" 
            return res.status(204).json()
        }
        return res.status(500).json(error) // erro qualquer
    }

    const { data: specieData, error: specieError } = await getSpecie(data.specie_id)
    const { data: breedData, error: breedError } = await getBreed(data.breed_id)
    if (!specieError || !breedError) {
        data.specie = specieData
        data.breed = breedData
    }

    return res.status(200).json(data)

})

exports.getListingsBySpecie = (('/'), async (req, res) => {
    const specie_id = req.query.specie_id

    try {
        if (!specie_id)
            return res.status(400).json({ message: 'you should provide a specie_id' }) // retorna nada

        const { data, error } = await supabase
            .from('listing')
            .select('*')
            .eq('specie_id', specie_id)

        if (error) {
            if (error.code == "PGRST116") { // se o código de erro for que "não retornou nenhuma linha" 
                return res.status(204).json()
            }
            return res.status(500).json(error) // erro qualquer
        }

        // Para cada listagem, busca os dados de specie e breed
        const listingsWithDetails = await Promise.all(listingsData.map(async (listing) => {
            const { data: specieData, error: specieError } = await getSpecie(listing.specie_id);
            const { data: breedData, error: breedError } = await getBreed(listing.breed_id);

            // Adiciona os dados de specie e breed à listagem, se não houver erro
            if (!specieError && !breedError) {
                listing.specie = specieData;
                listing.breed = breedData;
            } else {
                listing.specie = null;
                listing.breed = null;
            }

            return listing;
        }));

        // Retorna os dados dos listings com specie e breed incluídos
        return res.status(200).json({ data: listingsWithDetails });
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao buscar as listagens' });
    }
})

exports.createListing = (('/'), async (req, res) => {
    const {
        animal_name,
        animal_age,
        description,
        size,
        photo_url, // O URL da imagem enviado anteriormente
        localization,
        specie_id,
        breed_id,
        user_id,
        sex
    } = req.body;

    if (!animal_name || !specie_id || !user_id || !sex) {
        return res.status(400).json({ message: 'Required fields: animal_name, specie_id, user_id, sex' });
    }

    const { data, error } = await supabase
        .from('listing')
        .insert([
            {
                animal_name,
                animal_age,
                description,
                size,
                photo_url, // Esse campo conterá o URL da imagem enviada para o storage
                localization,
                specie_id,
                breed_id,
                user_id,
                sex
            }
        ]);

    if (error) {
        return res.status(500).json(error);
    }

    return res.status(201).json(data); // Retorna os dados da nova listagem
});



