const supabase = require('../util/init')

exports.getComments = (('/'), async (req, res) => {
    const n = (req.query.n) ? req.query.n : 50 // número máximo de registros  ; DEFAULT = 50

    const {data, error} = await supabase
    .from('comment')
    .select('*')
    .limit(n)

    if(error){
        return res.status(500).json({error})
    }

    return res.status(200).json({data})

})

exports.getComment = (('/'), async (req, res) => {
    const id = req.query.id
    if(!id){
        return res.status(400).json({error: 'id was not provided'})
    }

    const {data, error} = await supabase
    .from('comment')
    .select('*')
    .eq('id', id)

    if(error){
        if(error.code == "PGRST116"){ // se o código de erro for que "não retornou nenhuma linha" 
          return res.status(204).json()
        }
        return res.status(500).json({error}) // erro qualquer
      }

    return res.status(200).json({data})

})

exports.getCommentsByUser = (('/'), async (req, res) => {
    const user_id = req.query.user_id 
    if(!user_id){
        return res.status(400).json({message: 'user_id is missing'})
    }

    {
        const { data, error } = await supabase
        .from('profile')
        .select('id')
        .eq('id', user_id)
        .single()

        if(error || !data){
            return res.status(400).json({message: `the post with id \'${user_id}\' doesn\'t exist`})
        }
    }

    const {data, error} = await supabase 
    .from('comment')
    .select('*')
    .eq('user_id', user_id)

    if(error){
        if(error.code == "23503"){
            return res.status(400).json({message: ''})
        }
        return res.status(500).json({error})
    }
    
    return res.status(200).json({data})
})

exports.getCommentByPost = (('/'), async (req, res) => {
    const post_id = req.query.post_id 
    if(!post_id){
        return res.status(400).json({message: 'post_id is missing'})
    }

    {
        const { data, error } = await supabase
        .from('post')
        .select('id')
        .eq('id', post_id)
        .single()

        if(error || !data){
            return res.status(400).json({message: `the post with id \'${post_id}\' doesn\'t exist`})
        }
    }

    const {data, error} = await supabase 
    .from('comment')
    .select('*')
    .eq('post_id', post_id)

    if(error){
        if(error.code == "23503"){
            return res.status(400).json({message: ''})
        }
        return res.status(500).json({error})
    }
    
    return res.status(200).json(data)
})

exports.comment = (('/'), async (req, res) => {
    const { 
      content,
      post_id,
      user_id    
    } = await req.body
  
    if(!content || !post_id || !user_id ){
      return res.status(400).json({message: "missing params"})
    }
  
    const { data: postData, error: postError } = await supabase
    .from('post')
    .select('id')
    .eq('id', post_id)
    .single();
  
  if (postError || !postData) {
    return res.status(400).json({ message: "post_id does not exist" });
  }
  
  // Verificar se o user_id existe
  const { data: userData, error: userError } = await supabase
    .from('profile')
    .select('id')
    .eq('id', user_id)
    .single();
  
  if (userError || !userData) {
    return res.status(400).json({ message: "user_id does not exist" });
  }
    
    const { data, error } = await supabase
    .from('comment')
    .insert([
      { content: content, post_id: post_id, user_id: user_id},
    ])
    .select()
            
    if(error){
      if(error.code == "23503"){
        return res.status(400).json({message: ''})
      }
      return res.status(500).json({error})
    }
  
    return res.status(200).json({data})
})

exports.deleteComment = (('/'), async (req, res) => {
    const id = req.query.id
    if(!id){
        return res.status(400).json({error: 'id was not provided'})
    }

    {
        const {data, error} = await supabase
        .from('comment')
        .select('*')
        .eq('id', id)

        if(error){
            if(error.code == "PGRST116"){ // se o código de erro for que "não retornou nenhuma linha" 
            return res.status(204).json()
            }
            return res.status(500).json({error}) // erro qualquer
        }
    }
    
    return res.status(200).json({data})
})