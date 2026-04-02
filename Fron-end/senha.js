function validarSenha(senha) {
    const proibidas = ["12345678", "senha"];
    return senha.length >= 8 && !proibidas.includes(senha);
}