function calcularDesconto(precoOriginal, isFuncionario) {
    return isFuncionario ? precoOriginal * 0.7 : precoOriginal;
}