const supabase = require('../util/init')
const { getSpecie, getBreed } = require('./util/getSpecieBreed')

exports.getFavoriteListings = async (req, res) => {
    const { user_id } = req.query;
    console.log(user_id);

    try {
        // Busca os listings favoritados do usuário
        const { data: favoritesData, error: favoritesError } = await supabase
            .from('like')
            .select('listing_id')
            .is('post_id', null)
            .eq('user_id', user_id);

        if (favoritesError) {
            return res.status(500).json(favoritesError);
        }

        // Se não houver listagens favoritadas, retorna uma lista vazia
        if (favoritesData.length === 0) {
            return res.status(204).json();
        }

        const listingIds = favoritesData.map(favorite => favorite.listing_id);

        // Busca os detalhes das listagens correspondentes
        const { data: listingsData, error: listingsError } = await supabase
            .from('listing')
            .select('*')
            .in('id', listingIds);

        if (listingsError) {
            return res.status(500).json(listingsError);
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

        // Retorna as listagens favoritadas com specie e breed incluídos
        return res.status(200).json(listingsWithDetails);
    } catch (error) {
        console.log(error)
        return res.status(500).json(error);
    }
};


exports.getLikedPosts = async (req, res) => {
    const { user_id } = req.query;
    try {
        // Busca os IDs dos posts que o usuário curtiu
        const { data: postsData, error: postsError } = await supabase
            .from('like')
            .select('post_id')
            .is('listing_id', null)
            .eq('user_id', user_id);
        if (postsError) {
            return res.status(500).json(postsError);
        }

        // Se não houver posts curtidos, retorna uma lista vazia
        if (postsData.length === 0) {
            return res.status(204).json([]);
        }

        const postIds = postsData.map(post => post.post_id);

        // Agora, busca os detalhes dos posts correspondentes
        const { data: likedPostsData, error: likedPostsError } = await supabase
            .from('post')
            .select('*')
            .in('id', postIds);

        if (likedPostsError) {
            return res.status(500).json(likedPostsError);
        }

        return res.status(200).json(likedPostsData);
    } catch (error) {
        return res.status(500).json(error);
    }
};


exports.getLikesCountFromPost = async (req, res) => {
    const { post_id } = req.query;
    try {
        const { data, error } = await supabase
            .from('like')
            .select('count(*)')
            .eq('post_id', post_id)
            .is('listing_id', null);

        if (error) {
            return res.status(500).json(error);
        }

        return res.status(200).json(data[0].count);
    } catch (error) {
        return res.status(500).json(error);
    }
};

exports.toggleLike = async (req, res) => {
    const { user_id, post_id, listing_id } = req.body;
    console.log(user_id, post_id, listing_id)
    if(!user_id){
        res.status(400).json({message: 'user_id is required'})
    }

    if(!post_id && !listing_id){
        return res.status(400).json({message: 'at least one of [post_id, listing_id] are required'})
    }

    if(!listing_id){
        try {
            // Verifica se o usuário já curtiu o post
            const { data: likeData, error: likeError } = await supabase
                .from('like')
                .select('*')
                .eq('user_id', user_id)
                .eq('post_id', post_id)
                .single(); // Retorna apenas um registro, já que a combinação é única
    
            if (likeError && likeError.code !== 'PGRST116') { // 'PGRST116' significa que não encontrou dados
                return res.status(500).json({ error: likeError });
            }
    
            if (likeData) {
                // Se o like já existe, remove (descurtir)
                const { error: deleteError } = await supabase
                    .from('like')
                    .delete()
                    .eq('user_id', user_id)
                    .eq('post_id', post_id);
    
                if (deleteError) {
                    return res.status(500).json({ error: deleteError });
                }
    
                return res.status(200).json({ message: 'Like succesfully removed' });
            } else {
                // Caso contrário, insere (curtir)
                const { error: insertError } = await supabase
                    .from('like')
                    .insert({ user_id, post_id });
    
                if (insertError) {
                    return res.status(500).json({ error: insertError });
                }
    
                return res.status(201).json({ message: 'Like succesfully added' });
            }
        } catch (error) {
            return res.status(500).json({ error: 'Error processing like action' });
        }
    }
    else{
        try {
            // Verifica se o usuário já curtiu o post
            const { data: likeData, error: likeError } = await supabase
                .from('like')
                .select('*')
                .eq('user_id', user_id)
                .eq('listing_id', listing_id)
                .single(); // Retorna apenas um registro, já que a combinação é única
    
            if (likeError && likeError.code !== 'PGRST116') { // 'PGRST116' significa que não encontrou dados
                return res.status(500).json({ error: likeError });
            }
    
            if (likeData) {
                // Se o like já existe, remove (descurtir)
                const { error: deleteError } = await supabase
                    .from('like')
                    .delete()
                    .eq('user_id', user_id)
                    .eq('listing_id', listing_id);
    
                if (deleteError) {
                    return res.status(500).json({ error: deleteError });
                }
    
                return res.status(200).json({ message: 'Like succesfully removed' });
            } else {
                // Caso contrário, insere (curtir)
                const { error: insertError } = await supabase
                    .from('like')
                    .insert({ user_id, listing_id });
    
                if (insertError) {
                    return res.status(500).json({ error: insertError });
                }
    
                return res.status(201).json({ message: 'Like succesfully added' });
            }
        } catch (error) {
            return res.status(500).json({ error: 'Error processing like action' });
        }
    }
};