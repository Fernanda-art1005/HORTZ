function fecharCarrinho(valorProduto, quantidade, valorFrete) {
    let total = valorProduto * quantidade;
    if (total > 200) valorFrete = 0;
    return total + valorFrete;
}