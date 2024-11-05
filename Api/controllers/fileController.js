const supabase = require("../util/init");
const multer = require('multer');

// Configurando o multer para armazenar o arquivo na memória
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

// Endpoint de upload
exports.uploadImage = [
  upload.single('file'), // O nome do campo usado no form-data é 'file'
  async (req, res) => {
    try {
      const file = req.file;

      if (!file) {
        return res.status(400).json({ message: 'No image file provided' });
      }

      const fileName = `${Date.now()}_${file.originalname}`;

      // Fazer upload da imagem para o Supabase Storage
      const { data, error } = await supabase.storage
        .from('uploads')
        .upload(fileName, file.buffer, {
          cacheControl: '3600',
          upsert: false,
          contentType: file.mimetype, // Garantir que o tipo de arquivo seja correto
        });
      if (error) {
        return res.status(500).json({ error: error.message });
      }

      // Gerar o URL público da imagem
      const { data: publicURL, error: publicUrlError } = await supabase.storage
        .from('uploads')
        .getPublicUrl(fileName);

      if (publicUrlError) {
        return res.status(500).json({ error: publicUrlError.message });
      }
      console.log("veio até aqui")  
      console.log(publicURL)
      return res.status(200).json({ url: publicURL });
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  }
];
