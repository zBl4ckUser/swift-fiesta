const supabase = require('../util/init')

exports.getRecentPosts = (('/recent'), async (req, res) => {
    try {
        // Obtém os 15 posts mais recentes
        const { data: recentPostsData, error: recentPostsError } = await supabase
            .from('post')
            .select('*, institution(id, name, image_url)') // Inclui os dados da instituição
            .order('created_at', { ascending: false }) // Ordena por data de criação (mais recente primeiro)
            .limit(15); // Limita a 15 posts

        if (recentPostsError) {
            return res.status(500).json({ error: recentPostsError });
        }

        // Formata os posts para incluir o nome da instituição
        const formattedPosts = recentPostsData.map(post => ({
            post_id: post.id,
            institution: {
                institution_id: post.institution.id,
                name: post.institution.name
            },
            ...post // Inclui o restante dos campos do post
        }));

        return res.status(200).json({ data: formattedPosts });
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao buscar os posts mais recentes' });
    }
});

exports.getRecentPostsWithLikedStatus = (('/recent_ul'), async (req, res) => {
    try {
        const { user_id } = req.query;

        // Obtém os 15 posts mais recentes
        const { data: recentPostsData, error: recentPostsError } = await supabase
            .from('post')
            .select('*, institution(id, name, image_url)') // Inclui os dados da instituição
            .order('created_at', { ascending: false }) // Ordena por data de criação (mais recente primeiro)
            .limit(15); // Limita a 15 posts

        if (recentPostsError) {
            return res.status(500).json({ error: recentPostsError });
        }

        // Verifica os posts curtidos pelo usuário na tabela 'like'
        const postIds = recentPostsData.map(post => post.id);
        const { data: likesData, error: likesError } = await supabase
            .from('like')
            .select('post_id')
            .eq('user_id', user_id)
            .in('post_id', postIds); // Filtra os likes do usuário nos posts retornados

        if (likesError) {
            return res.status(500).json({ error: likesError });
        }

        // Cria um set com os post_ids curtidos pelo usuário
        const likedPostsSet = new Set(likesData.map(like => like.post_id));

        // Formata os posts para incluir o nome da instituição e se foi curtido
        const formattedPosts = recentPostsData.map(post => ({
            post_id: post.id,
            institution: {
                institution_id: post.institution.id,
                name: post.institution.name
            },
            liked_by_user: likedPostsSet.has(post.id), // Verifica se o usuário curtiu o post
            ...post // Inclui o restante dos campos do post
        }));

        return res.status(200).json({ data: formattedPosts });
    } catch (error) {
        return res.status(500).json({ error: 'Erro ao buscar os posts mais recentes' });
    }
});

exports.getInstitutionsPosts = (('/'), async (req, res) => {
    const institution_id = req.query.institution_id;

    if (!institution_id) {
        return res.status(400).json({ error: 'institution_id is needed' });
    }

    // Verifica se a instituição existe
    const { data: institutionData, error: institutionError } = await supabase
        .from('institution')
        .select('id, name') // Seleciona apenas os campos necessários
        .eq('id', institution_id)
        .single();
    
    if (institutionError || !institutionData) {
        return res.status(204).json({});
    }

    // Obtém os posts da instituição
    const { data: postsData, error: postsError } = await supabase
        .from('post')
        .select('id') // Seleciona apenas o id dos posts
        .eq('institution_id', institution_id);

    if (postsError) {
        return res.status(500).json({ error: postsError });
    }

    // Formata a resposta para incluir o nome da instituição
    const formattedPosts = postsData.map(post => ({
        post_id: post.id,
        institution: {
            institution_id: institutionData.id,
            name: institutionData.name
        }
    }));

    return res.status(200).json({ data: formattedPosts });
});


    exports.getPostById = (('/'), async (req, res) => {
        const id = req.query.id;

        if (!id) {
            return res.status(400).json({ error: 'id is needed' });
        }

        const { data: postData, error: postError } = await supabase
            .from('post')
            .select('*')
            .eq('id', id)
            .single();

        if (postError) {
            return res.status(500).json({ error: postError });
        }

        return res.status(200).json({ data: postData });
    })

exports.createPost = (('/'), async (req, res) => {
    const { description, institution_id, image_url } = req.body;

    if (!institution_id) {
        return res.status(400).json({ error: 'institution_id is needed' });
    }

    if (!description && !image_url) {
        return res.status(400).json({ error: 'At least one of [description, image_url] must be provided' });
    }

    const { data: postData, error: postError } = await supabase
        .from('post')
        .insert([{ description, institution_id, image_url }]) // Insere como objeto dentro de um array
        .single();

    if (postError) {
        return res.status(500).json({ error: postError });
    }

    return res.status(201).json({ data: postData });
})

exports.putPost = (('/'), async (req, res) => {
    const { description, image_url, id } = req.body;

    if (!id) {
        return res.status(400).json({ error: 'id is needed' });
    }

    if (!description && !image_url) {
        return res.status(400).json({ error: 'At least one of [description, image_url] must be provided' });
    }

    const { data: updatedData, error: updateError } = await supabase
        .from('post')
        .update({ description, image_url }) // Atualiza os campos
        .eq('id', id)
        .select()
        .single();

    if (updateError) {
        return res.status(500).json({ error: updateError });
    }

    return res.status(200).json({ data: updatedData }); // 200 OK para updates
})

exports.patchPost = (('/'), async (req, res) => {
    const { description, institution_id, image_url, id } = req.body; 
    const updateData = {}

    if(!id){
        return res.status(400).json({error: 'id is needed'})
    }

    if (description) {
        updateData.description = description;
    }
    if (institution_id) {
        updateData.institution_id = institution_id;
    }
    if (image_url) {
        updateData.image_url = image_url;
    }

    const { data, error } = await supabase
        .from('post')
        .update(updateData)
        .eq('id', id)

    if(error){
        return res.status(500).json({error})
    }

    return res.status(200).json({data})
}) 

exports.deletePost = (('/'), async (req, res) => {
    const { institution_id } = req.body;

    if (!institution_id) {
        return res.status(400).json({ error: 'institution_id is needed' });
    }

    const { error: deleteError } = await supabase
        .from('post')
        .delete()
        .eq('institution_id', institution_id);

    if (deleteError) {
        return res.status(500).json({ error: deleteError });
    }

    return res.status(204).json({}); // 204 No Content para deleção
})