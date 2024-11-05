
const supabase = require("../util/init")
const validations = require('../util/validations')

//Selects a user using the account email
exports.getUser = (('/'), async (req, res) => {
  const email = req.query.email

  if (!email) {
    return res.status(400).json({ error: 'Email is required' });
  }

  const { data, error } = await supabase
    .from('profile')
    .select('*')
    .eq('email', email)
    .single()

  if (error) {
    if (error.code == "PGRST116") { // se o código de erro for que "não retornou nenhuma linha" 
      return res.status(204).json()
    }
    return res.status(500).json(error) // erro qualquer
  }

  return res.status(200).json({ data }) // sucesso
})

exports.signUp = async (req, res) => {
  const { email, password, name } = req.body;
  console.log(email)
  console.log(password)
  console.log(name)

  if (!email || !password || !name) {
    return res.status(400).json({ error: 'Email, password and name are required' });
  }
  if (!validations.isValidPassword(password)) {
    return res.status(400).json({ error: 'Password must contain lowercase, uppercase letters, digits and symbols' })
  }

  // Tenta criar o usuário no Supabase
  const { error: signupError } = await supabase.auth.signUp({ email, password })

  if (signupError) {
    return res.status(400).json({ error: signupError.message });
  }

  try {
    // Se o sign-up for bem-sucedido, insira os dados no perfil
    const { data: user, error: profileError } = await supabase
      .from('profile')
      .update({ email: email, name: name, })
      .eq('email', email)
      .select()

    if (profileError) {
      console.log(profileError)
      return res.status(400).json({ error: profileError.message });
    }

    // Retorna sucesso
    return res.status(201).json({ data: user });
  } catch (e) {
    console.log(e)
  }
};


exports.signIn = (('/'), async (req, res) => {
  const { email, password } = req.body

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  let id;

  {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: email,
      password: password
    });

    if (error) {
      if (error.code === 'invalid_credentials') {
        return res.status(401).json({ error: error.message });
      }
      return res.status(500).json({ error: error.message });
    }
    id = data.user.id

  }

  const {data, error} = await supabase
    .from('profile')
    .select('*')
    .eq('id', id)

  if(error){
    return res.status(500).json(error)
  }

  return res.status(200).json(data);
})

// exports.resetPassword = (('/'), async (req, res) => {
//   const { data, error } = await supabase.auth.resetPasswordForEmail(email);

//   if (error) {
//     console.error('Error resetting password:', error.message);
//   }

//   return data;
// })

exports.signOut = (('/'), async (req, res) => {
  const { data, error } = await supabase.auth.signOut()
  if (error) {
    return res.status(500).json({ error })
  }
  return res.status(200).json({ data })
})

exports.deleteUser = (('/'), async (req, res) => {
  const { id } = req.body
  if (!id) {
    res.status(400).json({ error: 'id is needed' })
  }

  const { data, error } = await supabase
    .from('profile')
    .delete()
    .eq('id', id)
    .select()

  if (error) {
    return res.status(500).json({ error })
  }

  return res.status(204).json({ data })
})

exports.updateUser = async (req, res) => {
  const { id, email, phone, name, avatar_url } = req.body;

  if (!id) {
    return res.status(400).json({ error: "id is required" });
  }

  try {
    const updates = {};
    if (email) updates.email = email;
    if (phone) updates.phone = phone;
    if (name) updates.name = name;
    if (avatar_url) updates.avatar_url = avatar_url;

    const { data, error } = await supabase
      .from('profile')
      .update({ ...updates, updated_at: new Date() })
      .eq('id', id)
      .select();

    if (error) {
      console.error(error);
      return res.status(500).json({ error });
    }

    return res.status(200).json(data);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};


module.exports